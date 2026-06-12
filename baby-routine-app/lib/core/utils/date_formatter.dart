import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'pt_BR').format(dateTime);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat("MMMM 'de' yyyy", 'pt_BR').format(date);
  }

  static String formatWeekday(DateTime date) {
    return DateFormat('EEEE', 'pt_BR').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'pt_BR').format(date);
    } else {
      return formatDate(date);
    }
  }
}
