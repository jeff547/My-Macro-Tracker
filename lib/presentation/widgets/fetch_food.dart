import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FoodApiException implements Exception {
  FoodApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FoodItem {
  const FoodItem({
    required this.fdcId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.servingSize,
    this.brandOwner,
  });

  final int fdcId;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String? servingSize;
  final String? brandOwner;
}

const _baseHost = 'api.nal.usda.gov';
const _searchPath = '/fdc/v1/foods/search';
const _detailsPath = '/fdc/v1/food/';

String _apiKey() {
  final key = dotenv.env['API_KEY'];
  if (key == null || key.isEmpty) {
    throw FoodApiException(
      'USDA API key not found.',
    );
  }
  return key;
}

Future<Map<String, int>> fetchFoodList(String query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return {};
  }

  final uri = Uri.https(
    _baseHost,
    _searchPath,
    {
      'api_key': _apiKey(),
      'query': trimmed,
      'pageSize': '25',
      'sortBy': 'dataType.keyword',
      'sortOrder': 'asc',
    },
  );

  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw FoodApiException(
      'Food search failed (${response.statusCode}): ${response.reasonPhrase}',
    );
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final foods = data['foods'] as List<dynamic>? ?? [];

  return {
    for (final item in foods)
      _formatFoodName(item as Map<String, dynamic>):
          (item['fdcId'] as num?)?.toInt() ?? 0,
  }..removeWhere((_, value) => value == 0);
}

Future<FoodItem?> fetchFoodDetails(int id) async {
  final uri = Uri.https(
    _baseHost,
    '$_detailsPath$id',
    {'api_key': _apiKey()},
  );

  final response = await http.get(uri);
  if (response.statusCode == 404) {
    return null;
  }
  if (response.statusCode != 200) {
    throw FoodApiException(
      'Failed to retrieve nutrition details (${response.statusCode}).',
    );
  }

  final payload = jsonDecode(response.body) as Map<String, dynamic>;
  final nutrients = (payload['foodNutrients'] as List<dynamic>? ?? [])
      .cast<Map<String, dynamic>>();
  final labelNutrients =
      (payload['labelNutrients'] as Map<String, dynamic>?) ?? const {};

  double _labelValue(String key) {
    final entry = labelNutrients[key];
    if (entry is Map<String, dynamic>) {
      final value = entry['value'];
      if (value is num) {
        return value.toDouble();
      }
    } else if (entry is num) {
      return entry.toDouble();
    }
    return 0;
  }

  double _nutrientWithFallback({
    required List<String> names,
    required List<String> numbers,
    required List<int> ids,
    required String labelKey,
  }) {
    final extracted = _extractNutrient(
      nutrients,
      names: names,
      numbers: numbers,
      ids: ids,
    );
    if (extracted > 0) {
      return extracted;
    }
    return _labelValue(labelKey);
  }

  return FoodItem(
    fdcId: id,
    name: _formatFoodName(payload),
    calories: _nutrientWithFallback(
      names: const ['energy', 'calorie'],
      numbers: const ['1008', '208'],
      ids: const [1008],
      labelKey: 'calories',
    ),
    protein: _nutrientWithFallback(
      names: const ['protein'],
      numbers: const ['1003', '203'],
      ids: const [1003],
      labelKey: 'protein',
    ),
    carbs: _nutrientWithFallback(
      names: const ['carbohydrate, by difference', 'carbohydrate'],
      numbers: const ['1005', '205'],
      ids: const [1005],
      labelKey: 'carbohydrates',
    ),
    fats: _nutrientWithFallback(
      names: const ['total lipid', 'fat'],
      numbers: const ['1004', '204'],
      ids: const [1004],
      labelKey: 'fat',
    ),
    servingSize: _servingDescription(payload),
    brandOwner: payload['brandOwner'] as String?,
  );
}

String _formatFoodName(Map<String, dynamic> data) {
  final description =
      ((data['description'] ?? data['lowercaseDescription']) as String? ?? '')
          .trim();
  final brand = (data['brandOwner'] as String? ?? '').trim();
  if (brand.isEmpty) {
    return description.isEmpty ? 'Unknown Food' : description;
  }
  final base = description.isEmpty ? 'Unknown Food' : description;
  return '$base ($brand)';
}

double _extractNutrient(
  List<Map<String, dynamic>> nutrients, {
  required List<String> names,
  required List<String> numbers,
  List<int> ids = const [],
}) {
  final targetNames = {
    for (final name in names) name.toLowerCase(),
  };
  final targetNumbers = {
    for (final number in numbers) number.toLowerCase(),
  };
  final targetIds = ids.toSet();

  for (final nutrient in nutrients) {
    final nutrientName =
        (nutrient['nutrientName'] as String? ?? '').toLowerCase();
    final nutrientNumber =
        (nutrient['nutrientNumber'] as String? ?? '').toLowerCase();
    final nutrientId = (nutrient['nutrientId'] as num?)?.toInt();

    final matchesName =
        targetNames.any((name) => nutrientName.contains(name));
    final matchesNumber = targetNumbers.contains(nutrientNumber);
    final matchesId = nutrientId != null && targetIds.contains(nutrientId);

    if (matchesName || matchesNumber || matchesId) {
      final value = nutrient['value'] ?? nutrient['amount'];
      if (value is num) {
        return value.toDouble();
      }
    }
  }
  return 0;
}

String? _servingDescription(Map<String, dynamic> data) {
  final size = (data['servingSize'] as num?)?.toDouble();
  final unit = data['servingSizeUnit'] as String?;
  if (size != null && unit != null && unit.isNotEmpty) {
    return '${size.toStringAsFixed(size.truncateToDouble() == size ? 0 : 1)} $unit';
  }

  final portions = data['foodPortions'] as List<dynamic>? ?? [];
  if (portions.isNotEmpty) {
    final portion = portions.first as Map<String, dynamic>;
    final modifier = portion['modifier'] as String?;
    final gramWeight = (portion['gramWeight'] as num?)?.toDouble();
    if (modifier != null && gramWeight != null) {
      return '$modifier (${gramWeight.toStringAsFixed(0)} g)';
    }
  }

  return null;
}
