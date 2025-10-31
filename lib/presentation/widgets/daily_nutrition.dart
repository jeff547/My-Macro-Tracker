import 'package:hive/hive.dart';

class DailyNutrition extends HiveObject {
  DailyNutrition({
    this.breakfastCalories = 0,
    this.lunchCalories = 0,
    this.dinnerCalories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
  });

  double breakfastCalories;
  double lunchCalories;
  double dinnerCalories;
  double protein;
  double carbs;
  double fats;

  double get totalCalories => breakfastCalories + lunchCalories + dinnerCalories;

  void addMeal({
    required MealType meal,
    required double calories,
    required double proteinGrams,
    required double carbGrams,
    required double fatGrams,
  }) {
    switch (meal) {
      case MealType.breakfast:
        breakfastCalories += calories;
        break;
      case MealType.lunch:
        lunchCalories += calories;
        break;
      case MealType.dinner:
        dinnerCalories += calories;
        break;
    }

    protein += proteinGrams;
    carbs += carbGrams;
    fats += fatGrams;
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
}

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}

class DailyNutritionAdapter extends TypeAdapter<DailyNutrition> {
  @override
  final int typeId = 0;

  @override
  DailyNutrition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyNutrition(
      breakfastCalories: (fields[0] as num?)?.toDouble() ?? 0,
      lunchCalories: (fields[1] as num?)?.toDouble() ?? 0,
      dinnerCalories: (fields[2] as num?)?.toDouble() ?? 0,
      protein: (fields[3] as num?)?.toDouble() ?? 0,
      carbs: (fields[4] as num?)?.toDouble() ?? 0,
      fats: (fields[5] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, DailyNutrition obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.breakfastCalories)
      ..writeByte(1)
      ..write(obj.lunchCalories)
      ..writeByte(2)
      ..write(obj.dinnerCalories)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.carbs)
      ..writeByte(5)
      ..write(obj.fats);
  }
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 1;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      default:
        return MealType.breakfast;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast:
        writer.writeByte(0);
        break;
      case MealType.lunch:
        writer.writeByte(1);
        break;
      case MealType.dinner:
        writer.writeByte(2);
        break;
    }
  }
}
