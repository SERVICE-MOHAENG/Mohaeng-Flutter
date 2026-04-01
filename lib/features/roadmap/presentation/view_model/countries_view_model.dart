import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/exception/country_exception.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_countries.dart';

@immutable
class CountriesState {
  const CountriesState({
    this.isLoading = false,
    this.errorMessage,
    this.countries = const <CountryModel>[],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<CountryModel> countries;

  CountriesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<CountryModel>? countries,
  }) {
    return CountriesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      countries: countries ?? this.countries,
    );
  }
}

class CountriesViewModel extends StateNotifier<CountriesState> {
  CountriesViewModel(this._getCountriesUsecase)
    : super(const CountriesState());

  final GetCountriesUsecase _getCountriesUsecase;

  Future<bool> load() async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _getCountriesUsecase();
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        countries: response.countries,
      );
      return true;
    } on CountryException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        countries: const <CountryModel>[],
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '국가 목록을 불러오지 못했어요.',
        countries: const <CountryModel>[],
      );
      return false;
    }
  }
}
