import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/countries_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/country_regions_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class RegionSelectScreen extends ConsumerStatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  ConsumerState<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends ConsumerState<RegionSelectScreen> {
  late final PageController _pageController;
  late final TextEditingController _countrySearchController;
  late final FocusNode _countrySearchFocusNode;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  final Map<String, List<String>> _selectedCitiesByCountry = {};
  String _countrySearchQuery = '';
  String _searchQuery = '';
  int _currentCountryIndex = 0;
  String? _currentCountryKey;
  double _pageOffset = 0.0;
  bool _didSyncInitialCountry = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);
    _countrySearchFocusNode =
        FocusNode()..addListener(_handleCountrySearchFocusChanged);
    _countrySearchController = TextEditingController()
      ..addListener(_handleCountrySearchChanged);
    _searchFocusNode = FocusNode()..addListener(_handleSearchFocusChanged);
    _searchController = TextEditingController()
      ..addListener(_handleSearchChanged);

    Future.microtask(() {
      ref.read(countriesViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _countrySearchFocusNode
        .removeListener(_handleCountrySearchFocusChanged);
    _countrySearchFocusNode.dispose();
    _countrySearchController.removeListener(_handleCountrySearchChanged);
    _countrySearchController.dispose();
    _searchFocusNode.removeListener(_handleSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countriesState = ref.watch(countriesViewModelProvider);
    final countryRegionsState = ref.watch(countryRegionsViewModelProvider);
    final regionState = ref.watch(regionSelectViewModelProvider);
    final countries = countriesState.countries;

    final currentCountry = _currentCountry(countries);
    _syncInitialCountryIfNeeded(countries);
    _syncCurrentCountryIndexIfNeeded(countries);

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
            _buildHeroImage(countriesState, countries, currentCountry),
            SizedBox(height: 24.h),
            _buildCountryHeader(currentCountry),
            SizedBox(height: 12.h),
            _buildDescription(currentCountry),
            SizedBox(height: 24.h),
            Expanded(
              child: TextFieldTapRegion(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildLiftedSearchAttachment(
                          focused: _countrySearchFocusNode.hasFocus,
                          child: _buildCountrySearchAttachment(
                            countries,
                            currentCountry,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildLiftedSearchAttachment(
                          focused: _searchFocusNode.hasFocus,
                          child: _buildSearchAttachment(
                            currentCountry: currentCountry,
                            countryRegionsState: countryRegionsState,
                            selectedCities: regionState.selectedCities,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _buildSelectedChips(regionState.selectedCities),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiftedSearchAttachment({
    required bool focused,
    required Widget child,
  }) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: focused ? Offset(0, -0.045) : Offset.zero,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        scale: focused ? 1.01 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeroImage(
    CountriesState countriesState,
    List<CountryModel> countries,
    CountryModel? currentCountry,
  ) {
    return SizedBox(
      height: 400.h,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (countriesState.isLoading && countries.isEmpty)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else if (countriesState.errorMessage != null && countries.isEmpty)
              _buildHeroError(countriesState.errorMessage!)
            else if (countries.isEmpty)
              _buildHeroPlaceholder()
            else
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => _handleCountryPageChanged(
                  index,
                  countries,
                ),
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return _buildCountryHero(country);
                },
              ),
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
              child: _buildPagerIndicator(countries),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroError(String message) {
    return Container(
      color: MColor.gray100,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: MTextStyles.bodyM.copyWith(color: MColor.gray600),
      ),
    );
  }

  Widget _buildCountryHero(CountryModel country) {
    final imageUrl = country.imageUrl;
    return _buildCountryHeroImage(imageUrl);
  }

  Widget _buildCountryHeroImage(String? imageUrl) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildHeroPlaceholder();
        },
      );
    }

    return _buildHeroPlaceholder();
  }

  Widget _buildHeroPlaceholder() {
    return Container(
      color: MColor.gray100,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 42.sp, color: MColor.gray300),
    );
  }

  Widget _buildPagerIndicator(List<CountryModel> countries) {
    if (countries.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        final page = _pageController.hasClients
            ? (_pageController.page ?? _currentCountryIndex.toDouble())
            : _currentCountryIndex.toDouble();
        final activeIndex = page.round().clamp(0, countries.length - 1);
        final items = _buildIndicatorItems(countries.length, activeIndex);

        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _buildIndicatorItem(
                  item: items[index],
                  isActive: items[index] == _IndicatorItem.bar(activeIndex),
                ),
                if (index != items.length - 1) SizedBox(width: 4.w),
              ],
            ],
          ),
        );
      },
    );
  }

  List<_IndicatorItem> _buildIndicatorItems(int totalCount, int activeIndex) {
    if (totalCount <= 7) {
      return List.generate(totalCount, _IndicatorItem.bar);
    }

    final clampedIndex = activeIndex.clamp(0, totalCount - 1);
    if (clampedIndex <= 3) {
      return [
        for (var i = 0; i < 5; i++) _IndicatorItem.bar(i),
        const _IndicatorItem.ellipsis(),
      ];
    }

    if (clampedIndex >= totalCount - 4) {
      return [
        const _IndicatorItem.ellipsis(),
        for (var i = totalCount - 5; i < totalCount; i++) _IndicatorItem.bar(i),
      ];
    }

    return [
      const _IndicatorItem.ellipsis(),
      _IndicatorItem.bar(clampedIndex - 2),
      _IndicatorItem.bar(clampedIndex - 1),
      _IndicatorItem.bar(clampedIndex),
      _IndicatorItem.bar(clampedIndex + 1),
      _IndicatorItem.bar(clampedIndex + 2),
      const _IndicatorItem.ellipsis(),
    ];
  }

  Widget _buildIndicatorItem({
    required _IndicatorItem item,
    required bool isActive,
  }) {
    if (item.isEllipsis) {
      return Text(
        '...',
        style: MTextStyles.labelM.copyWith(color: MColor.gray100),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 24.w,
      height: 2.h,
      decoration: BoxDecoration(
        color: isActive ? MColor.primary500 : MColor.gray100,
        borderRadius: BorderRadius.circular(99.r),
      ),
    );
  }

  Widget _buildCountryHeader(CountryModel? currentCountry) {
    final countryName = currentCountry?.name.trim().isNotEmpty == true
        ? currentCountry!.name.trim()
        : '국가';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              countryName,
              style: MTextStyles.bodyM.copyWith(color: MColor.gray900),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(CountryModel? currentCountry) {
    final countryName = currentCountry?.name.trim().isNotEmpty == true
        ? currentCountry!.name.trim()
        : '해당 국가';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Text(
        '광활한 자연과 다양한 문화가 공존하는 나라, $countryName.\n'
        '대도시부터 국립공원까지 다채로운 여행을 즐길 수 있습니다.',
        textAlign: TextAlign.center,
        style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
      ),
    );
  }

  Widget _buildSearchAttachment({
    required CountryModel? currentCountry,
    required CountryRegionsState countryRegionsState,
    required List<String> selectedCities,
  }) {
    final countryName = currentCountry?.name.trim().isNotEmpty == true
        ? currentCountry!.name.trim()
        : '해당 국가';
    final shouldShowPanel =
        _searchFocusNode.hasFocus &&
        (countryRegionsState.isLoading ||
            countryRegionsState.errorMessage != null ||
            _searchQuery.isNotEmpty ||
            _filteredCityNames(countryRegionsState, selectedCities).isNotEmpty);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
            onFieldSubmitted: (_) => _handleAddCity(),
            onTapOutside: (_) => _searchFocusNode.unfocus(),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MColor.gray200, width: 1.w),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MColor.gray200, width: 1.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MColor.gray200, width: 1.w),
              ),
              hintText: '$countryName에서 방문하고 싶은 도시를 입력해주세요.',
              hintStyle: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 11.h,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
                child: InkWell(
                  onTap: _handleAddCity,
                  borderRadius: BorderRadius.circular(65.r),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: MColor.primary500,
                      borderRadius: BorderRadius.circular(65.r),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 16.sp,
                      color: MColor.white100,
                    ),
                  ),
                ),
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
          if (shouldShowPanel) ...[
            Divider(height: 1.h, thickness: 1.h, color: MColor.gray100),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 260.h),
              child: _buildSuggestionList(
                countryRegionsState: countryRegionsState,
                currentCountry: currentCountry,
                selectedCities: selectedCities,
                countryName: countryName,
                compact: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountrySearchAttachment(
    List<CountryModel> countries,
    CountryModel? currentCountry,
  ) {
    final shouldShowPanel =
        _countrySearchFocusNode.hasFocus &&
        (_countrySearchQuery.isNotEmpty ||
            _filteredCountries(countries).isNotEmpty);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _countrySearchController,
            focusNode: _countrySearchFocusNode,
            style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
            onFieldSubmitted: (_) => _handleCountrySearchPickFirst(countries),
            onTapOutside: (_) => _countrySearchFocusNode.unfocus(),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MColor.gray200, width: 1.w),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MColor.gray200, width: 1.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MColor.gray200, width: 1.w),
              ),
              hintText: '나라를 입력해주세요.',
              hintStyle: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 11.h,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w, top: 8.h, bottom: 8.h),
                child: InkWell(
                  onTap: () => _handleCountrySearchPickFirst(countries),
                  borderRadius: BorderRadius.circular(65.r),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: MColor.primary500,
                      borderRadius: BorderRadius.circular(65.r),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 16.sp,
                      color: MColor.white100,
                    ),
                  ),
                ),
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
          if (shouldShowPanel) ...[
            Divider(height: 1.h, thickness: 1.h, color: MColor.gray100),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 260.h),
              child: _buildCountrySuggestionList(
                countries,
                currentCountry,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountrySuggestionList(
    List<CountryModel> countries,
    CountryModel? currentCountry,
  ) {
    final filteredCountries = _filteredCountries(countries);
    if (filteredCountries.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          '검색 결과가 없습니다.',
          style: MTextStyles.sLabelM.copyWith(color: MColor.gray500),
        ),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        itemCount: filteredCountries.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final country = filteredCountries[index];
          final isSelected = currentCountry?.id == country.id;
          return InkWell(
            borderRadius: BorderRadius.circular(10.r),
            onTap: () => _selectCountry(country, countries),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? MColor.gray100 : MColor.white100,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isSelected ? MColor.primary500 : MColor.gray100,
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      country.name,
                      style: MTextStyles.bodyM.copyWith(color: MColor.gray900),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionList({
    required CountryRegionsState countryRegionsState,
    required CountryModel? currentCountry,
    required List<String> selectedCities,
    required String countryName,
    required bool compact,
  }) {
    if (countryRegionsState.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (countryRegionsState.errorMessage != null) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                countryRegionsState.errorMessage!,
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray500),
              ),
            ),
            TextButton(
              onPressed: currentCountry == null
                  ? null
                  : () => ref
                        .read(countryRegionsViewModelProvider.notifier)
                        .load(currentCountry.name),
              child: Text(
                '다시 시도',
                style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
              ),
            ),
          ],
        ),
      );
    }

    final filteredCityNames = _filteredCityNames(countryRegionsState, selectedCities);
    if (filteredCityNames.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          compact ? '검색 결과가 없습니다.' : '$countryName에서 찾을 수 있는 도시가 없습니다.',
          style: MTextStyles.sLabelM.copyWith(color: MColor.gray500),
        ),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        itemCount: filteredCityNames.length,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        physics: const ClampingScrollPhysics(),
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
      ),
    );
  }

  void _handleAddCity() {
    final city = _searchController.text.trim();
    if (city.isEmpty) return;
    _addCity(city, clearInput: true);
  }

  void _handleSearchChanged() {
    final next = _searchController.text.trim();
    if (next == _searchQuery) return;
    setState(() => _searchQuery = next);
  }

  void _handleCountrySearchChanged() {
    final next = _countrySearchController.text.trim();
    if (next == _countrySearchQuery) return;
    setState(() => _countrySearchQuery = next);
  }

  void _handleSearchFocusChanged() {
    setState(() {});
    if (_searchFocusNode.hasFocus) {
      _loadCitiesForCurrentCountry();
    }
  }

  void _handleCountrySearchFocusChanged() {
    setState(() {});
  }

  void _loadCitiesForCurrentCountry() {
    final countries = ref.read(countriesViewModelProvider).countries;
    final currentCountry = _currentCountry(countries);
    if (currentCountry == null) return;

    ref.read(countryRegionsViewModelProvider.notifier).load(currentCountry.name);
  }

  void _addCity(String city, {bool clearInput = false}) {
    final normalized = city.trim();
    if (normalized.isEmpty) return;

    ref.read(regionSelectViewModelProvider.notifier).addCity(normalized);
    _syncSelectedCitiesCache();

    if (clearInput) {
      _searchController.clear();
    }
    FocusScope.of(context).unfocus();
  }

  void _handleCountrySearchPickFirst(List<CountryModel> countries) {
    final filteredCountries = _filteredCountries(countries);
    if (filteredCountries.isEmpty) return;
    _selectCountry(filteredCountries.first, countries);
  }

  void _selectCountry(CountryModel country, List<CountryModel> countries) {
    final index = countries.indexWhere((item) => item.id == country.id);
    if (index < 0) return;

    _countrySearchController.clear();
    _countrySearchFocusNode.unfocus();
    _pageController.jumpToPage(index);
    _applyCountryAtIndex(index, countries, resetPageController: false);
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
                _syncSelectedCitiesCache();
              },
            ),
            if (entry.key != cities.length - 1) SizedBox(width: 10.w),
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

  void _syncInitialCountryIfNeeded(List<CountryModel> countries) {
    if (_didSyncInitialCountry || countries.isEmpty) return;

    _didSyncInitialCountry = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyCountryAtIndex(0, countries, resetPageController: false);
    });
  }

  void _syncCurrentCountryIndexIfNeeded(List<CountryModel> countries) {
    if (countries.isEmpty) return;
    if (_currentCountryIndex < countries.length) return;

    final nextIndex = countries.length - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyCountryAtIndex(nextIndex, countries, resetPageController: true);
    });
  }

  void _handleCountryPageChanged(int index, List<CountryModel> countries) {
    _applyCountryAtIndex(index, countries, resetPageController: false);
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page;
    if (page == null) return;
    if ((page - _pageOffset).abs() < 0.001) return;

    setState(() => _pageOffset = page);
  }

  void _applyCountryAtIndex(
    int index,
    List<CountryModel> countries, {
    required bool resetPageController,
  }) {
    if (countries.isEmpty) return;

    final nextIndex = index.clamp(0, countries.length - 1);
    final nextCountry = countries[nextIndex];
    final nextCountryKey = _countryCacheKey(nextCountry);

    final previousCountryKey = _currentCountryKey;
    if (previousCountryKey != null) {
      _selectedCitiesByCountry[previousCountryKey] = List<String>.from(
        ref.read(regionSelectViewModelProvider).selectedCities,
      );
    }

    final nextCities = _selectedCitiesByCountry[nextCountryKey] ?? const [];
    ref.read(regionSelectViewModelProvider.notifier).setCities(nextCities);

    if (_currentCountryIndex != nextIndex || _currentCountryKey != nextCountryKey) {
      setState(() {
        _currentCountryIndex = nextIndex;
        _currentCountryKey = nextCountryKey;
        _searchQuery = '';
      });
    }

    _searchController.clear();
    _searchFocusNode.unfocus();

    if (resetPageController && _pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }

    ref.read(countryRegionsViewModelProvider.notifier).load(nextCountry.name);
    setState(() => _pageOffset = nextIndex.toDouble());
  }

  void _syncSelectedCitiesCache() {
    final currentKey = _currentCountryKey;
    if (currentKey == null) return;

    _selectedCitiesByCountry[currentKey] = List<String>.from(
      ref.read(regionSelectViewModelProvider).selectedCities,
    );
  }

  CountryModel? _currentCountry(List<CountryModel> countries) {
    if (countries.isEmpty) return null;
    if (_currentCountryIndex < 0 || _currentCountryIndex >= countries.length) {
      return countries.first;
    }
    return countries[_currentCountryIndex];
  }

  String _countryCacheKey(CountryModel country) {
    final id = country.id.trim();
    if (id.isNotEmpty) return id;
    final code = country.countryCode.trim();
    if (code.isNotEmpty) return code;
    return country.name.trim();
  }

  List<String> _filteredCityNames(
    CountryRegionsState countryRegionsState,
    List<String> selectedCities,
  ) {
    final availableCityNames = countryRegionsState.regions
        .map((region) => region.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final query = _searchQuery.toLowerCase();
    return availableCityNames
        .where((name) {
          if (selectedCities.contains(name)) return false;
          if (query.isEmpty) return true;
          return name.toLowerCase().contains(query);
        })
        .take(30)
        .toList();
  }

  List<CountryModel> _filteredCountries(List<CountryModel> countries) {
    final query = _countrySearchQuery.toLowerCase();
    return countries.where((country) {
      if (query.isEmpty) return true;
      final name = country.name.toLowerCase();
      final code = country.code.toLowerCase();
      final countryCode = country.countryCode.toLowerCase();
      final continent = country.continent.toLowerCase();
      return name.contains(query) ||
          code.contains(query) ||
          countryCode.contains(query) ||
          continent.contains(query);
    }).toList();
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
          InkWell(
            onTap: onDeleted,
            child: Icon(Icons.close, size: 14.sp, color: MColor.primary500),
          ),
        ],
      ),
    );
  }
}

@immutable
class _IndicatorItem {
  const _IndicatorItem.bar(this.index) : isEllipsis = false;
  const _IndicatorItem.ellipsis()
    : index = null,
      isEllipsis = true;

  final int? index;
  final bool isEllipsis;

  @override
  bool operator ==(Object other) {
    return other is _IndicatorItem &&
        other.index == index &&
        other.isEllipsis == isEllipsis;
  }

  @override
  int get hashCode => Object.hash(index, isEllipsis);
}
