import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class GetRoadmapItineraryStatusUsecase {
  const GetRoadmapItineraryStatusUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<RoadmapItineraryStatusResponse> call({
    required String jobId,
  }) {
    return _repository.getItineraryStatus(jobId: jobId);
  }
}
