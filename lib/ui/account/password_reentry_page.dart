import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/errors.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/subscription_purchased_event.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/ui/account/recovery_page.dart';
import 'package:photos/ui/common/dynamic_fab.dart';
import 'package:photos/ui/components/buttons/button_widget.dart';
import 'package:photos/ui/home_widget.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/email_util.dart';

class PasswordReentryPage extends StatefulWidget {
  const PasswordReentryPage({Key? key}) : super(key: key);

  @override
  State<PasswordReentryPage> createState() => _PasswordReentryPageState();
}

class _PasswordReentryPageState extends State<PasswordReentryPage> {
  final _logger = Logger((_PasswordReentryPageState).toString());
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  String? email;
  bool _passwordInFocus = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    email = Configuration.instance.getEmail();
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordInFocus = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeypadOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    FloatingActionButtonLocation? fabLocation() {
      if (isKeypadOpen) {
        return null;
      } else {
        return FloatingActionButtonLocation.centerFloat;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: isKeypadOpen,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _getBody(),
      floatingActionButton: DynamicFAB(
        key: const ValueKey("verifyPasswordButton"),
        isKeypadOpen: isKeypadOpen,
        isFormValid: _passwordController.text.isNotEmpty,
        buttonText: S.of(context).verifyPassword,
        onPressedFunction: () async {
          FocusScope.of(context).unfocus();
          final dialog =
              createProgressDialog(context, S.of(context).pleaseWait);
          await dialog.show();
          try {
            await Configuration.instance.decryptAndSaveSecrets(
              _passwordController.text,
              Configuration.instance.getKeyAttributes()!,
            );
          } on KeyDerivationError catch (e, s) {
            _logger.severe("Password verification failed", e, s);
            await dialog.hide();
            final dialogChoice = await showChoiceDialog(
              context,
              title: S.of(context).recreatePasswordTitle,
              body: S.of(context).recreatePasswordBody,
              firstButtonLabel: S.of(context).useRecoveryKey,
            );
            if (dialogChoice!.action == ButtonAction.first) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const RecoveryPage();
                  },
                ),
              );
            }
            return;
          } catch (e, s) {
            _logger.severe("Password verification failed", e, s);
            await dialog.hide();
            final dialogChoice = await showChoiceDialog(
              context,
              title: S.of(context).incorrectPasswordTitle,
              body: S.of(context).pleaseTryAgain,
              firstButtonLabel: S.of(context).contactSupport,
              secondButtonLabel: S.of(context).ok,
            );
            if (dialogChoice!.action == ButtonAction.first) {
              await sendLogs(
                context,
                S.of(context).contactSupport,
                "support@ente.io",
                postShare: () {},
              );
            }
            return;
          }
          await dialog.hide();
          Bus.instance.fire(SubscriptionPurchasedEvent());
          unawaited(
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const HomeWidget();
                },
              ),
              (route) => false,
            ),
          );
        },
      ),
      floatingActionButtonLocation: fabLocation(),
      floatingActionButtonAnimator: NoScalingAnimation(),
    );
  }

  Widget _getBody() {
    return Column(
      children: [
        Expanded(
          child: AutofillGroup(
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Text(
                    S.of(context).welcomeBack,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                Visibility(
                  // hidden textForm for suggesting auto-fill service for saving
                  // password
                  visible: false,
                  child: TextFormField(
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    initialValue: email,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: TextFormField(
                    key: const ValueKey("passwordInputField"),
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      hintText: S.of(context).enterYourPassword,
                      filled: true,
                      contentPadding: const EdgeInsets.all(20),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      suffixIcon: _passwordInFocus
                          ? IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).iconTheme.color,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    controller: _passwordController,
                    autofocus: true,
                    autocorrect: false,
                    obscureText: !_passwordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _passwordFocusNode,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const RecoveryPage();
                              },
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            S.of(context).forgotPassword,
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final dialog = createProgressDialog(
                            context,
                            S.of(context).pleaseWait,
                          );
                          await dialog.show();
                          await Configuration.instance.logout();
                          await dialog.hide();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: Center(
                          child: Text(
                            S.of(context).changeEmail,
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
