import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';

abstract class BlogRepository {
  Future<String> uploadImage({required String filePath});

  Future<CreatedBlogResponse> createBlog({required CreateBlogRequest request});
}
