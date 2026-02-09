import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AdditionalRequestState {
  const AdditionalRequestState({this.request = ''});

  final String request;

  AdditionalRequestState copyWith({String? request}) {
    return AdditionalRequestState(request: request ?? this.request);
  }
}

class AdditionalRequestViewModel extends StateNotifier<AdditionalRequestState> {
  AdditionalRequestViewModel() : super(const AdditionalRequestState());

  void setRequest(String value) {
    state = state.copyWith(request: value);
  }
}
