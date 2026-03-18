import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/roadmap_modification_request_limit.dart';

void main() {
  group('roadmap modification request limit', () {
    test('reports remaining requests within limit', () {
      expect(remainingRoadmapModificationRequests(0), 5);
      expect(remainingRoadmapModificationRequests(3), 2);
    });

    test('detects when limit is reached', () {
      expect(hasReachedRoadmapModificationRequestLimit(4), isFalse);
      expect(hasReachedRoadmapModificationRequestLimit(5), isTrue);
      expect(hasReachedRoadmapModificationRequestLimit(6), isTrue);
    });

    test('caps increment at the limit', () {
      expect(incrementRoadmapModificationRequestCount(0), 1);
      expect(incrementRoadmapModificationRequestCount(4), 5);
      expect(incrementRoadmapModificationRequestCount(5), 5);
    });
  });
}
