import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class BlogWriteScreen extends StatefulWidget {
  const BlogWriteScreen({super.key});

  @override
  State<BlogWriteScreen> createState() => _BlogWriteScreenState();
}

class _BlogWriteScreenState extends State<BlogWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  final List<String> _tags = [];

  String? _selectedRoadmapTitle;

  static const Color _accentColor = Color(0xFF00CCFF);
  static const Color _titleHintColor = Color(0xFFD8D8D8);
  static const Color _contentHintColor = Color(0xFFE0E0E0);
  static const Color _tagHintColor = Color(0xFFD0D0D0);

  static const List<String> _roadmapOptions = <String>[
    '도쿄 3박 4일 감성 로드맵',
    '오사카 먹방 여행 로드맵',
    '제주 힐링 드라이브 로드맵',
    '부산 바다 산책 로드맵',
  ];

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

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectRoadmap() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MColor.white100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: MColor.gray200,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '연결할 로드맵을 선택하세요',
                  style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 8.h),
                Text(
                  '작성한 블로그를 어떤 여행 기록과 묶을지 선택할 수 있어요.',
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 16.h),
                ..._roadmapOptions.map(
                  (title) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () => Navigator.of(context).pop(title),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: MColor.gray50,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: MColor.gray100),
                        ),
                        child: Text(
                          title,
                          style: MTextStyles.labelM.copyWith(
                            color: MColor.gray800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(48.h),
                      side: BorderSide(color: MColor.gray200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      '선택하지 않기',
                      style: MTextStyles.labelM.copyWith(color: MColor.gray500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      _selectedRoadmapTitle = selected;
    });
  }

  void _publishBlog() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

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

    showAppSnackBar(
      context,
      message: _selectedRoadmapTitle == null
          ? '블로그를 임시 저장했어요.'
          : '블로그를 저장했어요. 연결된 로드맵: $_selectedRoadmapTitle',
      fallbackMessage: '블로그를 저장하지 못했어요.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return MLayout(
      backgroundColor: MColor.gray50,
      appBar: AppBar(
        backgroundColor: MColor.gray50,
        surfaceTintColor: MColor.gray50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '블로그 작성',
          style: MTextStyles.labelM.copyWith(color: MColor.gray800),
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
              onPressed: _publishBlog,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size.fromHeight(54.h),
                backgroundColor: _accentColor,
                foregroundColor: MColor.white100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: Text(
                '임시 저장',
                style: MTextStyles.labelB.copyWith(color: MColor.white100),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoadmapCard(),
              SizedBox(height: 12.h),
              _buildEditorCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(MImages.imageIcon, width: 24.w, height: 24.h),
          SizedBox(width: 16.w),
          Expanded(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  child: ElevatedButton(
                    onPressed: _selectRoadmap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: MColor.white100,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    child: Text(
                      '로드맵 선택하기',
                      style: MTextStyles.labelM.copyWith(
                        color: MColor.white100,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            SizedBox(height: 18.h),
            _buildContentField(),
            SizedBox(height: 18.h),
            _buildTagArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      maxLines: 1,
      style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
      decoration: InputDecoration(
        isDense: true,
        hintText: '제목을 입력해주세요.',
        hintStyle: MTextStyles.lBodyM.copyWith(color: _titleHintColor),
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
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 260.h),
      child: TextField(
        controller: _contentController,
        expands: false,
        maxLines: null,
        minLines: 10,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        style: MTextStyles.bodyM.copyWith(color: MColor.gray800, height: 1.55),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: '내용을 입력해주세요.',
          hintStyle: MTextStyles.bodyM.copyWith(color: _contentHintColor),
        ),
      ),
    );
  }

  Widget _buildTagArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('태그', style: MTextStyles.labelB.copyWith(color: MColor.gray800)),
        SizedBox(height: 10.h),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            ..._tags.map(
              (tag) => InputChip(
                label: Text(
                  '#$tag',
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray600),
                ),
                onDeleted: () => _removeTag(tag),
                deleteIconColor: MColor.gray300,
                backgroundColor: MColor.gray50,
                side: BorderSide(color: MColor.gray100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
            SizedBox(
              width: 220.w,
              child: TextField(
                controller: _tagController,
                onSubmitted: _addTag,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration.collapsed(
                  hintText: '#태그입력  (태그 입력 후 엔터를 눌러주세요.)',
                  hintStyle: MTextStyles.sLabelM.copyWith(color: _tagHintColor),
                ),
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
