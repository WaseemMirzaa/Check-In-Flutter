import 'package:intl/intl.dart';

class DateTimeUtils {
  static String time24to12(String time) {
    final DateFormat inputFormat = DateFormat('HH:mm');
    final DateFormat outputFormat = DateFormat('h:mm a');
    final DateTime dateTime = inputFormat.parse(time);
    final String formattedTime = outputFormat.format(dateTime);
    return formattedTime;
  }
}
