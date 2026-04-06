import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_providers.dart';

class BlogLikeButton extends ConsumerStatefulWidget {
  const BlogLikeButton({
    super.key,
    required this.blogId,
    required this.initialIsLiked,
    required this.initialLikeCount,
    this.iconSize,
    this.textStyle,
    this.inactiveColor,
    this.activeColor = const Color(0xFFFF4C78),
    this.spacing,
  });

  final String blogId;
  final bool initialIsLiked;
  final int initialLikeCount;
  final double? iconSize;
  final TextStyle? textStyle;
  final Color? inactiveColor;
  final Color activeColor;
  final double? spacing;

  @override
  ConsumerState<BlogLikeButton> createState() => _BlogLikeButtonState();
}

class _BlogLikeButtonState extends ConsumerState<BlogLikeButton> {
  late bool _isLiked = widget.initialIsLiked;
  late int _likeCount = widget.initialLikeCount;
  bool _isSubmitting = false;

  @override
  void didUpdateWidget(covariant BlogLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSubmitting) return;

    if (oldWidget.blogId != widget.blogId ||
        oldWidget.initialIsLiked != widget.initialIsLiked ||
        oldWidget.initialLikeCount != widget.initialLikeCount) {
      _isLiked = widget.initialIsLiked;
      _likeCount = widget.initialLikeCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = widget.inactiveColor ?? MColor.gray300;
    final iconColor = _isLiked ? widget.activeColor : inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: _isSubmitting ? null : _toggleLike,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSubmitting)
              SizedBox(
                width: widget.iconSize ?? 14.w,
                height: widget.iconSize ?? 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: iconColor,
                ),
              )
            else
              Icon(
                _isLiked ? Icons.favorite_rounded : Icons.favorite_border,
                size: widget.iconSize ?? 14.w,
                color: iconColor,
              ),
            SizedBox(width: widget.spacing ?? 4.w),
            Text(
              '$_likeCount',
              style:
                  widget.textStyle ??
                  MTextStyles.sLabelM.copyWith(color: MColor.gray400),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    final blogId = widget.blogId.trim();
    if (blogId.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isLiked) {
        await ref.read(removeBlogLikeUsecaseProvider).call(id: blogId);
      } else {
        await ref.read(addBlogLikeUsecaseProvider).call(id: blogId);
      }

      if (!mounted) return;
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked
            ? _likeCount + 1
            : (_likeCount > 0 ? _likeCount - 1 : 0);
      });
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        ApiError(:final message) => message,
        _ => _isLiked ? '좋아요를 취소하지 못했어요.' : '좋아요를 추가하지 못했어요.',
      };
      showAppSnackBar(
        context,
        message: message,
        fallbackMessage: _isLiked ? '좋아요를 취소하지 못했어요.' : '좋아요를 추가하지 못했어요.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
