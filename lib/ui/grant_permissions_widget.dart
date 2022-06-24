import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/services/sync_service.dart';

class GrantPermissionsWidget extends StatelessWidget {
  const GrantPermissionsWidget({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 100, 0, 50),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        isLightMode
                            ? Image.asset(
                                'assets/loading_photos_background.png',
                                color: Colors.white.withOpacity(0.4),
                                colorBlendMode: BlendMode.modulate,
                              )
                            : Image.asset(
                                'assets/loading_photos_background_dark.png'),
                        Center(
                          child: Image.asset(
                            "assets/gallery_locked.png",
                            height: 160,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(text: 'ente '),
                        TextSpan(
                          text: "needs permission to ",
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        TextSpan(text: 'preserve your photos'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).backgroundColor,
              spreadRadius: 200,
              blurRadius: 100,
              offset: Offset(0, 160),
            )
          ],
        ),
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: Platform.isIOS ? 40 : 16,
        ),
        child: OutlinedButton(
          child: Text("Grant permission"),
          onPressed: () async {
            final state = await PhotoManager.requestPermissionExtend();
            if (state == PermissionState.authorized ||
                state == PermissionState.limited) {
              await SyncService.instance.onPermissionGranted(state);
            } else if (state == PermissionState.denied) {
              AlertDialog alert = AlertDialog(
                title: Text("Please grant permissions"),
                content: Text(
                  "ente can encrypt and preserve files only if you grant access to them",
                ),
                actions: [
                  TextButton(
                    child: Text(
                      "OK",
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      if (Platform.isIOS) {
                        PhotoManager.openSetting();
                      }
                    },
                  ),
                ],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
                barrierColor: Colors.black12,
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
