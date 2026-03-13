extension DateOnlyX on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool sameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
