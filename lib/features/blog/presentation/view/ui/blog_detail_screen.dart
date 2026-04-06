import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_detail_models.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_providers.dart';

class BlogDetailScreen extends ConsumerStatefulWidget {
  const BlogDetailScreen({super.key, required this.blogId});

  final String blogId;

  @override
  ConsumerState<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends ConsumerState<BlogDetailScreen> {
  int _currentImagePage = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blogDetailViewModelProvider(widget.blogId));
    final blog = state.blog;

    return MLayout(
      backgroundColor: MColor.gray50,
      body: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            if (state.isLoading && blog == null) {
              return _buildLoading();
            }

            if (state.errorMessage != null && blog == null) {
              return _buildError(
                message: state.errorMessage!,
                onRetry: _reload,
              );
            }

            if (blog == null) {
              return _buildError(
                message: '블로그 상세를 찾을 수 없어요.',
                onRetry: _reload,
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(context, blog, isLiking: state.isLiking),
                    Transform.translate(
                      offset: Offset(0, -28.h),
                      child: _buildContentPanel(blog, isLiking: state.isLiking),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _reload() {
    return ref.read(blogDetailViewModelProvider(widget.blogId).notifier).load();
  }

  Widget _buildLoading() {
    return Center(
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: MColor.primary500,
        ),
      ),
    );
  }

  Widget _buildError({required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 28.sp,
              color: MColor.gray300,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: MTextStyles.labelM.copyWith(color: MColor.gray500),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: MColor.primary500,
                foregroundColor: MColor.white100,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '다시 시도',
                style: MTextStyles.labelB.copyWith(color: MColor.white100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    BlogDetailResponse blog, {
    required bool isLiking,
  }) {
    final imageUrls = blog.displayImageUrls;
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 380.h,
      child: Stack(
        children: [
          Positioned.fill(child: _buildImagePager(blog)),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.48),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset + 6.h,
            left: 16.w,
            child: _buildOverlayIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            top: topInset + 8.h,
            right: 16.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrls.length > 1) ...[
                  _buildHeroBadge(
                    '${_currentImagePage + 1}/${imageUrls.length}',
                  ),
                  SizedBox(width: 8.w),
                ],
                _buildOverlayLikeButton(blog, isLiking: isLiking),
              ],
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 32.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildHeroBadge(blog.isPublic == true ? '공개 글' : '비공개 글'),
                    _buildHeroBadge('조회 ${(blog.viewCount ?? 0)}'),
                    _buildHeroBadge('좋아요 ${(blog.likeCount ?? 0)}'),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  _displayTitle(blog),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.titleB.copyWith(
                    color: MColor.white100,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  _buildAuthorAndDate(blog),
                  style: MTextStyles.labelM.copyWith(
                    color: MColor.white100.withValues(alpha: 0.92),
                  ),
                ),
                if (blog.tags.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: blog.tags
                        .where((tag) => tag.trim().isNotEmpty)
                        .take(4)
                        .map(_buildHeroTag)
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePager(BlogDetailResponse blog) {
    final imageUrls = blog.displayImageUrls;
    if (imageUrls.isEmpty) {
      return _buildFallbackImage(height: 380.h);
    }

    return PageView.builder(
      itemCount: imageUrls.length,
      onPageChanged: (index) {
        if (_currentImagePage == index) return;
        setState(() {
          _currentImagePage = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildNetworkImage(imageUrls[index], height: 380.h);
      },
    );
  }

  Widget _buildContentPanel(BlogDetailResponse blog, {required bool isLiking}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(blog, isLiking: isLiking),
            SizedBox(height: 22.h),
            _buildSectionTitle('여행 기록'),
            SizedBox(height: 10.h),
            Text(
              _displayContent(blog),
              style: MTextStyles.bodyM.copyWith(
                color: MColor.gray700,
                height: 1.75,
              ),
            ),
            if (blog.displayImageUrls.length > 1) ...[
              SizedBox(height: 28.h),
              _buildSectionTitle('추가 사진'),
              SizedBox(height: 12.h),
              SizedBox(
                height: 88.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: blog.displayImageUrls.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentImagePage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 88.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? MColor.primary500
                              : MColor.gray100,
                          width: isSelected ? 2.w : 1.w,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildNetworkImage(
                        blog.displayImageUrls[index],
                        height: 88.h,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BlogDetailResponse blog, {required bool isLiking}) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: '상태',
            value: blog.isPublic == true ? '공개' : '비공개',
            icon: blog.isPublic == true
                ? Icons.public_rounded
                : Icons.lock_outline_rounded,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildInfoCard(
            title: '좋아요',
            value: '${blog.likeCount ?? 0}',
            icon: blog.isLiked == true
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: blog.isLiked == true
                ? const Color(0xFFFF4C78)
                : MColor.gray400,
            onTap: isLiking ? null : _toggleLike,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildInfoCard(
            title: '조회수',
            value: '${blog.viewCount ?? 0}',
            icon: Icons.remove_red_eye_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: MColor.gray50,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16.sp, color: iconColor ?? MColor.gray500),
              SizedBox(height: 12.h),
              Text(
                title,
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: MTextStyles.lBodyB.copyWith(color: MColor.gray800),
    );
  }

  Widget _buildOverlayIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.7),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 36.w,
              height: 36.w,
              child: Icon(icon, size: 18.sp, color: MColor.gray800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          color: Colors.white.withValues(alpha: 0.18),
          child: Text(
            text,
            style: MTextStyles.labelM.copyWith(color: MColor.white100),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTag(String tag) {
    final normalized = tag.startsWith('#') ? tag : '#$tag';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        normalized,
        style: MTextStyles.labelM.copyWith(color: MColor.white100),
      ),
    );
  }

  Widget _buildOverlayLikeButton(
    BlogDetailResponse blog, {
    required bool isLiking,
  }) {
    final isLiked = blog.isLiked ?? false;
    final color = isLiked ? const Color(0xFFFF4C78) : MColor.gray800;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.7),
          child: InkWell(
            onTap: isLiking ? null : _toggleLike,
            child: SizedBox(
              width: 36.w,
              height: 36.w,
              child: isLiking
                  ? Padding(
                      padding: EdgeInsets.all(9.r),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18.sp,
                      color: color,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl, {required double height}) {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasScheme) {
      return _buildFallbackImage(height: height);
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackImage(height: height);
      },
    );
  }

  Widget _buildFallbackImage({required double height}) {
    return Image.asset(
      MImages.sibuya,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
    );
  }

  String _displayTitle(BlogDetailResponse blog) {
    final title = blog.title?.trim() ?? '';
    return title.isEmpty ? '여행 기록' : title;
  }

  String _displayContent(BlogDetailResponse blog) {
    final content = blog.content?.trim() ?? '';
    return content.isEmpty ? '작성된 내용이 없어요.' : content;
  }

  String _buildAuthorAndDate(BlogDetailResponse blog) {
    final author = (blog.userName?.trim().isNotEmpty ?? false)
        ? blog.userName!.trim()
        : '작성자 정보 없음';
    final date = _formatDateTime(blog.createdAt);
    if (date == null) return author;
    return '$author · $date';
  }

  String? _formatDateTime(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final local = parsed.toLocal();
    return '${local.year}.${_twoDigits(local.month)}.${_twoDigits(local.day)} ${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Future<void> _toggleLike() async {
    try {
      await ref
          .read(blogDetailViewModelProvider(widget.blogId).notifier)
          .toggleLike();
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        ApiError(:final message) => message,
        _ => '블로그 좋아요를 처리하지 못했어요.',
      };
      showAppSnackBar(
        context,
        message: message,
        fallbackMessage: '블로그 좋아요를 처리하지 못했어요.',
      );
    }
  }
}
