import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_detail_models.dart';

abstract class BlogRepository {
  Future<String> uploadImage({required String filePath});

  Future<CreatedBlogResponse> createBlog({required CreateBlogRequest request});

  Future<BlogDetailResponse> getBlogDetail({required String id});

  Future<void> addBlogLike({required String id});

  Future<void> removeBlogLike({required String id});
}
