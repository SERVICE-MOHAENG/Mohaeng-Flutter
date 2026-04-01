import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_blogs_view_model.dart';

class MainBlogSection extends StatelessWidget {
  const MainBlogSection({
    super.key,
    required this.blogsState,
    required this.onRetry,
    this.onWrite,
  });

  final MainBlogsState blogsState;
  final VoidCallback onRetry;
  final VoidCallback? onWrite;

  @override
  Widget build(BuildContext context) {
    final blogContent = _buildMainBlogsContent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '여행 블로그 보기',
                style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
              ),
            ),
            if (onWrite != null)
              TextButton(
                onPressed: onWrite,
                style: TextButton.styleFrom(
                  foregroundColor: MColor.primary500,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '블로그 작성하러 가기',
                  style: MTextStyles.labelB.copyWith(color: MColor.primary500),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          '생생한 여행 후기를 볼 수 있어요!',
          style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
        ),
        SizedBox(height: 16.h),
        blogContent,
      ],
    );
  }

  Widget _buildMainBlogsContent() {
    if (blogsState.isLoading) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: MColor.primary500,
            ),
          ),
        ),
      );
    }

    final errorMessage = blogsState.errorMessage;
    if (errorMessage != null) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: MColor.primary500,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    '다시 시도',
                    style: MTextStyles.labelB.copyWith(color: MColor.white100),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (blogsState.blogs.isEmpty) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: Text(
            '아직 표시할 블로그가 없어요.',
            style: MTextStyles.labelM.copyWith(color: MColor.gray500),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < blogsState.blogs.length; i++) ...[
          _buildBlogListItem(blog: blogsState.blogs[i]),
          if (i != blogsState.blogs.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildBlogListItem({required BlogResponse blog}) {
    final title = (blog.title ?? '여행 블로그').trim();
    final description = (blog.description ?? '').trim();
    final tags = blog.tags
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.startsWith('#') ? e : '#$e')
        .toList(growable: false);
    final likeCountText = (blog.likeCount ?? 0).toString();
    final fallbackTags = <String>[
      if (blog.isPublic != null) blog.isPublic! ? '#공개' : '#비공개',
      '#여행블로그',
    ];

    return _buildBlogItem(
      title: title,
      description: description.isEmpty ? '내용이 없어요.' : description,
      tags: tags.isEmpty ? fallbackTags : tags,
      likeCountText: likeCountText,
      isLiked: blog.isLiked ?? false,
      thumbnailUrl: blog.thumbnailUrl,
    );
  }

  Widget _buildBlogItem({
    required String title,
    required String description,
    required List<String> tags,
    required String likeCountText,
    required bool isLiked,
    String? thumbnailUrl,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: _buildBlogThumbnail(thumbnailUrl),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 6.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    for (int i = 0; i < tags.length; i++) ...[
                      _buildBlogTag(tags[i]),
                      if (i != tags.length - 1) SizedBox(width: 6.w),
                    ],
                    const Spacer(),
                    Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border,
                      size: 14.w,
                      color: isLiked ? const Color(0xFFFF4C78) : MColor.gray300,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      likeCountText,
                      style: MTextStyles.sLabelM.copyWith(
                        color: MColor.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogThumbnail(String? thumbnailUrl) {
    final uri = thumbnailUrl == null ? null : Uri.tryParse(thumbnailUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = thumbnailUrl!;
      return Image.network(
        url,
        width: 75.w,
        height: 75.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          MImages.sibuya,
          width: 75.w,
          height: 75.w,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      MImages.sibuya,
      width: 75.w,
      height: 75.w,
      fit: BoxFit.cover,
    );
  }

  Widget _buildBlogTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(width: 0.5.w, color: MColor.primary500),
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
      ),
    );
  }
}
