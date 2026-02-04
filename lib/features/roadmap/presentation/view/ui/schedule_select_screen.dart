import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class ScheduleSelectScreen extends StatefulWidget {
  const ScheduleSelectScreen({super.key});

  @override
  State<ScheduleSelectScreen> createState() => _ScheduleSelectScreenState();
}

class _ScheduleSelectScreenState extends State<ScheduleSelectScreen> {
  late DateTime _displayMonth;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _selectedCountries = ['브라질', '일본', '독일'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isValidSelection;

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
            SizedBox(height: 40.h),
            _buildDescription(),
            SizedBox(height: 20.h),
            _buildCountryChips(),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildMonthHeader(),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildWeekHeader(),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildCalendarGrid(),
            ),
            const Spacer(),
            SizedBox(height: 16.h),
          ],
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

  Widget _buildCountryChips() {
    if (_selectedCountries.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (final entry in _selectedCountries.asMap().entries) ...[
            _CountryChip(label: entry.value),
            if (entry.key != _selectedCountries.length - 1)
              SizedBox(width: 12.w),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _goToPreviousMonth,
          icon: Icon(Icons.chevron_left, size: 28.sp, color: MColor.gray400),
        ),
        Expanded(
          child: Text(
            '${_displayMonth.month}월',
            textAlign: TextAlign.center,
            style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
          ),
        ),
        IconButton(
          onPressed: _goToNextMonth,
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

  Widget _buildCalendarGrid() {
    final days = _buildMonthCells(_displayMonth);

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
                  isStart: _isSameDay(_startDate, entry.date),
                  isEnd: _isSameDay(_endDate, entry.date),
                  isInRange: _isInRange(entry.date),
                  onTap: entry.inMonth ? () => _onSelectDate(entry.date) : null,
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

  void _goToPreviousMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      _startDate = null;
      _endDate = null;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      _startDate = null;
      _endDate = null;
    });
  }

  void _onSelectDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);

    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = normalized;
        _endDate = null;
        return;
      }

      final start = _startDate!;
      if (normalized.isBefore(start)) {
        _startDate = normalized;
        _endDate = null;
        return;
      }

      _endDate = normalized;
    });
  }

  bool get _isValidSelection {
    final start = _startDate;
    final end = _endDate;
    if (start == null || end == null) return false;
    final days = end.difference(start).inDays;
    return days >= 0 && days <= 7;
  }

  bool _isInRange(DateTime date) {
    final start = _startDate;
    if (start == null) return false;
    final end = _endDate;
    if (end == null) return _isSameDay(start, date);

    final normalized = DateTime(date.year, date.month, date.day);
    final isAfterStart =
        normalized.isAfter(start) || _isSameDay(normalized, start);
    final isBeforeEnd = normalized.isBefore(end) || _isSameDay(normalized, end);
    return isAfterStart && isBeforeEnd;
  }

  static bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 159.w,
      height: 64.h,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: MColor.primary500, width: 1.w),
          foregroundColor: MColor.primary500,
          backgroundColor: MColor.white100,
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
