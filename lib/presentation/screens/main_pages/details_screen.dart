import 'package:flutter/material.dart';
import 'package:food_diary/presentation/widgets/daily_nutrition.dart';
import 'package:food_diary/presentation/widgets/fetch_food.dart';
import 'package:food_diary/presentation/widgets/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Nutrition extends StatefulWidget {
  const Nutrition({
    super.key,
    required this.fdcId,
    required this.selectedDate,
    this.foodName,
  });

  final int fdcId;
  final String selectedDate;
  final String? foodName;

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition> {
  late Future<FoodItem?> _loadFoodFuture;
  MealType _selectedMeal = MealType.breakfast;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFoodFuture = fetchFoodDetails(widget.fdcId);
  }

  Future<void> _logMeal(FoodItem item) async {
    setState(() => _saving = true);
    try {
      final box = Hive.box('nutritionBox');
      final existing = box.get(widget.selectedDate) as DailyNutrition? ??
          DailyNutrition();
      existing.addMeal(
        meal: _selectedMeal,
        calories: item.calories,
        proteinGrams: item.protein,
        carbGrams: item.carbs,
        fatGrams: item.fats,
      );
      await box.put(widget.selectedDate, existing);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} added to ${_selectedMeal.label}.',
          ),
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.foodName ?? 'Food Details',
          style: CustomTextStyles.dashboardText,
        ),
      ),
      body: FutureBuilder<FoodItem?>(
        future: _loadFoodFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load nutrition details.',
                style: CustomTextStyles.configBody2,
              ),
            );
          }
          final food = snapshot.data;
          if (food == null) {
            return Center(
              child: Text(
                'No data available for this food.',
                style: CustomTextStyles.configBody2,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: CustomTextStyles.configTitle3),
                const SizedBox(height: 8),
                if (food.servingSize != null)
                  Text(
                    'Serving: ${food.servingSize}',
                    style: CustomTextStyles.smallLabel,
                  ),
                const SizedBox(height: 24),
                _NutritionRow(
                  label: 'Calories',
                  value: '${_formatNumber(food.calories, 0)} kcal',
                ),
                const SizedBox(height: 12),
                _NutritionRow(
                  label: 'Protein',
                  value: '${_formatNumber(food.protein)} g',
                ),
                const SizedBox(height: 12),
                _NutritionRow(
                  label: 'Carbs',
                  value: '${_formatNumber(food.carbs)} g',
                ),
                const SizedBox(height: 12),
                _NutritionRow(
                  label: 'Fat',
                  value: '${_formatNumber(food.fats)} g',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Log to meal:',
                      style: CustomTextStyles.configBody1,
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<MealType>(
                      value: _selectedMeal,
                      dropdownColor: AppColors.card,
                      items: MealType.values
                          .map(
                            (meal) => DropdownMenuItem(
                              value: meal,
                              child: Text(meal.label),
                            ),
                          )
                          .toList(),
                      onChanged: (meal) {
                        if (meal != null) {
                          setState(() {
                            _selectedMeal = meal;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => _logMeal(food),
                    child: _saving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add to Diary'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: CustomTextStyles.calsText2),
        Text(value, style: CustomTextStyles.calsText3),
      ],
    );
  }
}

String _formatNumber(double value, [int fractionDigits = 1]) {
  if (value == 0) return '0';
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(fractionDigits);
}
