import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';

void main() {
  test('parses main blogs mainpage response schema', () {
    final response = BlogsResponse.fromJson({
      'blogs': [
        {
          'id': 'blog-1',
          'title': '도쿄에서 보낸 하루',
          'content': '시부야와 하라주쿠를 걸은 여행기',
          'imageUrl': 'https://example.com/blog.jpg',
          'isPublic': true,
          'viewCount': 120,
          'likeCount': 12,
          'createdAt': '2026-03-18T05:51:52.094Z',
          'updatedAt': '2026-03-18T05:51:52.094Z',
          'userId': 'user-1',
          'userName': '모행',
          'isLiked': true,
        },
      ],
      'page': 1,
      'limit': 6,
      'total': 1,
      'totalPages': 1,
    });

    expect(response.blogs, hasLength(1));

    final blog = response.blogs.first;
    expect(blog.id, 'blog-1');
    expect(blog.title, '도쿄에서 보낸 하루');
    expect(blog.description, '시부야와 하라주쿠를 걸은 여행기');
    expect(blog.thumbnailUrl, 'https://example.com/blog.jpg');
    expect(blog.isPublic, isTrue);
    expect(blog.viewCount, 120);
    expect(blog.likeCount, 12);
    expect(blog.userId, 'user-1');
    expect(blog.userName, '모행');
    expect(blog.isLiked, isTrue);
  });
}
