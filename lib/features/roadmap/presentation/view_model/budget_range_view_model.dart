import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

@immutable
class BudgetRangeState {
  const BudgetRangeState({this.range});

  final BudgetRange? range;

  BudgetRangeState copyWith({BudgetRange? range}) {
    return BudgetRangeState(range: range ?? this.range);
  }
}

class BudgetRangeViewModel extends StateNotifier<BudgetRangeState> {
  BudgetRangeViewModel() : super(const BudgetRangeState());

  void setRange(BudgetRange value) => state = state.copyWith(range: value);
}
