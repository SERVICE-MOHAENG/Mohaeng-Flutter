import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class RegionSelectState {
  const RegionSelectState({this.selectedCities = const []});

  final List<String> selectedCities;

  RegionSelectState copyWith({List<String>? selectedCities}) {
    return RegionSelectState(
      selectedCities: selectedCities ?? this.selectedCities,
    );
  }
}

class RegionSelectViewModel extends StateNotifier<RegionSelectState> {
  RegionSelectViewModel({List<String>? initialCities})
    : super(RegionSelectState(selectedCities: initialCities ?? const []));

  void addCity(String rawCity) {
    final city = rawCity.trim();
    if (city.isEmpty) return;
    if (state.selectedCities.contains(city)) return;
    state = state.copyWith(selectedCities: [...state.selectedCities, city]);
  }

  void removeCityAt(int index) {
    if (index < 0 || index >= state.selectedCities.length) return;
    final next = [...state.selectedCities]..removeAt(index);
    state = state.copyWith(selectedCities: next);
  }
}
