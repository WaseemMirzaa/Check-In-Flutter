import 'package:intl/intl.dart';

class DateTimeUtils {
  static String time24to12(String time) {
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateFormat outputFormat = DateFormat('h:mm a');
    final DateTime dateTime = inputFormat.parse(time);
    final String formattedTime = outputFormat.format(dateTime);
    return formattedTime;
  }

//  static String formatTimestamp(Timestamp timestamp) {
//   DateTime dateTime = timestamp.toDate();
//   DateTime now = DateTime.now();

//   if (dateTime.day == now.day &&
//       dateTime.month == now.month &&
//       dateTime.year == now.year) {
//     return 'Today';
//   } else if (dateTime.day == now.day + 1 &&
//       dateTime.month == now.month &&
//       dateTime.year == now.year) {
//     return 'Tomorrow';
//   } else {
//     return DateFormat('MMMM d, y').format(dateTime);
//   }}
}
