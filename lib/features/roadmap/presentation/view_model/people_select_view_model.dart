import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PeopleSelectState {
  const PeopleSelectState({this.count = 1});

  final int count;

  PeopleSelectState copyWith({int? count}) {
    return PeopleSelectState(count: count ?? this.count);
  }
}

class PeopleSelectViewModel extends StateNotifier<PeopleSelectState> {
  PeopleSelectViewModel() : super(const PeopleSelectState());

  void increment() {
    if (state.count >= 99) return;
    state = state.copyWith(count: state.count + 1);
  }

  void decrement() {
    if (state.count <= 1) return;
    state = state.copyWith(count: state.count - 1);
  }
}
