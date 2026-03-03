import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/schedule_select_view_model.dart';

void main() {
  group('ScheduleSelectState.copyWith', () {
    test('can clear start and end dates explicitly', () {
      final state = ScheduleSelectState(
        displayMonth: DateTime(2026, 1),
        startDate: DateTime(2026, 1, 2),
        endDate: DateTime(2026, 1, 4),
      );

      final next = state.copyWith(startDate: null, endDate: null);

      expect(next.startDate, isNull);
      expect(next.endDate, isNull);
    });
  });

  group('ScheduleSelectViewModel', () {
    test('switches to next city with an empty draft after range selection', () {
      final viewModel = ScheduleSelectViewModel();
      const cities = ['Los Angeles', 'New York'];

      viewModel.setSelectedCity(cities.first);
      viewModel.selectDate(DateTime(2026, 1, 5), cities: cities);
      viewModel.selectDate(DateTime(2026, 1, 7), cities: cities);

      final range = viewModel.state.cityDateRanges[cities.first];

      expect(viewModel.state.selectedCity, cities.last);
      expect(viewModel.state.startDate, isNull);
      expect(viewModel.state.endDate, isNull);
      expect(range, isNotNull);
      expect(viewModel.isSameDay(range?.start, DateTime(2026, 1, 5)), isTrue);
      expect(viewModel.isSameDay(range?.end, DateTime(2026, 1, 7)), isTrue);
    });

    test('restarting a completed selection clears end date', () {
      final viewModel = ScheduleSelectViewModel();

      viewModel.setSelectedCity('Los Angeles');
      viewModel.selectDate(DateTime(2026, 1, 5));
      viewModel.selectDate(DateTime(2026, 1, 7));

      viewModel.selectDate(DateTime(2026, 1, 10));

      expect(
        viewModel.isSameDay(viewModel.state.startDate, DateTime(2026, 1, 10)),
        isTrue,
      );
      expect(viewModel.state.endDate, isNull);
      expect(
        viewModel.state.cityDateRanges.containsKey('Los Angeles'),
        isFalse,
      );
    });

    test('keeps selected start date when moving month', () {
      final viewModel = ScheduleSelectViewModel();

      viewModel.setSelectedCity('Los Angeles');
      viewModel.selectDate(DateTime(2026, 1, 30));

      viewModel.goToNextMonth();
      viewModel.selectDate(DateTime(2026, 2, 2));

      final range = viewModel.state.cityDateRanges['Los Angeles'];
      expect(range, isNotNull);
      expect(viewModel.isSameDay(range?.start, DateTime(2026, 1, 30)), isTrue);
      expect(viewModel.isSameDay(range?.end, DateTime(2026, 2, 2)), isTrue);
    });

    test('ensureSelectedCity clears active selection for empty cities', () {
      final viewModel = ScheduleSelectViewModel();

      viewModel.setSelectedCity('Los Angeles');
      viewModel.selectDate(DateTime(2026, 1, 5));
      viewModel.ensureSelectedCity(const []);

      expect(viewModel.state.selectedCity, '');
      expect(viewModel.state.startDate, isNull);
      expect(viewModel.state.endDate, isNull);
    });
  });
}
