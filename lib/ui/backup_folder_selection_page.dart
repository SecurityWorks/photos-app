import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/db/files_db.dart';
import 'package:photos/events/backup_folders_updated_event.dart';
import 'package:photos/models/file.dart';
import 'package:photos/ui/common/custom_color_scheme.dart';
import 'package:photos/ui/common_elements.dart';
import 'package:photos/ui/loading_widget.dart';
import 'package:photos/ui/thumbnail_widget.dart';

class BackupFolderSelectionPage extends StatefulWidget {
  final bool shouldSelectAll;
  final String buttonText;

  const BackupFolderSelectionPage({
    @required this.buttonText,
    this.shouldSelectAll = false,
    Key key,
  }) : super(key: key);

  @override
  _BackupFolderSelectionPageState createState() =>
      _BackupFolderSelectionPageState();
}

class _BackupFolderSelectionPageState extends State<BackupFolderSelectionPage> {
  final Set<String> _allFolders = <String>{};
  Set<String> _selectedFolders = <String>{};
  List<File> _latestFiles;
  Map<String, int> _itemCount;

  @override
  void initState() {
    _selectedFolders = Configuration.instance.getPathsToBackUp();
    FilesDB.instance.getLatestLocalFiles().then((files) async {
      _itemCount = await FilesDB.instance.getFileCountInDeviceFolders();
      setState(() {
        _latestFiles = files;
        _latestFiles.sort((first, second) {
          return first.deviceFolder
              .toLowerCase()
              .compareTo(second.deviceFolder.toLowerCase());
        });
        for (final file in _latestFiles) {
          _allFolders.add(file.deviceFolder);
        }
        if (widget.shouldSelectAll) {
          _selectedFolders.addAll(_allFolders);
        }
        _selectedFolders.removeWhere((folder) => !_allFolders.contains(folder));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            child: Text(
              'Select folders for backup',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Inter-Bold',
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 48),
            child: Text(
              "Selected folders will be end-to-end encrypted and backed up",
              style: Theme.of(context).textTheme.caption.copyWith(height: 1.3),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          _latestFiles == null
              ? Container()
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 64, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedFolders.length == _allFolders.length
                            ? "Unselect all"
                            : "Select all",
                        textAlign: TextAlign.right,
                        style: Theme.of(context)
                            .textTheme
                            .overline
                            .copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  onTap: () {
                    final hasSelectedAll =
                        _selectedFolders.length == _allFolders.length;
                    // Flip selection
                    if (hasSelectedAll) {
                      _selectedFolders.clear();
                    } else {
                      _selectedFolders.addAll(_allFolders);
                    }
                    _latestFiles.sort((first, second) {
                      return first.deviceFolder
                          .toLowerCase()
                          .compareTo(second.deviceFolder.toLowerCase());
                    });
                    setState(() {});
                  }),
          Expanded(child: _getFolders()),
          Padding(
            padding: EdgeInsets.all(20),
          ),
          Hero(
            tag: "select_folders",
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  left: 24, right: 24, bottom: Platform.isIOS ? 60 : 32),
              child: OutlinedButton(
                child: Text(widget.buttonText),
                onPressed: _selectedFolders.isEmpty
                    ? null
                    : () async {
                        await Configuration.instance
                            .setPathsToBackUp(_selectedFolders);
                        Bus.instance.fire(BackupFoldersUpdatedEvent());
                        Navigator.of(context).pop();
                      },
                // padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFolders() {
    if (_latestFiles == null) {
      return loadWidget;
    }
    _sortFiles();
    final scrollController = ScrollController();
    return Container(
      padding: EdgeInsets.only(left: 20, right: 24),
      child: Scrollbar(
        controller: scrollController,
        isAlwaysShown: true,
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ImplicitlyAnimatedReorderableList<File>(
            controller: scrollController,
            items: _latestFiles,
            areItemsTheSame: (oldItem, newItem) =>
                oldItem.deviceFolder == newItem.deviceFolder,
            onReorderFinished: (item, from, to, newItems) {
              setState(() {
                _latestFiles
                  ..clear()
                  ..addAll(newItems);
              });
            },
            itemBuilder: (context, itemAnimation, file, index) {
              return Reorderable(
                key: ValueKey(file),
                builder: (context, dragAnimation, inDrag) {
                  final t = dragAnimation.value;
                  final elevation = lerpDouble(0, 8, t);
                  final themeColor = Theme.of(context).colorScheme.onSurface;
                  final color =
                      Color.lerp(themeColor, themeColor.withOpacity(0.8), t);
                  return SizeFadeTransition(
                    sizeFraction: 0.7,
                    curve: Curves.easeInOut,
                    animation: itemAnimation,
                    child: Material(
                      color: color,
                      elevation: elevation,
                      type: MaterialType.transparency,
                      child: _getFileItem(file),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getFileItem(File file) {
    final isSelected = _selectedFolders.contains(file.deviceFolder);
    return Padding(
      padding: const EdgeInsets.only(bottom: 1, right: 1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.boxUnSelectColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.boxSelectColor
              : Theme.of(context).colorScheme.boxUnSelectColor,
        ),
        padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.green,
                    activeColor: Colors.white,
                    value: isSelected,
                    onChanged: (value) {
                      if (value) {
                        _selectedFolders.add(file.deviceFolder);
                      } else {
                        _selectedFolders.remove(file.deviceFolder);
                      }
                      setState(() {});
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 180),
                        child: Text(
                          file.deviceFolder,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Inter-Medium',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 2)),
                      Text(
                        _itemCount[file.deviceFolder].toString() +
                            " item" +
                            (_itemCount[file.deviceFolder] == 1 ? "" : "s"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _getThumbnail(file),
            ],
          ),
          onTap: () {
            final value = !_selectedFolders.contains(file.deviceFolder);
            if (value) {
              _selectedFolders.add(file.deviceFolder);
            } else {
              _selectedFolders.remove(file.deviceFolder);
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  void _sortFiles() {
    _latestFiles.sort((first, second) {
      if (_selectedFolders.contains(first.deviceFolder) &&
          _selectedFolders.contains(second.deviceFolder)) {
        return first.deviceFolder
            .toLowerCase()
            .compareTo(second.deviceFolder.toLowerCase());
      } else if (_selectedFolders.contains(first.deviceFolder)) {
        return -1;
      } else if (_selectedFolders.contains(second.deviceFolder)) {
        return 1;
      }
      return first.deviceFolder
          .toLowerCase()
          .compareTo(second.deviceFolder.toLowerCase());
    });
  }

  Widget _getThumbnail(File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: SizedBox(
        child: ThumbnailWidget(
          file,
          shouldShowSyncStatus: false,
          key: Key("backup_selection_widget" + file.tag()),
        ),
        height: 88,
        width: 88,
      ),
    );
  }
}
