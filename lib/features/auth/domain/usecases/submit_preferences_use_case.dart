import 'package:mohaeng_app_service/features/auth/domain/entities/preference_job.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class SubmitPreferencesUseCase {
  const SubmitPreferencesUseCase(this._repository);

  final AuthRepository _repository;

  Future<PreferenceJob> call({
    required String weather,
    required String travelRange,
    required String travelStyle,
    required List<String> foodPersonality,
    required List<String> mainInterests,
    required String budgetLevel,
  }) {
    return _repository.submitPreferences(
      weather: weather,
      travelRange: travelRange,
      travelStyle: travelStyle,
      foodPersonality: foodPersonality,
      mainInterests: mainInterests,
      budgetLevel: budgetLevel,
    );
  }
}
