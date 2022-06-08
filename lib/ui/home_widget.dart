import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/events/account_configured_event.dart';
import 'package:photos/events/backup_folders_updated_event.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/events/force_reload_home_gallery_event.dart';
import 'package:photos/events/local_photos_updated_event.dart';
import 'package:photos/events/permission_granted_event.dart';
import 'package:photos/events/subscription_purchased_event.dart';
import 'package:photos/events/sync_status_update_event.dart';
import 'package:photos/events/tab_changed_event.dart';
import 'package:photos/events/trigger_logout_event.dart';
import 'package:photos/events/user_logged_out_event.dart';
import 'package:photos/models/file_load_result.dart';
import 'package:photos/models/galleryType.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/services/collections_service.dart';
import 'package:photos/services/ignored_files_service.dart';
import 'package:photos/services/local_sync_service.dart';
import 'package:photos/services/update_service.dart';
import 'package:photos/services/user_service.dart';
import 'package:photos/ui/app_update_dialog.dart';
import 'package:photos/ui/backup_folder_selection_page.dart';
import 'package:photos/ui/collections_gallery_widget.dart';
import 'package:photos/ui/common/bottomShadow.dart';
import 'package:photos/ui/common/gradientButton.dart';
import 'package:photos/ui/create_collection_page.dart';
import 'package:photos/ui/extents_page_view.dart';
import 'package:photos/ui/gallery.dart';
import 'package:photos/ui/gallery_app_bar_widget.dart';
import 'package:photos/ui/gallery_footer_widget.dart';
import 'package:photos/ui/gallery_overlay_widget.dart';
import 'package:photos/ui/grant_permissions_widget.dart';
import 'package:photos/ui/landing_page_widget.dart';
import 'package:photos/ui/loading_photos_widget.dart';
import 'package:photos/ui/memories_widget.dart';
import 'package:photos/ui/nav_bar.dart';
import 'package:photos/ui/settings_page.dart';
import 'package:photos/ui/shared_collections_gallery.dart';
import 'package:photos/ui/sync_indicator.dart';
import 'package:photos/utils/dialog_util.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  static const _deviceFolderGalleryWidget = CollectionsGalleryWidget();
  static const _sharedCollectionGallery = SharedCollectionGallery();
  static const _settingsPage = SettingsPage();
  static const _headerWidget = HeaderWidget();

  final _logger = Logger("HomeWidgetState");
  final _selectedFiles = SelectedFiles();

  // final _settingsButton = SettingsButton();
  final PageController _pageController = PageController();
  int _selectedTabIndex = 0;
  Widget _headerWidgetWithSettingsButton;

  // for receiving media files
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;

  StreamSubscription<TabChangedEvent> _tabChangedEventSubscription;
  StreamSubscription<SubscriptionPurchasedEvent> _subscriptionPurchaseEvent;
  StreamSubscription<TriggerLogoutEvent> _triggerLogoutEvent;
  StreamSubscription<UserLoggedOutEvent> _loggedOutEvent;
  StreamSubscription<PermissionGrantedEvent> _permissionGrantedEvent;
  StreamSubscription<SyncStatusUpdate> _firstImportEvent;
  StreamSubscription<BackupFoldersUpdatedEvent> _backupFoldersUpdatedEvent;
  StreamSubscription<AccountConfiguredEvent> _accountConfiguredEvent;

  @override
  void initState() {
    _logger.info("Building initstate");
    _headerWidgetWithSettingsButton = Container(
      margin: const EdgeInsets.only(top: 12),
      child: Stack(
        children: const [
          _headerWidget,
        ],
      ),
    );
    _tabChangedEventSubscription =
        Bus.instance.on<TabChangedEvent>().listen((event) {
      if (event.source != TabChangedEventSource.page_view) {
        _selectedTabIndex = event.selectedIndex;
        _pageController.animateToPage(
          event.selectedIndex,
          duration: Duration(milliseconds: 150),
          curve: Curves.easeIn,
        );
      }
    });
    _subscriptionPurchaseEvent =
        Bus.instance.on<SubscriptionPurchasedEvent>().listen((event) {
      setState(() {});
    });
    _accountConfiguredEvent =
        Bus.instance.on<AccountConfiguredEvent>().listen((event) {
      setState(() {});
    });
    _triggerLogoutEvent =
        Bus.instance.on<TriggerLogoutEvent>().listen((event) async {
      AlertDialog alert = AlertDialog(
        title: Text("Session expired"),
        content: Text("Please login again"),
        actions: [
          TextButton(
            child: Text(
              "Ok",
              style: TextStyle(
                color: Theme.of(context).buttonColor,
              ),
            ),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              final dialog = createProgressDialog(context, "Logging out...");
              await dialog.show();
              await Configuration.instance.logout();
              await dialog.hide();
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
    });
    _loggedOutEvent = Bus.instance.on<UserLoggedOutEvent>().listen((event) {
      setState(() {});
    });
    _permissionGrantedEvent =
        Bus.instance.on<PermissionGrantedEvent>().listen((event) async {
      if (mounted) {
        setState(() {});
      }
    });
    _firstImportEvent =
        Bus.instance.on<SyncStatusUpdate>().listen((event) async {
      if (mounted &&
          event.status == SyncStatus.completed_first_gallery_import) {
        setState(() {});
      }
    });
    _backupFoldersUpdatedEvent =
        Bus.instance.on<BackupFoldersUpdatedEvent>().listen((event) async {
      if (mounted) {
        setState(() {});
      }
    });
    _initDeepLinks();
    UpdateService.instance.shouldUpdate().then((shouldUpdate) {
      if (shouldUpdate) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppUpdateDialog(
                  UpdateService.instance.getLatestVersionInfo());
            },
            barrierColor: Colors.black.withOpacity(0.85),
          );
        });
      }
    });
    // For sharing images coming from outside the app while the app is in the memory
    _initMediaShareSubscription();
    super.initState();
  }

  @override
  void dispose() {
    _tabChangedEventSubscription.cancel();
    _subscriptionPurchaseEvent.cancel();
    _triggerLogoutEvent.cancel();
    _loggedOutEvent.cancel();
    _permissionGrantedEvent.cancel();
    _firstImportEvent.cancel();
    _backupFoldersUpdatedEvent.cancel();
    _accountConfiguredEvent.cancel();
    super.dispose();
  }

  void _initMediaShareSubscription() {
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    }, onError: (err) {
      _logger.severe("getIntentDataStream error: $err");
    });
    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _logger.info("Building home_Widget");

    return WillPopScope(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(),
        ),
        body: _getBody(),
      ),
      onWillPop: () async {
        if (_selectedTabIndex == 0) {
          if (Platform.isAndroid) {
            MoveToBackground.moveTaskToBack();
            return false;
          } else {
            return true;
          }
        } else {
          Bus.instance
              .fire(TabChangedEvent(0, TabChangedEventSource.back_button));
          return false;
        }
      },
    );
  }

  Widget _getBody() {
    if (!Configuration.instance.hasConfiguredAccount()) {
      return LandingPageWidget();
    }
    if (!LocalSyncService.instance.hasGrantedPermissions()) {
      return GrantPermissionsWidget();
    }
    if (!LocalSyncService.instance.hasCompletedFirstImport()) {
      return LoadingPhotosWidget();
    }
    if (_sharedFiles != null && _sharedFiles.isNotEmpty) {
      ReceiveSharingIntent.reset();
      return CreateCollectionPage(null, _sharedFiles);
    }

    return Stack(
      children: [
        ExtentsPageView(
          children: [
            (Configuration.instance.getPathsToBackUp().isEmpty &&
                    !LocalSyncService.instance.hasGrantedLimitedPermissions() &&
                    CollectionsService.instance.getActiveCollections().isEmpty)
                ? _getBackupFolderSelectionHook()
                : _getMainGalleryWidget(),
            _deviceFolderGalleryWidget,
            _sharedCollectionGallery,
            _settingsPage,
          ],
          onPageChanged: (page) {
            Bus.instance.fire(TabChangedEvent(
              page,
              TabChangedEventSource.page_view,
            ));
          },
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
        ),
        Align(alignment: Alignment.bottomCenter, child: BottomShadowWidget()),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: EdgeInsets.only(bottom: 8),
            child: HomeBottomNavigationBar(
              _selectedFiles,
              selectedTabIndex: _selectedTabIndex,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GalleryOverlayWidget(GalleryType.homepage, _selectedFiles),
        ),
      ],
    );
  }

  Future<bool> _initDeepLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      if (initialLink != null) {
        _logger.info("Initial link received: " + initialLink);
        _getCredentials(context, initialLink);
        return true;
      } else {
        _logger.info("No initial link received.");
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      _logger.severe("PlatformException thrown while getting initial link");
    }

    // Attach a listener to the stream
    linkStream.listen((String link) {
      _logger.info("Link received: " + link);
      _getCredentials(context, link);
    }, onError: (err) {
      _logger.severe(err);
    });
    return false;
  }

  void _getCredentials(BuildContext context, String link) {
    if (Configuration.instance.hasConfiguredAccount()) {
      return;
    }
    final ott = Uri.parse(link).queryParameters["ott"];
    UserService.instance.verifyEmail(context, ott);
  }

  Widget _getMainGalleryWidget() {
    Widget header;
    if (_selectedFiles.files.isEmpty) {
      header = _headerWidgetWithSettingsButton;
    } else {
      header = _headerWidget;
    }
    final gallery = Gallery(
      asyncLoader: (creationStartTime, creationEndTime, {limit, asc}) async {
        final importantPaths = Configuration.instance.getPathsToBackUp();
        final ownerID = Configuration.instance.getUserID();
        final archivedCollectionIds =
            CollectionsService.instance.getArchivedCollections();
        FileLoadResult result;
        if (importantPaths.isNotEmpty) {
          result = await FilesDB.instance.getImportantFiles(creationStartTime,
              creationEndTime, ownerID, importantPaths.toList(),
              limit: limit,
              asc: asc,
              ignoredCollectionIDs: archivedCollectionIds);
        } else {
          if (LocalSyncService.instance.hasGrantedLimitedPermissions()) {
            result = await FilesDB.instance.getAllLocalAndUploadedFiles(
                creationStartTime, creationEndTime, ownerID,
                limit: limit,
                asc: asc,
                ignoredCollectionIDs: archivedCollectionIds);
          } else {
            result = await FilesDB.instance.getAllUploadedFiles(
                creationStartTime, creationEndTime, ownerID,
                limit: limit,
                asc: asc,
                ignoredCollectionIDs: archivedCollectionIds);
          }
        }
        // hide ignored files from home page UI
        final ignoredIDs = await IgnoredFilesService.instance.ignoredIDs;
        result.files.removeWhere((f) =>
            f.uploadedFileID == null &&
            IgnoredFilesService.instance.shouldSkipUpload(ignoredIDs, f));
        return result;
      },
      reloadEvent: Bus.instance.on<LocalPhotosUpdatedEvent>(),
      removalEventTypes: const {
        EventType.deletedFromRemote,
        EventType.deletedFromEverywhere,
        EventType.archived,
      },
      forceReloadEvents: [
        Bus.instance.on<BackupFoldersUpdatedEvent>(),
        Bus.instance.on<ForceReloadHomeGalleryEvent>(),
      ],
      tagPrefix: "home_gallery",
      selectedFiles: _selectedFiles,
      header: header,
      footer: GalleryFooterWidget(),
    );
    return Stack(
      children: [
        Container(
          child: gallery,
        ),
        HomePageAppBar(_selectedFiles),
      ],
    );
  }

  Widget _getBackupFolderSelectionHook() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _headerWidgetWithSettingsButton,
        Padding(
          padding: const EdgeInsets.only(top: 64),
          child: Image.asset(
            "assets/preserved.png",
            height: 206,
          ),
        ),
        Text('No photos are being backed up right now',
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(fontFamily: 'Inter-Medium', fontSize: 16)),
        Center(
          child: Hero(
            tag: "select_folders",
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                height: 64,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: GradientButton(
                  child: Text(
                    'Start backup',
                    style: gradientButtonTextTheme(),
                  ),
                  linearGradientColors: const [
                    Color(0xFF2CD267),
                    Color(0xFF1DB954),
                  ],
                  onTap: () async {
                    if (LocalSyncService.instance
                        .hasGrantedLimitedPermissions()) {
                      PhotoManager.presentLimited();
                    } else {
                      routeToPage(
                        context,
                        BackupFolderSelectionPage(
                          shouldSelectAll: true,
                          buttonText: "Start backup",
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(50)),
      ],
    );
  }
}

class HomePageAppBar extends StatefulWidget {
  const HomePageAppBar(
    this.selectedFiles, {
    Key key,
  }) : super(key: key);

  final SelectedFiles selectedFiles;

  @override
  _HomePageAppBarState createState() => _HomePageAppBarState();
}

class _HomePageAppBarState extends State<HomePageAppBar> {
  @override
  void initState() {
    super.initState();
    widget.selectedFiles.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = SizedBox(
      height: 60,
      child: GalleryAppBarWidget(
        GalleryType.homepage,
        null,
        widget.selectedFiles,
      ),
    );
    if (widget.selectedFiles.files.isEmpty) {
      return IgnorePointer(child: appBar);
    } else {
      return appBar;
    }
  }
}

class HomeBottomNavigationBar extends StatefulWidget {
  const HomeBottomNavigationBar(
    this.selectedFiles, {
    this.selectedTabIndex,
    Key key,
  }) : super(key: key);

  final SelectedFiles selectedFiles;
  final int selectedTabIndex;

  @override
  _HomeBottomNavigationBarState createState() =>
      _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  StreamSubscription<TabChangedEvent> _tabChangedEventSubscription;
  final _logger = Logger((_HomeBottomNavigationBarState).toString());
  int currentTabIndex;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.selectedTabIndex;
    widget.selectedFiles.addListener(() {
      setState(() {});
    });
    _tabChangedEventSubscription =
        Bus.instance.on<TabChangedEvent>().listen((event) {
      if (event.source != TabChangedEventSource.tab_bar) {
        _logger.fine('index changed to ${event.selectedIndex}');
        if (mounted) {
          setState(() {
            currentTabIndex = event.selectedIndex;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabChangedEventSubscription.cancel();
    super.dispose();
  }

  void _onTabChange(int index) {
    Bus.instance.fire(TabChangedEvent(
      index,
      TabChangedEventSource.tab_bar,
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool filesAreSelected = widget.selectedFiles.files.isNotEmpty;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: filesAreSelected ? 0 : 52,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        opacity: filesAreSelected ? 0.0 : 1.0,
        curve: Curves.easeIn,
        child: IgnorePointer(
          ignoring: filesAreSelected,
          child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 52,
                        width: 240,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: GNav(
                              curve: Curves.easeOutExpo,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .gNavBackgroundColor,
                              mainAxisAlignment: MainAxisAlignment.center,
                              rippleColor: Colors.white.withOpacity(0.1),
                              activeColor: Theme.of(context)
                                  .colorScheme
                                  .gNavBarActiveColor,
                              iconSize: 24,
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              duration: Duration(milliseconds: 200),
                              gap: 0,
                              tabBorderRadius: 24,
                              tabBackgroundColor: Theme.of(context)
                                  .colorScheme
                                  .gNavBarActiveColor,
                              haptic: false,
                              tabs: [
                                GButton(
                                  margin: EdgeInsets.fromLTRB(6, 6, 0, 6),
                                  icon: Icons.home,
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .gNavIconColor,
                                  iconActiveColor: Theme.of(context)
                                      .colorScheme
                                      .gNavActiveIconColor,
                                  text: '',
                                  onPressed: () {
                                    _onTabChange(
                                        0); // To take care of occasional missing events
                                  },
                                ),
                                GButton(
                                  margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
                                  icon: Icons.photo_library,
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .gNavIconColor,
                                  iconActiveColor: Theme.of(context)
                                      .colorScheme
                                      .gNavActiveIconColor,
                                  text: '',
                                  onPressed: () {
                                    _onTabChange(
                                        1); // To take care of occasional missing events
                                  },
                                ),
                                GButton(
                                  margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
                                  icon: Icons.folder_shared,
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .gNavIconColor,
                                  iconActiveColor: Theme.of(context)
                                      .colorScheme
                                      .gNavActiveIconColor,
                                  text: '',
                                  onPressed: () {
                                    _onTabChange(
                                        2); // To take care of occasional missing events
                                  },
                                ),
                                GButton(
                                  margin: EdgeInsets.fromLTRB(0, 6, 6, 6),
                                  icon: Icons.person,
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .gNavIconColor,
                                  iconActiveColor: Theme.of(context)
                                      .colorScheme
                                      .gNavActiveIconColor,
                                  text: '',
                                  onPressed: () {
                                    _onTabChange(
                                        3); // To take care of occasional missing events
                                  },
                                )
                              ],
                              selectedIndex: currentTabIndex,
                              onTabChange: _onTabChange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  static const _memoriesWidget = MemoriesWidget();
  static const _syncIndicator = SyncIndicator();

  const HeaderWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logger("Header").info("Building header widget");
    const list = [
      _syncIndicator,
      _memoriesWidget,
    ];
    return Column(
      children: list,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
