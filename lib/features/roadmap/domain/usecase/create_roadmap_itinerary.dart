import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class CreateRoadmapItineraryUsecase {
  const CreateRoadmapItineraryUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<RoadmapItineraryResponse> call({
    required RoadmapItineraryRequest request,
  }) {
    return _repository.createItinerary(request: request);
  }
}
