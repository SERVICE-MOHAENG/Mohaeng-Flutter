import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';

void main() {
  test('parses mainpage courses response schema', () {
    final response = CoursesResponse.fromJson({
      'courses': [
        {
          'id': 'course-1',
          'title': '시부야 밤거리',
          'start_date': '2026-03-18',
          'end_date': '2026-03-20',
          'tags': ['당일치기', '친구'],
          'like_count': 7,
          'is_liked': true,
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
    expect(course.title, '시부야 밤거리');
    expect(course.startDate, '2026-03-18');
    expect(course.endDate, '2026-03-20');
    expect(course.tags, ['당일치기', '친구']);
    expect(course.likeCount, 7);
    expect(course.isLiked, isTrue);
    expect(course.thumbnailUrl, isNull);
    expect(course.places, isEmpty);
  });
}
