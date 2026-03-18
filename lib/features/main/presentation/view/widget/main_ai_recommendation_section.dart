import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_preference_result_view_model.dart';

class MainAiRecommendationSection extends StatelessWidget {
  const MainAiRecommendationSection({
    super.key,
    required this.recommendationState,
    required this.onToggleLike,
  });

  final RoadmapPreferenceResultState recommendationState;
  final ValueChanged<RoadmapPreferenceResultItem> onToggleLike;

  @override
  Widget build(BuildContext context) {
    final showEmptyMessage =
        !recommendationState.isLoading &&
        recommendationState.errorMessage == null &&
        recommendationState.items.isEmpty;

    if (showEmptyMessage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          SizedBox(height: 8.h),
          _buildSubtitle(),
          SizedBox(height: 20.h),
          SizedBox(
            height: 190.h,
            child: Center(
              child: Text(
                '추천 여행지가 없습니다.',
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
            ),
          ),
        ],
      );
    }

    final destinations = _resolveAiDestinations(recommendationState.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        SizedBox(height: 8.h),
        _buildSubtitle(),
        SizedBox(height: 20.h),
        SizedBox(
          height: 190.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return _buildDestinationCard(
                title: destination.title,
                subtitle: destination.subtitle,
                imageUrl: destination.imageUrl,
                fallbackImagePath: destination.fallbackImagePath,
                likeCount: destination.likeCount,
                isLiked: destination.isLiked,
                onToggleLike: () => onToggleLike(destination.item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text.rich(
      TextSpan(
        style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
        children: [
          const TextSpan(text: '모행 AI가 사용자에게\n'),
          TextSpan(
            text: '딱!',
            style: MTextStyles.lBodyB.copyWith(color: MColor.primary500),
          ),
          const TextSpan(text: ' 맞는 여행지를 찾았어요!'),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '모행의 AI가 사용자님의 정보를 기반으로\n추천하는 해외 여행지입니다!',
      style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
    );
  }

  List<_AiDestinationCardData> _resolveAiDestinations(
    List<RoadmapPreferenceResultItem> items,
  ) {
    final resolved = <_AiDestinationCardData>[];
    final maxCount = items.length > 4 ? 4 : items.length;
    for (int i = 0; i < maxCount; i++) {
      final item = items[i];
      final regionName = item.regionName.trim();
      final description = _extractReadableText(item.description);
      final imageUrl = _extractImageUrl(item.imageUrl);

      resolved.add(
        _AiDestinationCardData(
          item: item,
          title: regionName.isEmpty ? '추천 여행지' : regionName,
          subtitle: description ?? '모행 AI가 추천한 여행지입니다.',
          imageUrl: imageUrl,
          fallbackImagePath: MImages.sibuya,
          likeCount: item.likeCount ?? 0,
          isLiked: item.isLiked ?? false,
        ),
      );
    }

    return resolved;
  }

  String? _extractReadableText(Object? value) {
    if (value == null) return null;

    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty || normalized == '{}' || normalized == '[]') {
        return null;
      }
      return normalized;
    }

    if (value is List) {
      for (final item in value) {
        final nested = _extractReadableText(item);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    if (value is Map) {
      const preferredKeys = <String>[
        'description',
        'summary',
        'content',
        'text',
        'value',
        'message',
        'url',
      ];

      for (final key in preferredKeys) {
        final nested = _extractReadableText(value[key]);
        if (nested != null) {
          return nested;
        }
      }

      for (final nestedValue in value.values) {
        final nested = _extractReadableText(nestedValue);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    final normalized = value.toString().trim();
    if (normalized.isEmpty || normalized == '{}' || normalized == '[]') {
      return null;
    }
    return normalized;
  }

  String? _extractImageUrl(Object? value) {
    final candidate = _extractReadableText(value);
    if (candidate == null || candidate.isEmpty) return null;

    final uri = Uri.tryParse(candidate);
    if (uri == null || !uri.hasScheme) return null;
    return candidate;
  }

  Widget _buildDestinationCard({
    required String title,
    required String subtitle,
    required String fallbackImagePath,
    required int likeCount,
    required bool isLiked,
    required VoidCallback onToggleLike,
    String? imageUrl,
  }) {
    return Container(
      width: 155.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _buildDestinationImage(
              imageUrl: imageUrl,
              fallbackImagePath: fallbackImagePath,
            ),
          ),
          Positioned(
            top: 10.h,
            right: 10.w,
            child: _buildLikeBadge(
              likeCount: likeCount,
              isLiked: isLiked,
              onTap: onToggleLike,
            ),
          ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 14.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MTextStyles.lBodyB.copyWith(color: Colors.white),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GmarketSansMedium',
                    fontSize: 7.sp,
                    color: MColor.white100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeBadge({
    required int likeCount,
    required bool isLiked,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: MColor.white100.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(width: 0.4.w, color: MColor.gray200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isLiked ? const Color(0xFFFF4C78) : MColor.gray400,
                size: 14.w,
              ),
              SizedBox(width: 4.w),
              Text(
                _formatLikeCount(likeCount),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                  color: MColor.gray700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationImage({
    required String fallbackImagePath,
    String? imageUrl,
  }) {
    final uri = imageUrl == null ? null : Uri.tryParse(imageUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = imageUrl!;
      return Image.network(
        url,
        fit: BoxFit.fill,
        width: 160.w,
        height: 194.h,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackImagePath,
          fit: BoxFit.fill,
          width: 160.w,
          height: 194.h,
        ),
      );
    }

    return Image.asset(
      fallbackImagePath,
      fit: BoxFit.fill,
      width: 160.w,
      height: 194.h,
    );
  }
}

@immutable
class _AiDestinationCardData {
  const _AiDestinationCardData({
    required this.item,
    required this.title,
    required this.subtitle,
    required this.fallbackImagePath,
    required this.likeCount,
    required this.isLiked,
    this.imageUrl,
  });

  final RoadmapPreferenceResultItem item;
  final String title;
  final String subtitle;
  final String fallbackImagePath;
  final int likeCount;
  final bool isLiked;
  final String? imageUrl;
}

String _formatLikeCount(int value) {
  final safeValue = value < 0 ? 0 : value;
  final raw = safeValue.toString();
  return raw.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
