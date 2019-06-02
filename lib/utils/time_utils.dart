String timeToString(DateTime time) {
  String str = "";
  str += time.day.toString();
  str += ". ";
  str += monthFromInt(time.month);
  if (time.year != DateTime.now().year) {
    str += " ";
    str += time.year.toString();
  }
  str += " ";
  if (time.hour < 10) str += "0";
  str += time.hour.toString();
  str += ":";
  if (time.minute < 10) str += "0";
  str += time.minute.toString();
  return str;
}

String monthFromInt(int index) {
  assert(index >= 0 && index <= 12);
  switch (index) {
    case 1:
      return "Jan.";
    case 2:
      return "Feb.";
    case 3:
      return "Mar.";
    case 4:
      return "Apr.";
    case 5:
      return "May.";
    case 6:
      return "Jun.";
    case 7:
      return "Jul.";
    case 8:
      return "Aug.";
    case 9:
      return "Sept.";
    case 10:
      return "Oct.";
    case 11:
      return "Nov.";
    case 12:
      return "Dec.";
  }
  return "";
}
