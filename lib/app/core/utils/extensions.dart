extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  bool get isStrongPassword {
    // Check for minimum length
    if (length < 8) return false;

    // Check for uppercase
    if (!contains(RegExp(r'[A-Z]'))) return false;

    // Check for lowercase
    if (!contains(RegExp(r'[a-z]'))) return false;

    // Check for numbers
    if (!contains(RegExp(r'[0-9]'))) return false;

    // Check for special characters
    if (!contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }
}

extension ListExtensions<T> on List<T> {
  List<T> addBetween(T separator) {
    if (length <= 1) return this;

    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

extension DateTimeExtensions on DateTime {
  String get formattedDate {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return day == yesterday.day &&
        month == yesterday.month &&
        year == yesterday.year;
  }
}