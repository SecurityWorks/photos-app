import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/events/files_updated_event.dart';
import 'package:photos/models/file/file.dart';
import 'package:photos/models/selected_files.dart';
import 'package:photos/theme/ente_theme.dart';
import "package:photos/ui/viewer/gallery/component/grid/place_holder_grid_view_widget.dart";
import "package:photos/ui/viewer/gallery/component/group/group_gallery.dart";
import "package:photos/ui/viewer/gallery/component/group/group_header_widget.dart";
import 'package:photos/ui/viewer/gallery/gallery.dart';
import "package:photos/ui/viewer/gallery/state/gallery_context_state.dart";

class LazyGroupGallery extends StatefulWidget {
  final List<EnteFile> files;
  final int index;
  final Stream<FilesUpdatedEvent>? reloadEvent;
  final Set<EventType> removalEventTypes;
  final GalleryLoader asyncLoader;
  final SelectedFiles? selectedFiles;
  final String tag;
  final String? logTag;
  final Stream<int> currentIndexStream;
  final int photoGridSize;
  final bool enableFileGrouping;
  final bool limitSelectionToOne;
  final bool showSelectAllByDefault;
  const LazyGroupGallery(
    this.files,
    this.index,
    this.reloadEvent,
    this.removalEventTypes,
    this.asyncLoader,
    this.selectedFiles,
    this.tag,
    this.currentIndexStream,
    this.enableFileGrouping,
    this.showSelectAllByDefault, {
    this.logTag = "",
    this.photoGridSize = photoGridSizeDefault,
    this.limitSelectionToOne = false,
    Key? key,
  }) : super(key: key);

  @override
  State<LazyGroupGallery> createState() => _LazyGroupGalleryState();
}

class _LazyGroupGalleryState extends State<LazyGroupGallery> {
  static const numberOfGroupsToRenderBeforeAndAfter = 8;
  late final ValueNotifier<bool> _showSelectAllButtonNotifier;
  late final ValueNotifier<bool> _areAllFromGroupSelectedNotifer;

  late Logger _logger;

  late List<EnteFile> _files;
  Set<EnteFile>? _filesAsSet;
  late StreamSubscription<FilesUpdatedEvent>? _reloadEventSubscription;
  late StreamSubscription<int> _currentIndexSubscription;
  bool? _shouldRender;

  @override
  void initState() {
    super.initState();
    _areAllFromGroupSelectedNotifer = ValueNotifier(_areAllFromGroupSelected());

    widget.selectedFiles?.addListener(_selectedFilesListener);
    _showSelectAllButtonNotifier = ValueNotifier(widget.showSelectAllByDefault);
    _init();
  }

  void _init() {
    _logger = Logger("LazyLoading_${widget.logTag}");
    _shouldRender = true;
    _files = widget.files;
    _reloadEventSubscription = widget.reloadEvent?.listen((e) => _onReload(e));

    _currentIndexSubscription =
        widget.currentIndexStream.listen((currentIndex) {
      final bool shouldRender = (currentIndex - widget.index).abs() <
          numberOfGroupsToRenderBeforeAndAfter;
      if (mounted && shouldRender != _shouldRender) {
        setState(() {
          _shouldRender = shouldRender;
        });
      }
    });
  }

  Set<EnteFile> get _setOfFiles {
    _filesAsSet ??= _files.toSet();
    return _filesAsSet!;
  }

  bool _areAllFromGroupSelected() {
    if (widget.selectedFiles != null &&
        widget.selectedFiles!.files.length >= widget.files.length) {
      widget.selectedFiles!.files.containsAll(widget.files);
      return widget.selectedFiles!.files.containsAll(widget.files);
    } else {
      return false;
    }
  }

  Future _onReload(FilesUpdatedEvent event) async {
    final DateTime groupDate =
        DateTime.fromMicrosecondsSinceEpoch(_files[0].creationTime!);
    // iterate over  files and check if any of the belongs to this group
    final anyCandidateForGroup = event.updatedFiles.any((file) {
      final fileDate = DateTime.fromMicrosecondsSinceEpoch(file.creationTime!);
      return fileDate.year == groupDate.year &&
          fileDate.month == groupDate.month &&
          fileDate.day == groupDate.day;
    });
    if (anyCandidateForGroup) {
      if (kDebugMode) {
        _logger.info(
          " files were updated due to ${event.reason} on " +
              DateTime.fromMicrosecondsSinceEpoch(
                groupDate.microsecondsSinceEpoch,
              ).toIso8601String(),
        );
      }
      if (event.type == EventType.addedOrUpdated ||
          widget.removalEventTypes.contains(event.type)) {
        // We are reloading the whole group
        final dayStartTime =
            DateTime(groupDate.year, groupDate.month, groupDate.day);
        final result = await widget.asyncLoader(
          dayStartTime.microsecondsSinceEpoch,
          dayStartTime.microsecondsSinceEpoch + microSecondsInDay - 1,
          asc: GalleryContextState.of(context)!.sortOrderAsc,
        );
        if (mounted) {
          setState(() {
            _files = result.files;
          });
        }
      } else if (kDebugMode) {
        debugPrint("Unexpected event ${event.type.name}");
      }
    }
  }

  @override
  void dispose() {
    _reloadEventSubscription?.cancel();
    _currentIndexSubscription.cancel();
    _areAllFromGroupSelectedNotifer.dispose();
    widget.selectedFiles?.removeListener(_selectedFilesListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(LazyGroupGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(_files, widget.files)) {
      _reloadEventSubscription?.cancel();
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_files.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.enableFileGrouping)
              GroupHeaderWidget(
                timestamp: _files[0].creationTime!,
                gridSize: widget.photoGridSize,
              ),
            widget.limitSelectionToOne
                ? const SizedBox.shrink()
                : ValueListenableBuilder(
                    valueListenable: _showSelectAllButtonNotifier,
                    builder: (context, dynamic value, _) {
                      return !value
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: SizedBox(
                                width: 48,
                                height: 44,
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      _areAllFromGroupSelectedNotifer,
                                  builder: (context, dynamic value, _) {
                                    return value
                                        ? const Icon(
                                            Icons.check_circle,
                                            size: 18,
                                          )
                                        : Icon(
                                            Icons.check_circle_outlined,
                                            color: getEnteColorScheme(context)
                                                .strokeMuted,
                                            size: 18,
                                          );
                                  },
                                ),
                              ),
                              onTap: () {
                                widget.selectedFiles?.toggleGroupSelection(
                                  _setOfFiles,
                                );
                              },
                            );
                    },
                  ),
          ],
        ),
        _shouldRender!
            ? GroupGallery(
                photoGridSize: widget.photoGridSize,
                files: _files,
                tag: widget.tag,
                asyncLoader: widget.asyncLoader,
                selectedFiles: widget.selectedFiles,
                limitSelectionToOne: widget.limitSelectionToOne,
              )
            // todo: perf eval should we have separate PlaceHolder for Groups
            //  instead of creating a large cached view
            : PlaceHolderGridViewWidget(
                _files.length,
                widget.photoGridSize,
              ),
      ],
    );
  }

  void _selectedFilesListener() {
    if (widget.selectedFiles == null) return;
    _areAllFromGroupSelectedNotifer.value =
        widget.selectedFiles!.files.containsAll(_setOfFiles);

    //Can remove this if we decide to show select all by default for all galleries
    if (widget.selectedFiles!.files.isEmpty && !widget.showSelectAllByDefault) {
      _showSelectAllButtonNotifier.value = false;
    } else {
      _showSelectAllButtonNotifier.value = true;
    }
  }
}
