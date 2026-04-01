import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_region_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/exception/country_region_exception.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_country_regions.dart';

@immutable
class CountryRegionsState {
  const CountryRegionsState({
    this.isLoading = false,
    this.countryName,
    this.errorMessage,
    this.regions = const <CountryRegionModel>[],
  });

  final bool isLoading;
  final String? countryName;
  final String? errorMessage;
  final List<CountryRegionModel> regions;

  CountryRegionsState copyWith({
    bool? isLoading,
    String? countryName,
    bool clearCountryName = false,
    String? errorMessage,
    bool clearError = false,
    List<CountryRegionModel>? regions,
  }) {
    return CountryRegionsState(
      isLoading: isLoading ?? this.isLoading,
      countryName: clearCountryName ? null : (countryName ?? this.countryName),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      regions: regions ?? this.regions,
    );
  }
}

class CountryRegionsViewModel extends StateNotifier<CountryRegionsState> {
  CountryRegionsViewModel(this._getCountryRegionsUsecase)
    : super(const CountryRegionsState());

  final GetCountryRegionsUsecase _getCountryRegionsUsecase;
  int _requestSerial = 0;

  Future<bool> load(String countryName) async {
    final normalizedCountryName = countryName.trim();
    if (normalizedCountryName.isEmpty) {
      state = state.copyWith(errorMessage: '국가명을 입력해 주세요.');
      return false;
    }

    final requestSerial = ++_requestSerial;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      countryName: normalizedCountryName,
      regions: const <CountryRegionModel>[],
    );

    try {
      final response = await _getCountryRegionsUsecase(
        countryName: normalizedCountryName,
      );
      if (requestSerial != _requestSerial) return false;
      state = state.copyWith(
        isLoading: false,
        countryName: normalizedCountryName,
        clearError: true,
        regions: response.regions,
      );
      return true;
    } on CountryNotFoundException catch (error) {
      if (requestSerial != _requestSerial) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        regions: const <CountryRegionModel>[],
      );
      return false;
    } on CountryRegionNetworkException catch (error) {
      if (requestSerial != _requestSerial) return false;
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } on CountryRegionException catch (error) {
      if (requestSerial != _requestSerial) return false;
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (_) {
      if (requestSerial != _requestSerial) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: '도시 목록을 불러오지 못했어요.',
      );
      return false;
    }
  }
}
