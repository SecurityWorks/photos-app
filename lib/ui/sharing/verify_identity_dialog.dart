import "dart:convert";

import 'package:bip39/bip39.dart' as bip39;
import "package:crypto/crypto.dart";
import "package:dotted_border/dotted_border.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:logging/logging.dart";
import "package:photos/core/configuration.dart";
import "package:photos/services/user_service.dart";
import "package:photos/theme/ente_theme.dart";
import "package:photos/ui/common/loading_widget.dart";
import "package:photos/ui/components/button_widget.dart";
import "package:photos/ui/components/models/button_type.dart";
import "package:photos/utils/share_util.dart";

class VerifyIdentifyDialog extends StatefulWidget {
  // email id of the user who's verification ID is being displayed for
  // verification
  final String email;

  // self is true when the user is viewing their own verification ID
  final bool self;

  VerifyIdentifyDialog({
    Key? key,
    required this.self,
    this.email = '',
  }) : super(key: key) {
    if (!self && email.isEmpty) {
      throw ArgumentError("email cannot be empty when self is false");
    }
  }

  @override
  State<VerifyIdentifyDialog> createState() => _VerifyIdentifyDialogState();
}

class _VerifyIdentifyDialogState extends State<VerifyIdentifyDialog> {
  final bool doesUserExist = true;

  @override
  Widget build(BuildContext context) {
    final textStyle = getEnteTextTheme(context);
    final String subTitle = widget.self
        ? "This is your Verification ID"
        : "This is ${widget.email}'s Verification ID";
    final String bottomText = widget.self
        ? "Someone sharing albums with you should see the same ID on their "
            "device."
        : "Please ask them to long-press their email address on the settings "
            "screen, and verify that the IDs on both devices match.";

    final AlertDialog alert = AlertDialog(
      title: Text(widget.self ? "Verification ID" : "Verify ${widget.email}"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<String>(
            future: _getPublicKey(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final publicKey = snapshot.data!;
                if (publicKey.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${widget.email} does not have an ente "
                        "account.\n"
                        "\nSend them an invite to share photos.",
                      ),
                      const SizedBox(height: 24),
                      ButtonWidget(
                        buttonType: ButtonType.neutral,
                        icon: Icons.adaptive.share,
                        labelText: "Send invite",
                        isInAlert: true,
                        onTap: () async {
                          shareText(
                            "Download ente so we can easily share original quality photos"
                            " and videos\n\nhttps://ente.io/",
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subTitle,
                        style: textStyle.bodyMuted,
                      ),
                      const SizedBox(height: 20),
                      _verificationIDWidget(context, publicKey),
                      const SizedBox(height: 16),
                      Text(
                        bottomText,
                        style: textStyle.bodyMuted,
                      ),
                      const SizedBox(height: 24),
                      ButtonWidget(
                        buttonType: ButtonType.neutral,
                        isInAlert: true,
                        labelText: widget.self ? "OK" : "Done",
                      ),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                Logger("VerificationID")
                    .severe("failed to end userID", snapshot.error);
                return Text(
                  "Something went wrong",
                  style: textStyle.bodyMuted,
                );
              } else {
                return const SizedBox(
                  height: 200,
                  child: EnteLoadingWidget(),
                );
              }
            },
          ),
        ],
      ),
    );
    return alert;
  }

  Future<String> _getPublicKey() async {
    if (widget.self) {
      return Configuration.instance.getKeyAttributes()!.publicKey;
    }
    final String? userPublicKey =
        await UserService.instance.getPublicKey(widget.email);
    if (userPublicKey == null) {
      // user not found
      return "";
    }
    return userPublicKey;
  }

  Widget _verificationIDWidget(BuildContext context, String publicKey) {
    final colorScheme = getEnteColorScheme(context);
    final textStyle = getEnteTextTheme(context);
    final String verificationID = _generateVerificationID(publicKey);
    return DottedBorder(
      color: colorScheme.strokeMuted,
      //color of dotted/dash line
      strokeWidth: 1,

      dashPattern: const [12, 6],
      radius: const Radius.circular(8),
      //dash patterns, 10 is dash width, 6 is space width
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              if (verificationID.isEmpty) {
                return;
              }
              await Clipboard.setData(
                ClipboardData(text: verificationID),
              );
              shareText(
                widget.self
                    ? "Here's my verification ID: "
                        "$verificationID for ente.io."
                    : "Hey, "
                        "can you confirm that "
                        "this is your ente.io verification "
                        "ID: $verificationID",
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(2),
                ),
                color: colorScheme.backgroundElevated2,
              ),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Text(
                verificationID,
                style: textStyle.bodyBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateVerificationID(String publicKey) {
    final inputBytes = base64.decode(publicKey);
    final shaValue = sha256.convert(inputBytes);
    return bip39.generateMnemonic(
      strength: 256,
      randomBytes: (int size) {
        return Uint8List.fromList(shaValue.bytes);
      },
    );
  }
}