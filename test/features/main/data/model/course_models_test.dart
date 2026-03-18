import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';

void main() {
  test('parses updated main courses response schema', () {
    final response = CoursesResponse.fromJson({
      'courses': [
        {
          'id': 'course-1',
          'title': '시부야 밤거리',
          'description': '도쿄의 밤거리를 걷는 당일 코스',
          'imageUrl': 'https://example.com/course.jpg',
          'viewCount': 123,
          'nights': 0,
          'days': 1,
          'likeCount': 7,
          'modificationCount': 2,
          'userId': 'user-1',
          'userName': '모행',
          'countries': ['JP'],
          'regionNames': ['시부야'],
          'hashTags': ['당일치기', '친구'],
          'places': [
            {
              'id': 'place-course-1',
              'visitOrder': 1,
              'dayNumber': 1,
              'memo': '저녁 방문 추천',
              'placeId': 'place-1',
              'placeName': '시부야 스카이',
              'placeDescription': '도심 전망 포인트',
              'latitude': 35.658034,
              'longitude': 139.701636,
              'address': '시부야구 2-24-12',
              'placeUrl': 'https://example.com/place',
            },
          ],
          'isPublic': true,
          'isCompleted': true,
          'createdAt': '2026-03-18T05:13:45.315Z',
          'updatedAt': '2026-03-18T05:13:45.315Z',
          'sourceCourseId': 'source-1',
          'isLiked': true,
        },
      ],
      'page': 1,
      'limit': 10,
      'total': 1,
      'totalPages': 1,
    });

    expect(response.courses, hasLength(1));

    final course = response.courses.first;
    expect(course.id, 'course-1');
    expect(course.description, '도쿄의 밤거리를 걷는 당일 코스');
    expect(course.thumbnailUrl, 'https://example.com/course.jpg');
    expect(course.nights, 0);
    expect(course.days, 1);
    expect(course.modificationCount, 2);
    expect(course.userName, '모행');
    expect(course.countries, ['JP']);
    expect(course.regionNames, ['시부야']);
    expect(course.tags, ['당일치기', '친구']);
    expect(course.isPublic, isTrue);
    expect(course.isCompleted, isTrue);
    expect(course.sourceCourseId, 'source-1');

    final place = course.places.first;
    expect(place.id, 'place-course-1');
    expect(place.placeId, 'place-1');
    expect(place.name, '시부야 스카이');
    expect(place.description, '도심 전망 포인트');
    expect(place.order, 1);
    expect(place.dayNumber, 1);
    expect(place.memo, '저녁 방문 추천');
    expect(place.placeUrl, 'https://example.com/place');
  });
}
