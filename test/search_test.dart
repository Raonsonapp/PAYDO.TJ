import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/features/search/domain/search_filters.dart';
import 'package:paydo_tj/models/business_model.dart';
import 'package:paydo_tj/models/product_model.dart';
import 'package:paydo_tj/models/vacancy_model.dart';

void main() {
  group('SearchFilters', () {
    test('isEmpty true вақте ҳама майдон холист', () {
      expect(const SearchFilters().isEmpty, true);
    });

    test('isEmpty false вақте ҳадди ақал як филтр дошта бошад', () {
      expect(const SearchFilters(city: 'Душанбе').isEmpty, false);
      expect(const SearchFilters(minRating: 4).isEmpty, false);
    });

    test('copyWith бо clear-параметрҳо майдонро тоза мекунад', () {
      const filters = SearchFilters(city: 'Душанбе');
      final cleared = filters.copyWith(clearCity: true);
      expect(cleared.city, null);
    });
  });

  group('nameLower/titleLower (PHASE 17 prefix-search)', () {
    test('ProductModel.toMap дорои nameLower аст', () {
      const product = ProductModel(
        id: '1',
        sellerId: 's1',
        name: 'Телефон Samsung',
        description: '',
        price: 100,
        category: 'Phones',
        city: 'Душанбе',
      );
      expect(product.toMap()['nameLower'], 'телефон samsung');
    });

    test('BusinessModel.toMap дорои nameLower аст', () {
      const business = BusinessModel(
        id: 'b1',
        ownerId: 'o1',
        businessName: 'Дӯкони Алишер',
        city: 'Душанбе',
      );
      expect(business.toMap()['nameLower'], 'дӯкони алишер');
    });

    test('VacancyModel.toMap дорои titleLower аст', () {
      const vacancy = VacancyModel(
        id: 'v1',
        employerId: 'e1',
        employerName: 'Test',
        title: 'Дизайнер',
        description: '',
        city: 'Хуҷанд',
      );
      expect(vacancy.toMap()['titleLower'], 'дизайнер');
    });
  });
}
