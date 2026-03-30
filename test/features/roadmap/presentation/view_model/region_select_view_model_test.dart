import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/region_select_view_model.dart';

void main() {
  group('RegionSelectViewModel', () {
    test('starts empty by default', () {
      final viewModel = RegionSelectViewModel();

      expect(viewModel.state.selectedCities, isEmpty);
    });

    test('uses provided initial cities', () {
      final viewModel = RegionSelectViewModel(
        initialCities: const ['Los Angeles', 'New York'],
      );

      expect(viewModel.state.selectedCities, const ['Los Angeles', 'New York']);
    });

    test('addCity trims whitespace and ignores duplicates', () {
      final viewModel = RegionSelectViewModel(initialCities: const []);

      viewModel.addCity('  Los Angeles  ');
      viewModel.addCity('Los Angeles');
      viewModel.addCity('New York');

      expect(viewModel.state.selectedCities, const ['Los Angeles', 'New York']);
    });

    test('removeCityAt deletes only the requested city', () {
      final viewModel = RegionSelectViewModel(
        initialCities: const ['Los Angeles', 'New York'],
      );

      viewModel.removeCityAt(0);

      expect(viewModel.state.selectedCities, const ['New York']);
    });
  });
}
