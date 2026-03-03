import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _dateValueUnset = Object();

@immutable
class ScheduleSelectState {
  const ScheduleSelectState({
    required this.displayMonth,
    this.startDate,
    this.endDate,
    this.selectedCountries = const [],
    this.selectedCity = '',
    this.cityDateRanges = const {},
  });

  final DateTime displayMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedCountries;
  final String selectedCity;
  final Map<String, DateTimeRange> cityDateRanges;

  ScheduleSelectState copyWith({
    DateTime? displayMonth,
    Object? startDate = _dateValueUnset,
    Object? endDate = _dateValueUnset,
    List<String>? selectedCountries,
    String? selectedCity,
    Map<String, DateTimeRange>? cityDateRanges,
  }) {
    return ScheduleSelectState(
      displayMonth: displayMonth ?? this.displayMonth,
      startDate: identical(startDate, _dateValueUnset)
          ? this.startDate
          : startDate as DateTime?,
      endDate: identical(endDate, _dateValueUnset)
          ? this.endDate
          : endDate as DateTime?,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      selectedCity: selectedCity ?? this.selectedCity,
      cityDateRanges: cityDateRanges ?? this.cityDateRanges,
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

  void setSelectedCity(String city, {bool resetSelection = false}) {
    if (city.isEmpty) {
      state = state.copyWith(selectedCity: '', startDate: null, endDate: null);
      return;
    }
    if (state.selectedCity == city) return;
    final existing = resetSelection ? null : state.cityDateRanges[city];
    state = state.copyWith(
      selectedCity: city,
      startDate: existing?.start,
      endDate: existing?.end,
    );
  }

  void ensureSelectedCity(List<String> cities) {
    if (cities.isEmpty) {
      state = state.copyWith(selectedCity: '', startDate: null, endDate: null);
      return;
    }
    if (cities.contains(state.selectedCity)) return;
    setSelectedCity(cities.first);
  }

  void goToPreviousMonth() {
    state = state.copyWith(
      displayMonth: DateTime(
        state.displayMonth.year,
        state.displayMonth.month - 1,
      ),
    );
  }

  void goToNextMonth() {
    state = state.copyWith(
      displayMonth: DateTime(
        state.displayMonth.year,
        state.displayMonth.month + 1,
      ),
    );
  }

  bool selectDate(DateTime date, {List<String> cities = const []}) {
    if (state.selectedCity.isEmpty) return false;
    final normalized = DateTime(date.year, date.month, date.day);
    final start = state.startDate;
    final end = state.endDate;

    if (start == null || end != null) {
      final nextRanges = Map<String, DateTimeRange>.from(state.cityDateRanges)
        ..remove(state.selectedCity);
      state = state.copyWith(
        startDate: normalized,
        endDate: null,
        cityDateRanges: nextRanges,
      );
      return false;
    }

    if (normalized.isBefore(start)) {
      final nextRanges = Map<String, DateTimeRange>.from(state.cityDateRanges)
        ..remove(state.selectedCity);
      state = state.copyWith(
        startDate: normalized,
        endDate: null,
        cityDateRanges: nextRanges,
      );
      return false;
    }

    final nextRange = DateTimeRange(start: start, end: normalized);
    final nextRanges = Map<String, DateTimeRange>.from(state.cityDateRanges)
      ..[state.selectedCity] = nextRange;

    final nextIndex = cities.indexOf(state.selectedCity);
    if (cities.isNotEmpty && nextIndex != -1 && nextIndex < cities.length - 1) {
      final nextCity = cities[nextIndex + 1];
      final clearedRanges = Map<String, DateTimeRange>.from(nextRanges)
        ..remove(nextCity);
      state = state.copyWith(
        selectedCity: nextCity,
        startDate: null,
        endDate: null,
        cityDateRanges: clearedRanges,
      );
    } else {
      state = state.copyWith(endDate: normalized, cityDateRanges: nextRanges);
    }

    return true;
  }

  bool get isValidSelection {
    if (state.selectedCity.isEmpty) return false;
    final start = state.startDate;
    final end = state.endDate;
    if (start == null || end == null) return false;
    final days = end.difference(start).inDays;
    return days >= 0 && days <= 7;
  }

  bool isAllCitiesSelected(List<String> cities) {
    if (cities.isEmpty) return false;
    for (final city in cities) {
      final range = state.cityDateRanges[city];
      if (range == null) return false;
      final days = range.end.difference(range.start).inDays;
      if (days < 0 || days > 7) return false;
    }
    return true;
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
