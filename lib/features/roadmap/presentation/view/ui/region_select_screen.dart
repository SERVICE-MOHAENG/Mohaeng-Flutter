import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class RegionSelectScreen extends StatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  State<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends State<RegionSelectScreen> {
  late final TextEditingController _searchController;

  final List<String> _selectedCities = ['알래스카, 동-국립공원', '워싱턴디시', '뉴욕'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildNextButton(),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroImage(),
            SizedBox(height: 24.h),
            _buildCountryHeader(),
            SizedBox(height: 12.h),
            _buildDescription(),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildSearchField(),
            ),
            SizedBox(height: 18.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildSelectedChips(),
            ),
            const Spacer(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 400.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(MImages.america, fit: BoxFit.cover),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18.h,
            child: _buildPagerIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildPagerIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final color = index == 0 ? MColor.primary500 : MColor.gray100;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Container(width: 24.w, height: 2.h, color: color),
        );
      }),
    );
  }

  Widget _buildCountryHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '미국',
              style: MTextStyles.bodyM.copyWith(color: MColor.gray900),
            ),
            SizedBox(width: 8.w),
            Text('🇺🇸', style: TextStyle(fontSize: 18.sp)),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Text(
        '광활한 자연과 다양한 문화가 공존하는 나라, 미국.\n'
        '대도시부터 국립공원까지 다채로운 여행을 즐길 수 있습니다.',
        textAlign: TextAlign.center,
        style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: _searchController,
      style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: MColor.white100,
        hintText: '미국에서 방문하고 싶은 도시를 입력해주세요.',
        hintStyle: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
          child: Container(
            decoration: BoxDecoration(
              color: MColor.primary500,
              borderRadius: BorderRadius.circular(65.r),
            ),
            child: Icon(Icons.search, size: 16.sp, color: MColor.white100),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: MColor.gray100, width: 1.5.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: MColor.gray100, width: 1.w),
        ),
      ),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildSelectedChips() {
    if (_selectedCities.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in _selectedCities.asMap().entries) ...[
            _CityChip(
              label: entry.value,
              onDeleted: () {
                setState(() => _selectedCities.removeAt(entry.key));
              },
            ),
            if (entry.key != _selectedCities.length - 1) SizedBox(width: 10.w),
          ],
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.roadmapSchedule),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MColor.primary500,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          '다음',
          style: TextStyle(
            fontFamily: 'GmarketMedium',
            fontSize: 12.sp,
            color: MColor.white100,
          ),
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: MColor.primary500, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: MTextStyles.labelM.copyWith(color: MColor.primary500),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDeleted,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close, size: 20.sp, color: MColor.primary500),
          ),
        ],
      ),
    );
  }
}
