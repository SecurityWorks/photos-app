import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/events/user_details_changed_event.dart';
import 'package:photos/models/duplicate_files.dart';
import 'package:photos/models/file.dart';
import 'package:photos/services/deduplication_service.dart';
import 'package:photos/ui/viewer/file/detail_page.dart';
import 'package:photos/ui/viewer/file/thumbnail_widget.dart';
import 'package:photos/ui/viewer/gallery/empty_state.dart';
import 'package:photos/utils/data_util.dart';
import 'package:photos/utils/delete_file_util.dart';
import 'package:photos/utils/navigation_util.dart';
import 'package:photos/utils/toast_util.dart';

class DeduplicatePage extends StatefulWidget {
  final List<DuplicateFiles> duplicates;

  const DeduplicatePage(this.duplicates, {Key key}) : super(key: key);

  @override
  State<DeduplicatePage> createState() => _DeduplicatePageState();
}

class _DeduplicatePageState extends State<DeduplicatePage> {
  static const kHeaderRowCount = 3;
  static final kDeleteIconOverlay = Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.6),
        ],
        stops: const [0.75, 1],
      ),
    ),
    child: Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 4),
        child: Icon(
          Icons.delete_forever,
          size: 18,
          color: Colors.red[700],
        ),
      ),
    ),
  );

  final Set<File> _selectedFiles = <File>{};
  final Map<int, int> _fileSizeMap = {};
  List<DuplicateFiles> _duplicates;
  bool _shouldClubByCaptureTime = true;

  SortKey sortKey = SortKey.size;

  @override
  void initState() {
    super.initState();
    _duplicates =
        DeduplicationService.instance.clubDuplicatesByTime(widget.duplicates);
    _selectAllFilesButFirst();
    showToast(context, "Long-press on an item to view in full-screen");
  }

  void _selectAllFilesButFirst() {
    _selectedFiles.clear();
    for (final duplicate in _duplicates) {
      for (int index = 0; index < duplicate.files.length; index++) {
        // Select all items but the first
        if (index != 0) {
          _selectedFiles.add(duplicate.files[index]);
        }
        // Maintain a map of fileID to fileSize for quick "space freed" computation
        _fileSizeMap[duplicate.files[index].uploadedFileID] = duplicate.size;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _sortDuplicates();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Deduplicate Files"),
      ),
      body: _getBody(),
    );
  }

  void _sortDuplicates() {
    _duplicates.sort((first, second) {
      if (sortKey == SortKey.size) {
        final aSize = first.files.length * first.size;
        final bSize = second.files.length * second.size;
        return bSize - aSize;
      } else if (sortKey == SortKey.count) {
        return second.files.length - first.files.length;
      } else {
        return second.files.first.creationTime - first.files.first.creationTime;
      }
    });
  }

  Widget _getBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (index == 0) {
                return _getHeader();
              } else if (index == 1) {
                return _getClubbingConfig();
              } else if (index == 2) {
                if (_duplicates.isNotEmpty) {
                  return _getSortMenu();
                } else {
                  return const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: EmptyState(),
                  );
                }
              }
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: _getGridView(
                  _duplicates[index - kHeaderRowCount],
                  index - kHeaderRowCount,
                ),
              );
            },
            itemCount: _duplicates.length + kHeaderRowCount,
            shrinkWrap: true,
          ),
        ),
        _selectedFiles.isEmpty ? Container() : _getDeleteButton(),
      ],
    );
  }

  Padding _getHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Following files were clubbed based on their sizes" +
                ((_shouldClubByCaptureTime ? " and capture times." : ".")),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          const Padding(
            padding: EdgeInsets.all(2),
          ),
          Text(
            "Please review and delete the items you believe are duplicates.",
            style: Theme.of(context).textTheme.subtitle2,
          ),
          const Padding(
            padding: EdgeInsets.all(12),
          ),
          const Divider(
            height: 0,
          ),
        ],
      ),
    );
  }

  Widget _getClubbingConfig() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: CheckboxListTile(
        value: _shouldClubByCaptureTime,
        onChanged: (value) {
          _shouldClubByCaptureTime = value;
          _resetEntriesAndSelection();
          setState(() {});
        },
        title: const Text("Club by capture time"),
      ),
    );
  }

  void _resetEntriesAndSelection() {
    if (_shouldClubByCaptureTime) {
      _duplicates =
          DeduplicationService.instance.clubDuplicatesByTime(_duplicates);
    } else {
      _duplicates = widget.duplicates;
    }
    _selectAllFilesButFirst();
  }

  Widget _getSortMenu() {
    Text sortOptionText(SortKey key) {
      String text = key.toString();
      switch (key) {
        case SortKey.count:
          text = "Count";
          break;
        case SortKey.size:
          text = "Total size";
          break;
        case SortKey.time:
          text = "Time";
          break;
      }
      return Text(
        text,
        style: Theme.of(context).textTheme.subtitle1.copyWith(
              fontSize: 14,
              color: Theme.of(context).iconTheme.color.withOpacity(0.7),
            ),
      );
    }

    return Row(
      // h4ck to align PopupMenuItems to end
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(),
        PopupMenuButton(
          initialValue: sortKey?.index ?? 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                sortOptionText(sortKey),
                const Padding(padding: EdgeInsets.only(left: 4)),
                Icon(
                  Icons.sort,
                  color: Theme.of(context).colorScheme.iconColor,
                  size: 20,
                ),
              ],
            ),
          ),
          onSelected: (int index) {
            setState(() {
              sortKey = SortKey.values[index];
            });
          },
          itemBuilder: (context) {
            return List.generate(SortKey.values.length, (index) {
              return PopupMenuItem(
                value: index,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: sortOptionText(SortKey.values[index]),
                ),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _getDeleteButton() {
    String text;
    if (_selectedFiles.length == 1) {
      text = "Delete 1 item";
    } else {
      text = "Delete " + _selectedFiles.length.toString() + " items";
    }
    int size = 0;
    for (final file in _selectedFiles) {
      size += _fileSizeMap[file.uploadedFileID];
    }
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: TextButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Padding(padding: EdgeInsets.all(2)),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.all(2)),
              Text(
                formatBytes(size),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Padding(padding: EdgeInsets.all(2)),
            ],
          ),
          onPressed: () async {
            await deleteFilesFromRemoteOnly(context, _selectedFiles.toList());
            Bus.instance.fire(UserDetailsChangedEvent());
            Navigator.of(context)
                .pop(DeduplicationResult(_selectedFiles.length, size));
          },
        ),
      ),
    );
  }

  Widget _getGridView(DuplicateFiles duplicates, int itemIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
          child: Text(
            duplicates.files.length.toString() +
                " files, " +
                formatBytes(duplicates.size) +
                " each",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // to disable GridView's scrolling
          itemBuilder: (context, index) {
            return _buildFile(context, duplicates.files[index], itemIndex);
          },
          itemCount: duplicates.files.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          padding: const EdgeInsets.all(0),
        ),
      ],
    );
  }

  Widget _buildFile(BuildContext context, File file, int index) {
    return GestureDetector(
      onTap: () {
        if (_selectedFiles.contains(file)) {
          _selectedFiles.remove(file);
        } else {
          _selectedFiles.add(file);
        }
        setState(() {});
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        final files = _duplicates[index].files;
        routeToPage(
          context,
          DetailPage(
            DetailPageConfiguration(
              files,
              null,
              files.indexOf(file),
              "deduplicate_",
              mode: DetailPageMode.minimalistic,
            ),
          ),
          forceCustomPageRoute: true,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          border: _selectedFiles.contains(file)
              ? Border.all(
                  width: 3,
                  color: Colors.red[700],
                )
              : null,
        ),
        child: Stack(
          children: [
            Hero(
              tag: "deduplicate_" + file.tag(),
              child: ThumbnailWidget(
                file,
                diskLoadDeferDuration: kThumbnailDiskLoadDeferDuration,
                serverLoadDeferDuration: kThumbnailServerLoadDeferDuration,
                shouldShowLivePhotoOverlay: true,
                key: Key("deduplicate_" + file.tag()),
              ),
            ),
            _selectedFiles.contains(file) ? kDeleteIconOverlay : Container(),
          ],
        ),
      ),
    );
  }
}

enum SortKey {
  size,
  count,
  time,
}

class DeduplicationResult {
  final int count;
  final int size;

  DeduplicationResult(this.count, this.size);
}
