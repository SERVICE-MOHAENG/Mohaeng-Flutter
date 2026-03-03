import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/schedule_select_view_model.dart';

class ScheduleSelectScreen extends ConsumerStatefulWidget {
  const ScheduleSelectScreen({super.key});

  @override
  ConsumerState<ScheduleSelectScreen> createState() =>
      _ScheduleSelectScreenState();
}

class _ScheduleSelectScreenState extends ConsumerState<ScheduleSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleSelectViewModelProvider);
    final scheduleNotifier = ref.read(scheduleSelectViewModelProvider.notifier);
    final regionState = ref.watch(regionSelectViewModelProvider);
    final needsCitySync =
        (regionState.selectedCities.isEmpty &&
            scheduleState.selectedCity.isNotEmpty) ||
        (regionState.selectedCities.isNotEmpty &&
            !regionState.selectedCities.contains(scheduleState.selectedCity));
    if (needsCitySync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scheduleNotifier.ensureSelectedCity(regionState.selectedCities);
      });
    }
    final isValid = scheduleNotifier.isAllCitiesSelected(
      regionState.selectedCities,
    );

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildNextButton(enabled: isValid),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 6.h),
            _buildTopBar(),
            SizedBox(height: 40.h),
            _buildDescription(),
            SizedBox(height: 24.h),
            _buildCityChips(regionState.selectedCities, scheduleState),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildMonthHeader(scheduleState.displayMonth),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildWeekHeader(),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildCalendarGrid(
                scheduleState,
                regionState.selectedCities,
              ),
            ),
            const Spacer(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 44.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          color: MColor.black100,
          splashRadius: 22.r,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Text(
            '일정 선택',
            textAlign: TextAlign.center,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          SizedBox(height: 16.h),
          Text(
            '희망하는 여행 기간을 선택해주세요!\n최소 1일 이상, 8일 이하로 선택해야 합니다!',
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChips(
    List<String> cities,
    ScheduleSelectState scheduleState,
  ) {
    if (cities.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (final entry in cities.asMap().entries) ...[
            _CountryChip(
              label: entry.value,
              selected: entry.value == scheduleState.selectedCity,
              onTap: () => ref
                  .read(scheduleSelectViewModelProvider.notifier)
                  .setSelectedCity(entry.value),
            ),
            if (entry.key != cities.length - 1) SizedBox(width: 12.w),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthHeader(DateTime displayMonth) {
    return Row(
      children: [
        IconButton(
          onPressed: ref
              .read(scheduleSelectViewModelProvider.notifier)
              .goToPreviousMonth,
          icon: Icon(Icons.chevron_left, size: 28.sp, color: MColor.gray400),
        ),
        Expanded(
          child: Text(
            '${displayMonth.month}월',
            textAlign: TextAlign.center,
            style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
          ),
        ),
        IconButton(
          onPressed: ref
              .read(scheduleSelectViewModelProvider.notifier)
              .goToNextMonth,
          icon: Icon(Icons.chevron_right, size: 28.sp, color: MColor.gray400),
        ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarGrid(
    ScheduleSelectState scheduleState,
    List<String> cities,
  ) {
    final days = _buildMonthCells(scheduleState.displayMonth);
    final scheduleNotifier = ref.read(scheduleSelectViewModelProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.w;
        final cellSize = (constraints.maxWidth - spacing * 6) / 7;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final entry in days)
              SizedBox(
                width: cellSize,
                height: cellSize,
                child: _DayCell(
                  date: entry.date,
                  inMonth: entry.inMonth,
                  isStart: scheduleNotifier.isSameDay(
                    scheduleState.startDate,
                    entry.date,
                  ),
                  isEnd: scheduleNotifier.isSameDay(
                    scheduleState.endDate,
                    entry.date,
                  ),
                  isInRange: scheduleNotifier.isInRange(entry.date),
                  onTap: entry.inMonth
                      ? () => scheduleNotifier.selectDate(
                          entry.date,
                          cities: cities,
                        )
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNextButton({required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _onTapNext : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MColor.primary500,
          disabledBackgroundColor: MColor.gray100,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          '완료',
          style: MTextStyles.labelM.copyWith(
            color: enabled ? MColor.white100 : MColor.gray300,
          ),
        ),
      ),
    );
  }

  void _onTapNext() {
    Navigator.pushNamed(context, AppRoutes.roadmapPeople);
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? MColor.primary50 : MColor.white100;
    final borderWidth = selected ? 2.w : 1.w;
    return SizedBox(
      width: 159.w,
      height: 64.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: MColor.primary500, width: borderWidth),
          foregroundColor: MColor.primary500,
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        child: Text(
          label,
          style: MTextStyles.bodyM.copyWith(color: MColor.primary500),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isStart,
    required this.isEnd,
    required this.isInRange,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool isStart;
  final bool isEnd;
  final bool isInRange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = isStart || isEnd || isInRange;
    final showPlane = isStart || isEnd;

    final backgroundColor = switch ((isStart, isEnd, isInRange)) {
      (true, _, _) || (_, true, _) => MColor.primary500,
      (_, _, true) => MColor.primary100,
      _ => MColor.white100,
    };

    final borderColor = isSelected ? Colors.transparent : MColor.gray100;

    final textColor = !inMonth
        ? MColor.gray200
        : (isSelected ? MColor.white100 : MColor.gray600);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: borderColor, width: 1.w),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Text(
                    '${date.day}',
                    style: MTextStyles.bodyM.copyWith(color: textColor),
                  ),
                ),
              ),
              if (showPlane)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w, bottom: 6.h),
                    child: Icon(
                      Icons.flight,
                      size: 14.sp,
                      color: MColor.white100,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCellEntry {
  const _MonthCellEntry({required this.date, required this.inMonth});

  final DateTime date;
  final bool inMonth;
}

List<_MonthCellEntry> _buildMonthCells(DateTime month) {
  final firstDay = DateTime(month.year, month.month, 1);
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final leadingEmpty = firstDay.weekday - DateTime.monday;

  final prevMonth = DateTime(month.year, month.month - 1);
  final prevMonthDays = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

  final cells = <_MonthCellEntry>[];

  for (var i = leadingEmpty; i > 0; i--) {
    final day = prevMonthDays - i + 1;
    cells.add(
      _MonthCellEntry(
        date: DateTime(prevMonth.year, prevMonth.month, day),
        inMonth: false,
      ),
    );
  }

  for (var day = 1; day <= daysInMonth; day++) {
    cells.add(
      _MonthCellEntry(
        date: DateTime(month.year, month.month, day),
        inMonth: true,
      ),
    );
  }

  final trailing = (7 - (cells.length % 7)) % 7;
  final nextMonth = DateTime(month.year, month.month + 1);
  for (var day = 1; day <= trailing; day++) {
    cells.add(
      _MonthCellEntry(
        date: DateTime(nextMonth.year, nextMonth.month, day),
        inMonth: false,
      ),
    );
  }

  return cells;
}
