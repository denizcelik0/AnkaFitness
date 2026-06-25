import 'package:intl/intl.dart';

/// Tarih formatlama yardımcıları.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dayMonthYear = DateFormat('dd MMMM yyyy', 'tr_TR');
  static final DateFormat _shortDate = DateFormat('dd.MM.yyyy', 'tr_TR');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

  /// "25 Haziran 2025" formatında tarih döndürür.
  static String formatLong(DateTime date) => _dayMonthYear.format(date);

  /// "25.06.2025" formatında kısa tarih döndürür.
  static String formatShort(DateTime date) => _shortDate.format(date);

  /// "25.06.2025 14:30" formatında tarih ve saat döndürür.
  static String formatDateTime(DateTime date) => _dateTime.format(date);

  /// İki tarih arasındaki kalan gün sayısını hesaplar.
  /// Negatif değer, süre dolmuş demektir.
  static int remainingDays(DateTime endDate) {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  /// Üyeliğin aktif olup olmadığını kontrol eder.
  static bool isMembershipActive(DateTime endDate) {
    return endDate.isAfter(DateTime.now());
  }
}
