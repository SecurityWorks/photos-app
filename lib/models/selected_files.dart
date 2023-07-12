import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:photos/core/event_bus.dart';
import 'package:photos/events/clear_selections_event.dart';
import 'package:photos/models/file.dart';

class SelectedFiles extends ChangeNotifier {
  final files = <File>{};
  final lastSelections = <File>{};

  void toggleSelection(File file) {
    // To handle the cases, where the file might have changed due to upload
    // or any other update, using file.generatedID to track if this file was already
    // selected or not
    final File? alreadySelected = files.firstWhereOrNull(
      (element) => _isMatch(file, element),
    );
    if (alreadySelected != null) {
      files.remove(alreadySelected);
    } else {
      files.add(file);
    }
    lastSelections.clear();
    lastSelections.add(file);
    notifyListeners();
  }

  void toggleGroupSelection(Set<File> filesToToggle) {
    if (files.containsAll(filesToToggle)) {
      unSelectAll(filesToToggle);
    } else {
      selectAll(filesToToggle);
    }
  }

  void selectAll(Set<File> selectedFiles) {
    files.addAll(selectedFiles);
    lastSelections.clear();
    lastSelections.addAll(selectedFiles);
    notifyListeners();
  }

  void unSelectAll(Set<File> selectedFiles, {bool skipNotify = false}) {
    files.removeWhere((file) => selectedFiles.contains(file));
    lastSelections.clear();
    if (!skipNotify) {
      notifyListeners();
    }
  }

  bool isFileSelected(File file) {
    final File? alreadySelected = files.firstWhereOrNull(
      (element) => _isMatch(file, element),
    );
    return alreadySelected != null;
  }

  bool isPartOfLastSelected(File file) {
    final File? matchedFile = lastSelections.firstWhereOrNull(
      (element) => _isMatch(file, element),
    );
    return matchedFile != null;
  }

  bool _isMatch(File first, File second) {
    if (first.generatedID != null && second.generatedID != null) {
      if (first.generatedID == second.generatedID) {
        return true;
      }
    } else if (first.uploadedFileID != null && second.uploadedFileID != null) {
      return first.uploadedFileID == second.uploadedFileID;
    }
    return false;
  }

  void clearAll() {
    Bus.instance.fire(ClearSelectionsEvent());
    lastSelections.addAll(files);
    files.clear();
    notifyListeners();
  }

  /// Retains only the files that are present in the [images] set. Takes the
  /// intersection of the two sets.
  void filesToRetain(Set<File> images) {
    files.retainAll(images);
    notifyListeners();
  }
}
