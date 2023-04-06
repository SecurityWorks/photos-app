import 'dart:developer' as dev;
import "package:flutter/material.dart";
import "package:photos/models/file.dart";
import "package:photos/models/file_load_result.dart";
import "package:photos/services/files_service.dart";
import "package:photos/services/location_service.dart";
import "package:photos/states/location_screen_state.dart";
import "package:photos/theme/colors.dart";
import "package:photos/theme/ente_theme.dart";
import "package:photos/ui/common/loading_widget.dart";
import "package:photos/ui/components/buttons/icon_button_widget.dart";
import "package:photos/ui/components/title_bar_title_widget.dart";
import "package:photos/ui/components/title_bar_widget.dart";
import "package:photos/ui/viewer/gallery/gallery.dart";
import "package:photos/ui/viewer/location/edit_location_sheet.dart";

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 48),
        child: TitleBarWidget(
          isSliver: false,
          isFlexibleSpaceDisabled: true,
          actionIcons: [LocationScreenPopUpMenu()],
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 102,
            width: double.infinity,
            child: const LocationGalleryWidget(),
          ),
        ],
      ),
    );
  }
}

class LocationScreenPopUpMenu extends StatelessWidget {
  const LocationScreenPopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = getEnteTextTheme(context);
    final colorScheme = getEnteColorScheme(context);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: PopupMenuButton(
          elevation: 5,
          offset: const Offset(10, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: colorScheme.backgroundElevated2,
          child: const IconButtonWidget(
            icon: Icons.more_horiz,
            iconButtonType: IconButtonType.primary,
            disableGestureDetector: true,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: "edit",
                child: Text(
                  "Edit",
                  style: textTheme.bodyBold,
                ),
              ),
              PopupMenuItem(
                onTap: () {},
                value: "delete",
                child: Text(
                  "Delete Location",
                  style: textTheme.bodyBold.copyWith(color: warning500),
                ),
              ),
            ];
          },
          onSelected: (value) {
            if (value == "edit") {
              showEditLocationSheet(
                context,
                InheritedLocationScreenState.of(context).locationTagEntity,
                () {},
              );
            } else if (value == "delete") {
              // LocationService.instance.deleteLocation(
              //   InheritedLocationScreenState.of(context)
              //       .locationTagEntity,
              // );
              // Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }
}

class LocationGalleryWidget extends StatefulWidget {
  const LocationGalleryWidget({super.key});

  @override
  State<LocationGalleryWidget> createState() => _LocationGalleryWidgetState();
}

class _LocationGalleryWidgetState extends State<LocationGalleryWidget> {
  late final Future<FileLoadResult> fileLoadResult;
  late Future<void> removeIgnoredFiles;
  late Widget galleryHeaderWidget;
  @override
  void initState() {
    fileLoadResult = FilesService.instance.fetchAllFilesWithLocationData();
    removeIgnoredFiles =
        FilesService.instance.removeIgnoredFiles(fileLoadResult);
    galleryHeaderWidget = const GalleryHeaderWidget();
    super.initState();
  }

  @override
  void dispose() {
    InheritedLocationScreenState.memoryCountNotifier.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRadius =
        InheritedLocationScreenState.of(context).locationTagEntity.item.radius;
    final centerPoint = InheritedLocationScreenState.of(context)
        .locationTagEntity
        .item
        .centerPoint;
    Future<FileLoadResult> filterFiles() async {
      final FileLoadResult result = await fileLoadResult;
      //wait for ignored files to be removed after init
      await removeIgnoredFiles;
      final stopWatch = Stopwatch()..start();
      final copyOfFiles = List<File>.from(result.files);
      copyOfFiles.removeWhere((f) {
        assert(
          f.location != null &&
              f.location!.latitude != null &&
              f.location!.longitude != null,
        );
        return !LocationService.instance.isFileInsideLocationTag(
          centerPoint,
          f.location!,
          selectedRadius,
        );
      });
      dev.log(
        "Time taken to get all files in a location tag: ${stopWatch.elapsedMilliseconds} ms",
      );
      stopWatch.stop();
      InheritedLocationScreenState.memoryCountNotifier.value =
          copyOfFiles.length;

      return Future.value(
        FileLoadResult(
          copyOfFiles,
          result.hasMore,
        ),
      );
    }

    return FutureBuilder(
      //rebuild gallery only when there is change in radius or center point
      key: ValueKey("$centerPoint$selectedRadius"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Gallery(
            loadingWidget: Column(
              children: [
                galleryHeaderWidget,
                EnteLoadingWidget(
                  color: getEnteColorScheme(context).strokeMuted,
                ),
              ],
            ),
            header: galleryHeaderWidget,
            asyncLoader: (
              creationStartTime,
              creationEndTime, {
              limit,
              asc,
            }) async {
              return snapshot.data as FileLoadResult;
            },
            tagPrefix: "location_gallery",
          );
        } else {
          return Column(
            children: [
              galleryHeaderWidget,
              const Expanded(
                child: EnteLoadingWidget(),
              ),
            ],
          );
        }
      },
      future: filterFiles(),
    );
  }
}

class GalleryHeaderWidget extends StatefulWidget {
  const GalleryHeaderWidget({super.key});

  @override
  State<GalleryHeaderWidget> createState() => _GalleryHeaderWidgetState();
}

class _GalleryHeaderWidgetState extends State<GalleryHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    final locationName =
        InheritedLocationScreenState.of(context).locationTagEntity.item.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              key: ValueKey(locationName),
              width: double.infinity,
              child: TitleBarTitleWidget(
                title: locationName,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: InheritedLocationScreenState.memoryCountNotifier,
              builder: (context, value, _) {
                if (value == null) {
                  return RepaintBoundary(
                    child: EnteLoadingWidget(
                      size: 10,
                      color: getEnteColorScheme(context).strokeMuted,
                      alignment: Alignment.centerLeft,
                      padding: 5,
                    ),
                  );
                } else {
                  return Text(
                    value == 1 ? "1 memory" : "$value memories",
                    style: getEnteTextTheme(context).smallMuted,
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
