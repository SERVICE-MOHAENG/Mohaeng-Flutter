import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class BudgetRangeState {
  const BudgetRangeState({this.min = '', this.max = ''});

  final String min;
  final String max;

  BudgetRangeState copyWith({String? min, String? max}) {
    return BudgetRangeState(min: min ?? this.min, max: max ?? this.max);
  }
}

class BudgetRangeViewModel extends StateNotifier<BudgetRangeState> {
  BudgetRangeViewModel() : super(const BudgetRangeState());

  void setMin(String value) => state = state.copyWith(min: value);

  void setMax(String value) => state = state.copyWith(max: value);
}
