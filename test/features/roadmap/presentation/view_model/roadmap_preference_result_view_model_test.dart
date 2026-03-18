import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_chat_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_survey_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_preference_job_result.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_preference_me_result.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_preference_result_view_model.dart';

void main() {
  group('RoadmapPreferenceResultViewModel', () {
    test('toggleLike turns false into true and increases like count', () async {
      final repository = _FakeRoadmapRepository(
        meResults: const <RoadmapPreferenceResultItem>[
          RoadmapPreferenceResultItem(
            regionName: 'BARCELONA',
            likeCount: 0,
            isLiked: false,
          ),
        ],
      );
      final viewModel = RoadmapPreferenceResultViewModel(
        GetRoadmapPreferenceJobResultUsecase(repository),
        GetRoadmapPreferenceMeResultUsecase(repository),
      );

      await viewModel.loadMine();
      viewModel.toggleLike(viewModel.state.items.single);

      expect(viewModel.state.items.single.isLiked, isTrue);
      expect(viewModel.state.items.single.likeCount, 1);
    });

    test(
      'toggleLike can turn true back to false without going negative',
      () async {
        final repository = _FakeRoadmapRepository(
          meResults: const <RoadmapPreferenceResultItem>[
            RoadmapPreferenceResultItem(
              regionName: 'LISBON',
              likeCount: 0,
              isLiked: true,
            ),
          ],
        );
        final viewModel = RoadmapPreferenceResultViewModel(
          GetRoadmapPreferenceJobResultUsecase(repository),
          GetRoadmapPreferenceMeResultUsecase(repository),
        );

        await viewModel.loadMine();
        viewModel.toggleLike(viewModel.state.items.single);

        expect(viewModel.state.items.single.isLiked, isFalse);
        expect(viewModel.state.items.single.likeCount, 0);
      },
    );
  });
}

class _FakeRoadmapRepository implements RoadmapRepository {
  const _FakeRoadmapRepository({
    this.jobResults = const <RoadmapPreferenceResultItem>[],
    this.meResults = const <RoadmapPreferenceResultItem>[],
  });

  final List<RoadmapPreferenceResultItem> jobResults;
  final List<RoadmapPreferenceResultItem> meResults;

  @override
  Future<RoadmapSurveyResponse> createSurvey({
    required RoadmapSurveyRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapItineraryResponse> createItinerary({
    required RoadmapItineraryRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapItineraryStatusResponse> getItineraryStatus({
    required String jobId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapItineraryResultResponse> getItineraryResult({
    required String jobId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapChatResponse> sendRoadmapChat({
    required String itineraryId,
    required RoadmapChatRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapModificationStatusResponse> getModificationStatus({
    required String jobId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<RoadmapPreferenceResultItem>> getPreferenceJobResult({
    required String jobId,
  }) async {
    return jobResults;
  }

  @override
  Future<List<RoadmapPreferenceResultItem>> getPreferenceMeResult() async {
    return meResults;
  }
}
