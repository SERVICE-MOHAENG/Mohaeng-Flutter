import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_survey_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class CreateRoadmapSurveyUsecase {
  const CreateRoadmapSurveyUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<RoadmapSurveyResponse> call({
    required RoadmapSurveyRequest request,
  }) {
    return _repository.createSurvey(request: request);
  }
}
