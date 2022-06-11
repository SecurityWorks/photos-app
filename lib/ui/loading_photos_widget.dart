import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/events/sync_status_update_event.dart';
import 'package:photos/services/local_sync_service.dart';
import 'package:photos/ui/backup_folder_selection_page.dart';
import 'package:photos/ui/common/bottomShadow.dart';
import 'package:photos/utils/navigation_util.dart';

class LoadingPhotosWidget extends StatefulWidget {
  const LoadingPhotosWidget({Key key}) : super(key: key);

  @override
  _LoadingPhotosWidgetState createState() => _LoadingPhotosWidgetState();
}

class _LoadingPhotosWidgetState extends State<LoadingPhotosWidget> {
  StreamSubscription<SyncStatusUpdate> _firstImportEvent;
  int _currentPage = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  final List<String> _messages = [
    "web.ente.io has a slick uploader",
    "We have preserved over 3 million memories so far",
    "All our apps are open source",
    "Our encryption protocols have been reviewed by engineers at Google, Apple, Amazon, and Facebook",
    "You can share links to your albums with your loved ones",
    "Our mobile apps run in the background to encrypt and backup new photos you take",
    "We use Xchacha20Poly1305 to safely encrypt your data",
    "One of our data centers is in an underground fall out shelter in Paris",
  ];

  @override
  void initState() {
    super.initState();
    _firstImportEvent =
        Bus.instance.on<SyncStatusUpdate>().listen((event) async {
      if (mounted &&
          event.status == SyncStatus.completed_first_gallery_import) {
        if (LocalSyncService.instance.hasGrantedLimitedPermissions()) {
          // Do nothing, let HomeWidget refresh
        } else {
          routeToPage(
            context,
            BackupFolderSelectionPage(
              shouldSelectAll: true,
              buttonText: "Start backup",
            ),
          );
        }
      }
    });
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        return;
      }
      if (_currentPage < _messages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _firstImportEvent.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  isLightMode
                      ? Image.asset(
                          'assets/loading_photos_light.png',
                          color: Colors.white.withOpacity(0.5),
                          colorBlendMode: BlendMode.modulate,
                        )
                      : Image.asset(
                          'assets/loading_photos_light.png',
                          color: Colors.white.withOpacity(0.25),
                          colorBlendMode: BlendMode.modulate,
                        ),
                  Lottie.asset(
                    'assets/loadingGalleryLottie.json',
                    height: 400,
                  )
                ],
              ),
              Text(
                "Loading your photos...",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.subTextColor,
                ),
              ),
              Padding(padding: EdgeInsets.all(36)),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Did you know?",
                        style: Theme.of(context).textTheme.headline6.copyWith(
                              color: Theme.of(context).colorScheme.greenText,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    height: 175,
                    child: Stack(
                      children: [
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            return _getMessage(_messages[index]);
                          },
                          itemCount: _messages.length,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: BottomShadowWidget(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMessage(String text) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: Theme.of(context)
          .textTheme
          .headline5
          .copyWith(color: Theme.of(context).colorScheme.defaultTextColor),
    );
  }
}
