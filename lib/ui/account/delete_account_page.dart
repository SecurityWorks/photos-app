import 'dart:convert';

import "package:dropdown_button2/dropdown_button2.dart";
import 'package:flutter/material.dart';
import "package:logging/logging.dart";
import 'package:photos/core/configuration.dart';
import "package:photos/generated/l10n.dart";
import 'package:photos/models/delete_account.dart';
import 'package:photos/services/user_service.dart';
import 'package:photos/theme/ente_theme.dart';
import 'package:photos/ui/components/buttons/button_widget.dart';
import 'package:photos/ui/components/models/button_type.dart';
import 'package:photos/utils/crypto_util.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/email_util.dart';
import "package:photos/utils/toast_util.dart";
import "package:styled_text/styled_text.dart";

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _hasConfirmedDeletion = false;
  final _feedbackTextCtrl = TextEditingController();
  late String _defaultSelection = S.of(context).selectReason;
  String? _dropdownValue;
  late final List<String> _deletionReason = [
    _defaultSelection,
    S.of(context).deleteReason1,
    S.of(context).deleteReason2,
    S.of(context).deleteReason3,
    S.of(context).deleteReason4,
  ];

  @override
  Widget build(BuildContext context) {
    _defaultSelection = S.of(context).selectReason;
    _dropdownValue ??= _defaultSelection;
    final double dropDownTextSize = MediaQuery.of(context).size.width - 120;

    final colorScheme = getEnteColorScheme(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(S.of(context).deleteAccount),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                S.of(context).askDeleteReason,
                style: getEnteTextTheme(context).body,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.fillFaint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton2<String>(
                  alignment: AlignmentDirectional.topStart,
                  value: _dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      _dropdownValue = newValue!;
                    });
                  },
                  underline: const SizedBox(),
                  items: _deletionReason
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      enabled: value != _defaultSelection,
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: dropDownTextSize,
                        child: Text(
                          value,
                          style: value != _defaultSelection
                              ? getEnteTextTheme(context).small
                              : getEnteTextTheme(context).smallMuted,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).deleteAccountFeedbackPrompt,
                style: getEnteTextTheme(context).body,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorScheme.strokeFaint, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorScheme.strokeFaint, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: S.of(context).feedback,
                  contentPadding: const EdgeInsets.all(12),
                ),
                controller: _feedbackTextCtrl,
                autofocus: false,
                autocorrect: false,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
                onChanged: (_) {
                  setState(() {});
                },
              ),
              _shouldAskForFeedback()
                  ? SizedBox(
                      height: 42,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          S.of(context).kindlyHelpUsWithThisInformation,
                          style: getEnteTextTheme(context)
                              .smallBold
                              .copyWith(color: colorScheme.warning700),
                        ),
                      ),
                    )
                  : const SizedBox(height: 42),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasConfirmedDeletion = !_hasConfirmedDeletion;
                  });
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _hasConfirmedDeletion,
                      side: CheckboxTheme.of(context).side,
                      onChanged: (value) {
                        setState(() {
                          _hasConfirmedDeletion = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        S.of(context).confirmDeletePrompt,
                        style: getEnteTextTheme(context).bodyMuted,
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonWidget(
                      buttonType: ButtonType.critical,
                      labelText: S.of(context).confirmAccountDeletion,
                      isDisabled: _shouldBlockDeletion(),
                      onTap: () async {
                        await _initiateDelete(context);
                      },
                      shouldSurfaceExecutionStates: true,
                    ),
                    const SizedBox(height: 8),
                    ButtonWidget(
                      buttonType: ButtonType.secondary,
                      labelText: S.of(context).cancel,
                      onTap: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SafeArea(
                      child: SizedBox(
                        height: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldBlockDeletion() {
    return !_hasConfirmedDeletion ||
        _dropdownValue == _defaultSelection ||
        _shouldAskForFeedback();
  }

  bool _shouldAskForFeedback() {
    return _feedbackTextCtrl.text.trim().isEmpty;
  }

  Future<void> _initiateDelete(BuildContext context) async {
    final choice = await showChoiceDialog(
      context,
      title: S.of(context).confirmAccountDeletion,
      body: S.of(context).deleteConfirmDialogBody,
      firstButtonLabel: S.of(context).deleteAccountPermanentlyButton,
      firstButtonType: ButtonType.critical,
      firstButtonOnTap: () async {
        final deleteChallengeResponse =
            await UserService.instance.getDeleteChallenge(context);
        if (deleteChallengeResponse == null) {
          return;
        }
        if (deleteChallengeResponse.allowDelete) {
          await _delete(context, deleteChallengeResponse);
        } else {
          await _requestEmailForDeletion(context);
        }
      },
      isDismissible: false,
    );
    if (choice!.action == ButtonAction.error) {
      await showGenericErrorDialog(context: context);
    }
  }

  Future<void> _delete(
    BuildContext context,
    DeleteChallengeResponse response,
  ) async {
    try {
      final decryptChallenge = CryptoUtil.openSealSync(
        CryptoUtil.base642bin(response.encryptedChallenge),
        CryptoUtil.base642bin(
          Configuration.instance.getKeyAttributes()!.publicKey,
        ),
        Configuration.instance.getSecretKey()!,
      );
      final challengeResponseStr = utf8.decode(decryptChallenge);
      await UserService.instance.deleteAccount(
        context,
        challengeResponseStr,
        reasonCategory: _dropdownValue!,
        feedback: _feedbackTextCtrl.text.trim(),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      showShortToast(context, S.of(context).yourAccountHasBeenDeleted);
    } catch (e, s) {
      Logger("DeleteAccount").severe("failed to delete", e, s);
      showGenericErrorDialog(context: context);
    }
  }

  Future<void> _requestEmailForDeletion(BuildContext context) async {
    final AlertDialog alert = AlertDialog(
      title: Text(
        S.of(context).deleteAccount,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      content: StyledText(
        text:
            "${S.of(context).deleteEmailRequest}\n\n${S.of(context).deleteRequestSLAText}",
        tags: {
          'warning': StyledTextTag(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[300],
            ),
          ),
        },
      ),
      actions: [
        TextButton(
          child: Text(
            S.of(context).sendEmail,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            await sendEmail(
              context,
              to: 'account-deletion@ente.io',
              subject: '[${S.of(context).deleteAccount}]',
            );
          },
        ),
        TextButton(
          child: Text(
            S.of(context).ok,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
