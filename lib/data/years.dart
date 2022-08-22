import 'package:photos/utils/date_time_util.dart';

class YearsData {
  final List<YearData> yearsData = [];
  YearsData._privateConstructor() {
    for (int year = 1970; year <= currentYear; year++) {
      yearsData.add(
        YearData(year.toString(), [
          DateTime(year).microsecondsSinceEpoch,
          DateTime(year + 1).microsecondsSinceEpoch,
        ]),
      );
    }
  }
  static final YearsData instance = YearsData._privateConstructor();
}

class YearData {
  final String year;
  final List<int> duration;
  YearData(this.year, this.duration);
}
