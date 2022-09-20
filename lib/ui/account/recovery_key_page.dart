// @dart=2.9

import 'dart:io' as io;

import 'package:bip39/bip39.dart' as bip39;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/ui/common/gradient_button.dart';
import 'package:photos/utils/toast_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class RecoveryKeyPage extends StatefulWidget {
  final bool showAppBar;
  final String recoveryKey;
  final String doneText;
  final Function() onDone;
  final bool isDismissible;
  final String title;
  final String text;
  final String subText;
  final bool showProgressBar;

  const RecoveryKeyPage(
    this.recoveryKey,
    this.doneText, {
    Key key,
    this.showAppBar,
    this.onDone,
    this.isDismissible,
    this.title,
    this.text,
    this.subText,
    this.showProgressBar = false,
  }) : super(key: key);

  @override
  State<RecoveryKeyPage> createState() => _RecoveryKeyPageState();
}

class _RecoveryKeyPageState extends State<RecoveryKeyPage> {
  bool _hasTriedToSave = false;
  final _recoveryKeyFile = io.File(
    Configuration.instance.getTempDirectory() + "ente-recovery-key.txt",
  );

  @override
  Widget build(BuildContext context) {
    final String recoveryKey = bip39.entropyToMnemonic(widget.recoveryKey);
    if (recoveryKey.split(' ').length != mnemonicKeyWordCount) {
      throw AssertionError(
        'recovery code should have $mnemonicKeyWordCount words',
      );
    }

    return Scaffold(
      appBar: widget.showProgressBar
          ? AppBar(
              elevation: 0,
              title: Hero(
                tag: "recovery_key",
                child: StepProgressIndicator(
                  totalSteps: 4,
                  currentStep: 3,
                  selectedColor: Theme.of(context).colorScheme.greenAlternative,
                  roundedEdges: const Radius.circular(10),
                  unselectedColor:
                      Theme.of(context).colorScheme.stepProgressUnselectedColor,
                ),
              ),
            )
          : widget.showAppBar
              ? AppBar(
                  elevation: 0,
                  title: Text(widget.title ?? "Recovery key"),
                )
              : null,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          widget.showAppBar
              ? 40
              : widget.showProgressBar
                  ? 32
                  : 120,
          20,
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            widget.showAppBar
                ? const SizedBox.shrink()
                : Text(
                    widget.title ?? "Recovery key",
                    style: Theme.of(context).textTheme.headline4,
                  ),
            Padding(padding: EdgeInsets.all(widget.showAppBar ? 0 : 12)),
            Text(
              widget.text ??
                  "If you forget your password, the only way you can recover your data is with this key.",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const Padding(padding: EdgeInsets.only(top: 24)),
            DottedBorder(
              color: const Color.fromRGBO(17, 127, 56, 1),
              //color of dotted/dash line
              strokeWidth: 1,
              //thickness of dash/dots
              dashPattern: const [6, 6],
              radius: const Radius.circular(8),
              //dash patterns, 10 is dash width, 6 is space width
              child: SizedBox(
                //inner container
                height: 120, //height of inner container
                width:
                    double.infinity, //width to 100% match to parent container.
                // ignore: prefer_const_literals_to_create_immutables
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: recoveryKey),
                        );
                        showToast(context, "Recovery key copied to clipboard");
                        setState(() {
                          _hasTriedToSave = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromRGBO(49, 155, 86, .2),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2),
                          ),
                          color:
                              Theme.of(context).colorScheme.recoveryKeyBoxColor,
                        ),
                        height: 120,
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        child: Text(
                          recoveryKey,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 80,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  widget.subText ??
                      "We don’t store this key, please save this in a safe place.",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _saveOptions(context, recoveryKey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _saveOptions(BuildContext context, String recoveryKey) {
    final List<Widget> childrens = [];
    if (!_hasTriedToSave) {
      childrens.add(
        ElevatedButton(
          style: Theme.of(context).colorScheme.optionalActionButtonStyle,
          onPressed: () async {
            await _saveKeys();
          },
          child: const Text('Do this later'),
        ),
      );
      childrens.add(const SizedBox(height: 10));
    }

    childrens.add(
      GradientButton(
        onTap: () async {
          await _shareRecoveryKey(recoveryKey);
        },
        text: 'Save key',
      ),
    );
    if (_hasTriedToSave) {
      childrens.add(const SizedBox(height: 10));
      childrens.add(
        ElevatedButton(
          child: Text(widget.doneText),
          onPressed: () async {
            await _saveKeys();
          },
        ),
      );
    }
    childrens.add(const SizedBox(height: 12));
    return childrens;
  }

  Future _shareRecoveryKey(String recoveryKey) async {
    if (_recoveryKeyFile.existsSync()) {
      await _recoveryKeyFile.delete();
    }
    _recoveryKeyFile.writeAsStringSync(recoveryKey);
    await Share.shareFiles([_recoveryKeyFile.path]);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _hasTriedToSave = true;
        });
      }
    });
  }

  Future<void> _saveKeys() async {
    Navigator.of(context).pop();
    if (_recoveryKeyFile.existsSync()) {
      await _recoveryKeyFile.delete();
    }
    widget.onDone();
  }
}
