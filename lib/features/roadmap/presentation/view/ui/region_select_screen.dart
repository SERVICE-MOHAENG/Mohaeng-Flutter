import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/country_regions_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class RegionSelectScreen extends ConsumerStatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  ConsumerState<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends ConsumerState<RegionSelectScreen> {
  static const String _countryName = '미국';

  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(_handleSearchChanged);
    Future.microtask(
      () =>
          ref.read(countryRegionsViewModelProvider.notifier).load(_countryName),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regionState = ref.watch(regionSelectViewModelProvider);
    final countryRegionsState = ref.watch(countryRegionsViewModelProvider);

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
              child: _buildSelectedChips(regionState.selectedCities),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildRegionSuggestions(
                  countryRegionsState: countryRegionsState,
                  selectedCities: regionState.selectedCities,
                ),
              ),
            ),
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
            left: 4.w,
            top: MediaQuery.paddingOf(context).top + 6.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MColor.white100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                color: MColor.black100,
                splashRadius: 22.r,
              ),
            ),
          ),
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
              _countryName,
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
      onFieldSubmitted: (_) => _handleAddCity(),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: MColor.white100,
        hintText: '미국에서 방문하고 싶은 도시를 입력해주세요.',
        hintStyle: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
          child: InkWell(
            onTap: _handleAddCity,
            borderRadius: BorderRadius.circular(65.r),
            child: Container(
              decoration: BoxDecoration(
                color: MColor.primary500,
                borderRadius: BorderRadius.circular(65.r),
              ),
              child: Icon(Icons.search, size: 16.sp, color: MColor.white100),
            ),
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

  void _handleAddCity() {
    final city = _searchController.text.trim();
    if (city.trim().isEmpty) return;
    _addCity(city, clearInput: true);
  }

  void _handleSearchChanged() {
    final next = _searchController.text.trim();
    if (next == _searchQuery) return;
    setState(() => _searchQuery = next);
  }

  void _addCity(String city, {bool clearInput = false}) {
    final normalized = city.trim();
    if (normalized.isEmpty) return;
    ref.read(regionSelectViewModelProvider.notifier).addCity(normalized);
    if (clearInput) {
      _searchController.clear();
    }
    FocusScope.of(context).unfocus();
  }

  Widget _buildSelectedChips(List<String> cities) {
    if (cities.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in cities.asMap().entries) ...[
            _CityChip(
              label: entry.value,
              onDeleted: () {
                ref
                    .read(regionSelectViewModelProvider.notifier)
                    .removeCityAt(entry.key);
              },
            ),
            if (entry.key != cities.length - 1) SizedBox(width: 10.w),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionSuggestions({
    required CountryRegionsState countryRegionsState,
    required List<String> selectedCities,
  }) {
    if (countryRegionsState.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (countryRegionsState.errorMessage != null) {
      return Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                countryRegionsState.errorMessage!,
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray500),
              ),
            ),
            TextButton(
              onPressed: () => ref
                  .read(countryRegionsViewModelProvider.notifier)
                  .load(_countryName),
              child: Text(
                '다시 시도',
                style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
              ),
            ),
          ],
        ),
      );
    }

    final availableCityNames =
        countryRegionsState.regions
            .map((region) => region.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final query = _searchQuery.toLowerCase();
    final filteredCityNames = availableCityNames
        .where((name) {
          if (selectedCities.contains(name)) return false;
          if (query.isEmpty) return true;
          return name.toLowerCase().contains(query);
        })
        .take(30)
        .toList();

    if (filteredCityNames.isEmpty) {
      if (_searchQuery.isEmpty) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.topLeft,
        child: Text(
          '검색 결과가 없습니다.',
          style: MTextStyles.sLabelM.copyWith(color: MColor.gray500),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: filteredCityNames.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final city = filteredCityNames[index];
        return InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => _addCity(city, clearInput: true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: MColor.white100,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: MColor.gray100, width: 1.w),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city, size: 16.sp, color: MColor.gray500),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    city,
                    style: MTextStyles.bodyM.copyWith(color: MColor.gray900),
                  ),
                ),
                Icon(Icons.add, size: 16.sp, color: MColor.primary500),
              ],
            ),
          ),
        );
      },
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
