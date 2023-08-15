import "package:photos/models/file.dart";
import "package:photos/models/file_type.dart";
import "package:photos/services/filter/filter.dart";

class TypeFilter extends Filter {
  final FileType type;
  final bool reverse;

  TypeFilter(
    this.type, {
    this.reverse = false,
  });

  @override
  bool filter(File file) {
    return reverse ? file.fileType != type : file.fileType == type;
  }
}
