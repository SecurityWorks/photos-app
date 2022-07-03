import 'dart:ui';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/public_keys_db.dart';
import 'package:photos/events/backup_folders_updated_event.dart';
import 'package:photos/models/collection.dart';
import 'package:photos/models/public_key.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/services/feature_flag_service.dart';
import 'package:photos/services/user_service.dart';
import 'package:photos/ui/common/dialogs.dart';
import 'package:photos/ui/common/gradient_button.dart';
import 'package:photos/ui/common/loading_widget.dart';
import 'package:photos/ui/payment/subscription.dart';
import 'package:photos/ui/sharing/manage_links_widget.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/email_util.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/share_util.dart';
import 'package:photos/utils/toast_util.dart';

class SharingDialog extends StatefulWidget {
  final Collection collection;

  SharingDialog(this.collection, {Key key}) : super(key: key);

  @override
  State<SharingDialog> createState() => _SharingDialogState();
}

class _SharingDialogState extends State<SharingDialog> {
  bool _showEntryField = false;
  List<User> _sharees;
  String _email;
  final Logger _logger = Logger("SharingDialogState");

  @override
  Widget build(BuildContext context) {
    _sharees = widget.collection.sharees;
    final children = <Widget>[];
    if (!_showEntryField && _sharees.isEmpty) {
      _showEntryField = true;
    } else {
      for (final user in _sharees) {
        children.add(EmailItemWidget(widget.collection, user.email));
      }
    }
    if (_showEntryField) {
      children.add(_getEmailField());
    }
    children.add(
      Padding(
        padding: EdgeInsets.all(8),
      ),
    );
    if (!_showEntryField) {
      children.add(
        SizedBox(
          width: 220,
          child: GradientButton(
            linearGradientColors: const [
              Color(0xFF2CD267),
              Color(0xFF1DB954),
            ],
            onTap: () async {
              setState(() {
                _showEntryField = true;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // child: OutlinedButton(
          //   child: Icon(
          //     Icons.add,
          //     color: Colors.pink,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _showEntryField = true;
          //     });
          //   },
          // ),
          // ),
        ),
      );
    } else {
      children.add(
        SizedBox(
          width: 240,
          height: 50,
          child: OutlinedButton(
            child: Text("Add"),
            onPressed: () {
              _addEmailToCollection(_email?.trim() ?? '');
            },
          ),
        ),
      );
    }

    if (!FeatureFlagService.instance.disableUrlSharing()) {
      bool hasUrl = widget.collection.publicURLs?.isNotEmpty ?? false;
      children.addAll([
        Padding(padding: EdgeInsets.all(16)),
        Divider(height: 1),
        Padding(padding: EdgeInsets.all(12)),
        SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Public link"),
              Switch(
                value: hasUrl,
                onChanged: (enable) async {
                  // confirm if user wants to disable the url
                  if (!enable) {
                    final choice = await showChoiceDialog(
                      context,
                      'Disable link',
                      'Are you sure that you want to disable the album link?',
                      firstAction: 'Yes, disable',
                      secondAction: 'No',
                      actionType: ActionType.critical,
                    );
                    if (choice != DialogUserChoice.firstChoice) {
                      return;
                    }
                  } else {
                    // Add local folder in backup patch before creating
                    // sharable link
                    if (widget.collection.type == CollectionType.folder) {
                      final path = CollectionsService.instance
                          .decryptCollectionPath(widget.collection);
                      if (!Configuration.instance
                          .getPathsToBackUp()
                          .contains(path)) {
                        await Configuration.instance
                            .addPathToFoldersToBeBackedUp(path);
                        Bus.instance.fire(BackupFoldersUpdatedEvent());
                      }
                    }
                  }
                  final dialog = createProgressDialog(
                    context,
                    enable ? "Creating link..." : "Disabling link...",
                  );
                  try {
                    await dialog.show();
                    enable
                        ? await CollectionsService.instance
                            .createShareUrl(widget.collection)
                        : await CollectionsService.instance
                            .disableShareUrl(widget.collection);
                    dialog.hide();
                    setState(() {});
                  } catch (e) {
                    dialog.hide();
                    if (e is SharingNotPermittedForFreeAccountsError) {
                      _showUnSupportedAlert();
                    } else {
                      _logger.severe("failed to share collection", e);
                      showGenericErrorDialog(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.all(8)),
      ]);
      if (widget.collection.publicURLs?.isNotEmpty ?? false) {
        children.add(
          Padding(
            padding: EdgeInsets.all(2),
          ),
        );
        children.add(_getShareableUrlWidget(context));
      }
    }

    return AlertDialog(
      title: Text("Sharing"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: children,
              ),
            ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 4),
    );
  }

  Widget _getEmailField() {
    return Row(
      children: [
        Expanded(
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "email@your-friend.com",
              ),
            ),
            hideOnEmpty: true,
            loadingBuilder: (context) {
              return const EnteLoadingWidget();
            },
            suggestionsCallback: (pattern) async {
              _email = pattern;
              return PublicKeysDB.instance.searchByEmail(_email);
            },
            itemBuilder: (context, suggestion) {
              return Container(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Text(
                  suggestion.email,
                  overflow: TextOverflow.clip,
                ),
              );
            },
            onSuggestionSelected: (PublicKey suggestion) {
              _addEmailToCollection(
                suggestion.email,
                publicKey: suggestion.publicKey,
              );
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(8)),
        IconButton(
          icon: Icon(
            Icons.contact_mail_outlined,
            color: Theme.of(context).buttonColor.withOpacity(0.8),
          ),
          onPressed: () async {
            final emailContact = await FlutterContactPicker.pickEmailContact(
              askForPermission: true,
            );
            _addEmailToCollection(emailContact.email.email);
          },
        ),
      ],
    );
  }

  Widget _getShareableUrlWidget(BuildContext parentContext) {
    String collectionKey = Base58Encode(
      CollectionsService.instance.getCollectionKey(widget.collection.id),
    );
    String url = "${widget.collection.publicURLs.first.url}#$collectionKey";
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(4)),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: url));
              showToast(context, "Link copied to clipboard");
            },
            child: Container(
              padding: EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.02),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      url,
                      style: TextStyle(
                        fontSize: 16,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.68),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(2)),
                  Icon(
                    Icons.copy,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(2)),
          TextButton(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.adaptive.share,
                    color: Theme.of(context).buttonColor,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  Text(
                    "Share link",
                    style: TextStyle(
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              shareText(url);
            },
          ),
          Padding(padding: EdgeInsets.all(4)),
          TextButton(
            child: Center(
              child: Text(
                "Manage link",
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            onPressed: () async {
              routeToPage(
                parentContext,
                ManageSharedLinkWidget(collection: widget.collection),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addEmailToCollection(
    String email, {
    String publicKey,
  }) async {
    if (!isValidEmail(email)) {
      showErrorDialog(
        context,
        "Invalid email address",
        "Please enter a valid email address.",
      );
      return;
    } else if (email == Configuration.instance.getEmail()) {
      showErrorDialog(context, "Oops", "You cannot share with yourself");
      return;
    } else if (widget.collection.sharees.any((user) => user.email == email)) {
      showErrorDialog(
        context,
        "Oops",
        "You're already sharing this with " + email,
      );
      return;
    }
    if (publicKey == null) {
      final dialog = createProgressDialog(context, "Searching for user...");
      await dialog.show();

      publicKey = await UserService.instance.getPublicKey(email);
      await dialog.hide();
    }
    if (publicKey == null) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      final dialog = AlertDialog(
        title: Text("Invite to ente?"),
        content: Text(
          "Looks like " +
              email +
              " hasn't signed up for ente yet. would you like to invite them?",
          style: TextStyle(
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Invite",
              style: TextStyle(
                color: Theme.of(context).buttonColor,
              ),
            ),
            onPressed: () {
              shareText(
                "Hey, I have some photos to share. Please install https://ente.io so that I can share them privately.",
              );
            },
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        },
      );
    } else {
      final dialog = createProgressDialog(context, "Sharing...");
      await dialog.show();
      final collection = widget.collection;
      try {
        if (collection.type == CollectionType.folder) {
          final path =
              CollectionsService.instance.decryptCollectionPath(collection);
          if (!Configuration.instance.getPathsToBackUp().contains(path)) {
            await Configuration.instance.addPathToFoldersToBeBackedUp(path);
          }
        }
        await CollectionsService.instance
            .share(widget.collection.id, email, publicKey);
        await dialog.hide();
        showShortToast(context, "Shared successfully!");
        setState(() {
          _sharees.add(User(email: email));
          _showEntryField = false;
        });
      } catch (e) {
        await dialog.hide();
        if (e is SharingNotPermittedForFreeAccountsError) {
          _showUnSupportedAlert();
        } else {
          _logger.severe("failed to share collection", e);
          showGenericErrorDialog(context);
        }
      }
    }
  }

  void _showUnSupportedAlert() {
    AlertDialog alert = AlertDialog(
      title: Text("Sorry"),
      content:
          Text("Sharing is not permitted for free accounts, please subscribe"),
      actions: [
        TextButton(
          child: Text(
            "Subscribe",
            style: TextStyle(
              color: Theme.of(context).buttonColor,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return getSubscriptionPage();
                },
              ),
            );
          },
        ),
        TextButton(
          child: Text(
            "Ok",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
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

class EmailItemWidget extends StatelessWidget {
  final Collection collection;
  final String email;

  const EmailItemWidget(
    this.collection,
    this.email, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            email,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(child: SizedBox()),
        IconButton(
          icon: Icon(Icons.delete_forever),
          color: Colors.redAccent,
          onPressed: () async {
            final dialog = createProgressDialog(context, "Please wait...");
            await dialog.show();
            try {
              await CollectionsService.instance.unshare(collection.id, email);
              collection.sharees.removeWhere((user) => user.email == email);
              await dialog.hide();
              showToast(context, "Stopped sharing with " + email + ".");
              Navigator.of(context).pop();
            } catch (e, s) {
              Logger("EmailItemWidget").severe(e, s);
              await dialog.hide();
              showGenericErrorDialog(context);
            }
          },
        ),
      ],
    );
  }
}