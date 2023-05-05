import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

const Set<int> monthWith31Days = {1, 3, 5, 7, 8, 10, 12};
const Set<int> monthWith30Days = {4, 6, 9, 11};
Map<int, String> _months = {
  1: "Jan",
  2: "Feb",
  3: "Mar",
  4: "Apr",
  5: "May",
  6: "Jun",
  7: "Jul",
  8: "Aug",
  9: "Sep",
  10: "Oct",
  11: "Nov",
  12: "Dec",
};

Map<int, String> _fullMonths = {
  1: "January",
  2: "February",
  3: "March",
  4: "April",
  5: "May",
  6: "June",
  7: "July",
  8: "August",
  9: "September",
  10: "October",
  11: "November",
  12: "December",
};

Map<int, String> _days = {
  1: "Mon",
  2: "Tue",
  3: "Wed",
  4: "Thu",
  5: "Fri",
  6: "Sat",
  7: "Sun",
};

final currentYear = DateTime.now().year;
const searchStartYear = 1970;

//Jun 2022
String getMonthAndYear(DateTime dateTime) {
  return _months[dateTime.month]! + " " + dateTime.year.toString();
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

bool areFromSameDay(int firstCreationTime, int secondCreationTime) {
  final firstDate = DateTime.fromMicrosecondsSinceEpoch(firstCreationTime);
  final secondDate = DateTime.fromMicrosecondsSinceEpoch(secondCreationTime);
  return firstDate.year == secondDate.year &&
      firstDate.month == secondDate.month &&
      firstDate.day == secondDate.day;
}

// Create link default names:
// Same day: "Dec 19, 2022"
// Same month: "Dec 19 - 22, 2022"
// Base case: "Dec 19, 2022 - Jan 7, 2023"
String getNameForDateRange(int firstCreationTime, int secondCreationTime) {
  final startTime = DateTime.fromMicrosecondsSinceEpoch(firstCreationTime);
  final endTime = DateTime.fromMicrosecondsSinceEpoch(secondCreationTime);
  // different year
  if (startTime.year != endTime.year) {
    return "${_months[startTime.month]!} ${startTime.day}, ${startTime.year} - "
        "${_months[endTime.month]!} ${endTime.day}, ${endTime.year}";
  }
  // same year, diff month
  if (startTime.month != endTime.month) {
    return "${_months[startTime.month]!} ${startTime.day} - "
        "${_months[endTime.month]!} ${endTime.day}, ${endTime.year}";
  }
  // same month and year, diff day
  if (startTime.day != endTime.day) {
    return "${_months[startTime.month]!} ${startTime.day} - "
        "${_months[endTime.month]!} ${endTime.day}, ${endTime.year}";
  }
  // same day
  return "${_months[endTime.month]!} ${endTime.day}, ${endTime.year}";
}

String getDay(DateTime dateTime) {
  return _days[dateTime.weekday]!;
}

String getMonth(DateTime dateTime) {
  return _months[dateTime.month]!;
}

String getFullMonth(DateTime dateTime) {
  return _fullMonths[dateTime.month]!;
}

String getAbbreviationOfYear(DateTime dateTime) {
  return (dateTime.year % 100).toString();
}

//14:32
String getTime(DateTime dateTime) {
  final hours = dateTime.hour > 9
      ? dateTime.hour.toString()
      : "0" + dateTime.hour.toString();
  final minutes = dateTime.minute > 9
      ? dateTime.minute.toString()
      : "0" + dateTime.minute.toString();
  return hours + ":" + minutes;
}

//11:22 AM
String getTimeIn12hrFormat(DateTime dateTime) {
  return DateFormat.jm().format(dateTime);
}

//Thu, Jun 30, 2022 - 14:32
String getFormattedTime(DateTime dateTime) {
  return getDay(dateTime) +
      ", " +
      getMonth(dateTime) +
      " " +
      dateTime.day.toString() +
      ", " +
      dateTime.year.toString() +
      " - " +
      getTime(dateTime);
}

//30 Jun'22
String getFormattedDate(DateTime dateTime) {
  return dateTime.day.toString() +
      " " +
      getMonth(dateTime) +
      "'" +
      getAbbreviationOfYear(dateTime);
}

String daysLeft(int futureTime) {
  final int daysLeft = ((futureTime - DateTime.now().microsecondsSinceEpoch) /
          Duration.microsecondsPerDay)
      .ceil();
  return '$daysLeft day' + (daysLeft <= 1 ? "" : "s");
}

String formatDuration(Duration position) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  final minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString = hours >= 10
      ? '$hours'
      : hours == 0
          ? '00'
          : '0$hours';

  final minutesString = minutes >= 10
      ? '$minutes'
      : minutes == 0
          ? '00'
          : '0$minutes';

  final secondsString = seconds >= 10
      ? '$seconds'
      : seconds == 0
          ? '00'
          : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';

  return formattedTime;
}

bool isLeapYear(DateTime dateTime) {
  final year = dateTime.year;
  if (year % 4 == 0) {
    if (year % 100 == 0) {
      if (year % 400 == 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  } else {
    return false;
  }
}

String secondsToHHMMSS(int value) {
  int h, m, s;
  h = value ~/ 3600;
  m = ((value - h * 3600)) ~/ 60;
  s = value - (h * 3600) - (m * 60);
  final String hourLeft =
      h.toString().length < 2 ? "0" + h.toString() : h.toString();

  final String minuteLeft =
      m.toString().length < 2 ? "0" + m.toString() : m.toString();

  final String secondsLeft =
      s.toString().length < 2 ? "0" + s.toString() : s.toString();

  final String result = "$hourLeft:$minuteLeft:$secondsLeft";

  return result;
}

bool isValidDate({
  required int day,
  required int month,
  required int year,
}) {
  if (day < 0 || day > 31 || month < 0 || month > 12 || year < 0) {
    return false;
  }
  if (monthWith30Days.contains(month) && day > 30) {
    return false;
  }
  if (month == 2) {
    if (day > 29) {
      return false;
    }
    if (day == 29 && year % 4 != 0) {
      return false;
    }
  }
  return true;
}

final RegExp exp = RegExp('[\\.A-Za-z]*');

DateTime? parseDateTimeFromFileNameV2(
  String fileName, {
  /* to avoid parsing incorrect date time from the filename, the max and min
    year limits the chances of parsing incorrect date times
    */
  int minYear = 1990,
  int? maxYear,
}) {
  // add next year to avoid corner cases for 31st Dec
  maxYear ??= currentYear + 1;
  String val = fileName.replaceAll(exp, '');
  if (val.isNotEmpty && !isNumeric(val[0])) {
    val = val.substring(1, val.length);
  }
  if (val.isNotEmpty && !isNumeric(val[val.length - 1])) {
    val = val.substring(0, val.length - 1);
  }
  final int countOfHyphen = val.split("-").length - 1;
  final int countUnderScore = val.split("_").length - 1;
  String valForParser = val;
  if (countOfHyphen == 1) {
    valForParser = val.replaceAll("-", "T");
  } else if (countUnderScore == 1 || countUnderScore == 2) {
    valForParser = val.replaceFirst("_", "T");
    if (countUnderScore == 2) {
      valForParser = valForParser.split("_")[0];
    }
  } else if (countOfHyphen == 2) {
    valForParser = val.replaceAll(".", ":");
  } else if (countOfHyphen == 6) {
    final splits = val.split("-");
    valForParser =
        "${splits[0]}${splits[1]}${splits[2]}T${splits[3]}${splits[4]}${splits[5]}";
  }
  final result = DateTime.tryParse(valForParser);
  if (kDebugMode && result == null) {
    debugPrint("Failed to parse $fileName dateTime from $valForParser");
  }
  if (result != null && result.year >= minYear && result.year <= maxYear) {
    return result;
  }
  return null;
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
