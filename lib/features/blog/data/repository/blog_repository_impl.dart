import 'package:mohaeng_app_service/features/blog/data/datasource/blog_remote_datasource.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_detail_models.dart';
import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';

class BlogRepositoryImpl implements BlogRepository {
  BlogRepositoryImpl({BlogRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? BlogRemoteDataSource();

  final BlogRemoteDataSource _remoteDataSource;

  @override
  Future<String> uploadImage({required String filePath}) {
    return _remoteDataSource.uploadImage(filePath: filePath);
  }

  @override
  Future<CreatedBlogResponse> createBlog({required CreateBlogRequest request}) {
    return _remoteDataSource.createBlog(request: request);
  }

  @override
  Future<BlogDetailResponse> getBlogDetail({required String id}) {
    return _remoteDataSource.getBlogDetail(id: id);
  }

  @override
  Future<void> addBlogLike({required String id}) {
    return _remoteDataSource.addBlogLike(id: id);
  }

  @override
  Future<void> removeBlogLike({required String id}) {
    return _remoteDataSource.removeBlogLike(id: id);
  }
}
