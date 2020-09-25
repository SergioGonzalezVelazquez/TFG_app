/// https://stackoverflow.com/questions/54391477/check-if-datetime-variable-is-today-tomorrow-or-yesterday
bool isToday(DateTime dateTime) {
  final now = DateTime.now();
  return now.day == dateTime.day &&
      now.month == dateTime.month &&
      now.year == dateTime.year;
}

bool isYesterday(DateTime dateTime) {
  final yesterday = DateTime.now().subtract(Duration(days: 1));
  return yesterday.day == dateTime.day &&
      yesterday.month == dateTime.month &&
      yesterday.year == dateTime.year;
}
