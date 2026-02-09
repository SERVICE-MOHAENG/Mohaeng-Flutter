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
  RegionSelectViewModel()
    : super(
        const RegionSelectState(
          selectedCities: ['알래스카, 동-국립공원', '워싱턴디시', '뉴욕'],
        ),
      );

  void removeCityAt(int index) {
    if (index < 0 || index >= state.selectedCities.length) return;
    final next = [...state.selectedCities]..removeAt(index);
    state = state.copyWith(selectedCities: next);
  }
}
