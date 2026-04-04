import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_providers.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_write_view_model.dart';

class BlogWriteScreen extends ConsumerStatefulWidget {
  const BlogWriteScreen({super.key, this.travelCourseId});

  final String? travelCourseId;

  @override
  ConsumerState<BlogWriteScreen> createState() => _BlogWriteScreenState();
}

class _BlogWriteScreenState extends ConsumerState<BlogWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _tags = <String>[];
  File? _selectedImageFile;

  static const Color _accentColor = Color(0xFF00CCFF);
  static const Color _titleHintColor = Color(0xFFD4D4D8);
  static const Color _contentHintColor = Color(0xFFE4E4E7);
  static const Color _tagHintColor = Color(0xFFA1A1AA);

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final String tag = value.trim().replaceAll('#', '');
    if (tag.isEmpty) return;

    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }

    _tagController.clear();
  }

  Future<void> _pickAndUploadPhoto() async {
    final BlogWriteState writeState = ref.read(blogWriteViewModelProvider);
    if (writeState.isUploadingImage) return;

    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (pickedFile == null) return;

    final File localFile = File(pickedFile.path);
    if (!mounted) return;

    setState(() {
      _selectedImageFile = localFile;
    });

    try {
      await ref
          .read(blogWriteViewModelProvider.notifier)
          .uploadImage(filePath: localFile.path);
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: '사진을 추가했어요.',
        fallbackMessage: '사진 업로드에 실패했어요.',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedImageFile = null;
      });
      ref.read(blogWriteViewModelProvider.notifier).clearUploadedImages();
      showAppSnackBar(
        context,
        message: '사진 업로드에 실패했어요.',
        fallbackMessage: '사진 업로드에 실패했어요.',
      );
    }
  }

  Future<void> _publishBlog() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final writeState = ref.read(blogWriteViewModelProvider);
    final String? travelCourseId = _resolveTravelCourseId();

    if (title.isEmpty) {
      showAppSnackBar(
        context,
        message: '제목을 입력해주세요.',
        fallbackMessage: '제목이 비어 있어요.',
      );
      return;
    }

    if (content.isEmpty) {
      showAppSnackBar(
        context,
        message: '내용을 입력해주세요.',
        fallbackMessage: '내용이 비어 있어요.',
      );
      return;
    }

    if (travelCourseId == null) {
      showAppSnackBar(
        context,
        message: '연결할 여행 코스 정보가 없어요.',
        fallbackMessage: 'travelCourseId가 필요해요.',
      );
      return;
    }

    if (_selectedImageFile != null && writeState.uploadedImageUrls.isEmpty) {
      showAppSnackBar(
        context,
        message: '사진 업로드를 먼저 완료해주세요.',
        fallbackMessage: '사진 업로드가 완료되지 않았어요.',
      );
      return;
    }

    try {
      final createdBlog = await ref
          .read(blogWriteViewModelProvider.notifier)
          .createBlog(
            request: CreateBlogRequest(
              travelCourseId: travelCourseId,
              title: title,
              content: content,
              imageUrls: writeState.uploadedImageUrls,
              tags: _tags,
              isPublic: true,
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(createdBlog);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: '블로그를 저장하지 못했어요.',
        fallbackMessage: '블로그를 저장하지 못했어요.',
      );
    }
  }

  String? _resolveTravelCourseId() {
    final String? widgetValue = widget.travelCourseId?.trim();
    if (widgetValue != null && widgetValue.isNotEmpty) {
      return widgetValue;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      final String value = arguments.trim();
      return value.isEmpty ? null : value;
    }

    if (arguments is Map) {
      final dynamic rawValue =
          arguments['travelCourseId'] ??
          arguments['courseId'] ??
          arguments['id'];
      if (rawValue == null) return null;
      final String value = rawValue.toString().trim();
      return value.isEmpty ? null : value;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final BlogWriteState writeState = ref.watch(blogWriteViewModelProvider);

    return MLayout(
      backgroundColor: MColor.white100,
      appBar: AppBar(
        backgroundColor: MColor.white100,
        surfaceTintColor: MColor.white100,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 56.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: IconButton(
            padding: EdgeInsets.zero,
            splashRadius: 22.r,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: MColor.black100,
              size: 20.sp,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h + bottomInset),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: writeState.isSubmitting ? null : _publishBlog,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size.fromHeight(54.h),
                backgroundColor: _accentColor,
                foregroundColor: MColor.white100,
                disabledBackgroundColor: _accentColor.withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: writeState.isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: MColor.white100,
                      ),
                    )
                  : Text(
                      '작성하기',
                      style: MTextStyles.bodyB.copyWith(color: MColor.white100),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              SizedBox(height: 22.h),
              _buildContentField(),
              SizedBox(height: 24.h),
              Text(
                '사진 첨부',
                style: MTextStyles.lBodyB.copyWith(color: MColor.gray800),
              ),
              SizedBox(height: 12.h),
              _buildPhotoBox(writeState),
              SizedBox(height: 24.h),
              Text(
                '태그',
                style: MTextStyles.lBodyB.copyWith(color: MColor.gray800),
              ),
              SizedBox(height: 12.h),
              _buildTagField(),
              SizedBox(height: 12.h),
              _buildTagChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      maxLines: 1,
      style: MTextStyles.sTitleM.copyWith(color: MColor.gray800, height: 1.1),
      decoration: InputDecoration(
        isDense: true,
        hintText: '제목을 입력해주세요.',
        hintStyle: MTextStyles.sTitleM.copyWith(
          color: _titleHintColor,
          height: 1.1,
        ),
        contentPadding: EdgeInsets.only(bottom: 14.h),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _accentColor, width: 1.2.w),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: _accentColor, width: 1.2.w),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 284.h),
      decoration: BoxDecoration(
        color: MColor.gray50,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TextField(
        controller: _contentController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        minLines: 10,
        style: MTextStyles.lBodyM.copyWith(color: MColor.gray800, height: 1.45),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
          hintText: '내용을 입력해주세요.',
          hintStyle: MTextStyles.lBodyM.copyWith(
            color: _contentHintColor,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoBox(BlogWriteState writeState) {
    final String? uploadedImageUrl = writeState.uploadedImageUrls.isEmpty
        ? null
        : writeState.uploadedImageUrls.first;

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: Radius.circular(16.r),
        color: MColor.primary500,
        strokeWidth: 1.5,
        dashPattern: const [8, 6],
        padding: EdgeInsets.zero,
      ),
      child: InkWell(
        onTap: _pickAndUploadPhoto,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          height: 132.h,
          decoration: BoxDecoration(
            color: MColor.white100,
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (uploadedImageUrl != null)
                Positioned.fill(
                  child: Image.network(uploadedImageUrl, fit: BoxFit.cover),
                )
              else if (_selectedImageFile != null)
                Positioned.fill(
                  child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                ),
              if (uploadedImageUrl != null || _selectedImageFile != null)
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.18)),
                ),
              if (writeState.isUploadingImage)
                CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: MColor.primary500,
                )
              else
                Text(
                  uploadedImageUrl == null ? '사진추가' : '사진추가 완료',
                  style: MTextStyles.bodyB.copyWith(
                    color: uploadedImageUrl == null
                        ? MColor.primary500
                        : MColor.white100,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagField() {
    return TextField(
      controller: _tagController,
      onSubmitted: _addTag,
      textInputAction: TextInputAction.done,
      style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
      decoration: InputDecoration(
        hintText: '태그입력  (ex #우정여행)',
        hintStyle: MTextStyles.bodyM.copyWith(color: _tagHintColor),
        filled: true,
        fillColor: MColor.white100,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: MColor.gray200, width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: MColor.gray200, width: 1.w),
        ),
      ),
    );
  }

  Widget _buildTagChips() {
    if (_tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: MColor.white100,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: MColor.gray100),
              ),
              child: Text(
                '#$tag',
                style: MTextStyles.bodyB.copyWith(color: MColor.gray600),
              ),
            ),
          )
          .toList(),
    );
  }
}
