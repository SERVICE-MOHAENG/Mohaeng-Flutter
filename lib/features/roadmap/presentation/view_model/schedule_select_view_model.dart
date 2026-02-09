import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ScheduleSelectState {
  const ScheduleSelectState({
    required this.displayMonth,
    this.startDate,
    this.endDate,
    this.selectedCountries = const ['브라질', '일본', '독일'],
  });

  final DateTime displayMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedCountries;

  ScheduleSelectState copyWith({
    DateTime? displayMonth,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedCountries,
  }) {
    return ScheduleSelectState(
      displayMonth: displayMonth ?? this.displayMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCountries: selectedCountries ?? this.selectedCountries,
    );
  }
}

class ScheduleSelectViewModel extends StateNotifier<ScheduleSelectState> {
  ScheduleSelectViewModel()
    : super(
        ScheduleSelectState(
          displayMonth: DateTime(DateTime.now().year, DateTime.now().month),
        ),
      );

  void goToPreviousMonth() {
    state = state.copyWith(
      displayMonth: DateTime(
        state.displayMonth.year,
        state.displayMonth.month - 1,
      ),
      startDate: null,
      endDate: null,
    );
  }

  void goToNextMonth() {
    state = state.copyWith(
      displayMonth: DateTime(
        state.displayMonth.year,
        state.displayMonth.month + 1,
      ),
      startDate: null,
      endDate: null,
    );
  }

  void selectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final start = state.startDate;
    final end = state.endDate;

    if (start == null || end != null) {
      state = state.copyWith(startDate: normalized, endDate: null);
      return;
    }

    if (normalized.isBefore(start)) {
      state = state.copyWith(startDate: normalized, endDate: null);
      return;
    }

    state = state.copyWith(endDate: normalized);
  }

  bool get isValidSelection {
    final start = state.startDate;
    final end = state.endDate;
    if (start == null || end == null) return false;
    final days = end.difference(start).inDays;
    return days >= 0 && days <= 7;
  }

  bool isInRange(DateTime date) {
    final start = state.startDate;
    if (start == null) return false;
    final end = state.endDate;
    if (end == null) return _isSameDay(start, date);

    final normalized = DateTime(date.year, date.month, date.day);
    final isAfterStart =
        normalized.isAfter(start) || _isSameDay(normalized, start);
    final isBeforeEnd = normalized.isBefore(end) || _isSameDay(normalized, end);
    return isAfterStart && isBeforeEnd;
  }

  bool isSameDay(DateTime? a, DateTime b) => _isSameDay(a, b);

  static bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
