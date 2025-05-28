import 'package:intl/intl.dart';

class ThaiDateTime {
  static const shortDayNameList = [
    'จ.',
    'อ.',
    'พ.',
    'พฤ.',
    'ศ.',
    'ส.',
    'อา.',
  ];
  static const shortMonthNameList = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  final DateTime _dateTime;

  ThaiDateTime(this._dateTime);

  String formatDate() {
    var dayName = shortDayNameList[_dateTime.weekday - 1];
    var monthName = shortMonthNameList[_dateTime.month - 1];
    var year = (_dateTime.year + 543) % 100;
    var format = DateFormat('$dayName d $monthName $year');
    return format.format(_dateTime.toUtc());
  }

  String formatTime() {
    var format = DateFormat('HH:mm น.');
    return format.format(_dateTime.toUtc());
  }
}
