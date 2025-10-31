import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_diary/presentation/screens/main_pages/about_page.dart';
import 'package:food_diary/presentation/screens/main_pages/camera_screen.dart';
import 'package:food_diary/presentation/screens/main_pages/search_page.dart';
import 'package:food_diary/presentation/widgets/daily_nutrition.dart';
import 'package:food_diary/presentation/widgets/theme.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionDashboard extends StatefulWidget {
  const NutritionDashboard({super.key});
  static const String routeName = '/nutrition_dashboard';

  @override
  NutritionDashboardState createState() => NutritionDashboardState();
}

class NutritionDashboardState extends State<NutritionDashboard> {
  final nutritionBox = Hive.box("nutritionBox");
  final DateFormat formatter = DateFormat('MMMM d, yyyy');
  final List<Color> macroColors = const [
    AppColors.secondaryAccent,
    Color(0xFF7AA9FF),
    Color(0xFFFFB86C),
  ];

  late final double estimatedCarbs;
  late final double estimatedFats;
  late final double estimatedProtein;
  late final double estimatedCalories;
  late DailyNutrition? dailyNutrition;

  bool dataLoaded = false;
  DateTime current = DateTime.now();
  String dateString = "";

  int currentPage = 0;

  double currentCalories = 0;
  double breakfastCalories = 0;
  double lunchCalories = 0;
  double dinnerCalories = 0;
  double currentProtein = 0;
  double currentFat = 0;
  double currentCarbs = 0;

  @override
  void initState() {
    nutritionBox.watch().listen((BoxEvent event) {
      if (event.key == dateString) {
        updateDate();
      }
    });
    updateDate();
    super.initState();
    _loadData();
  }

  void updateDate() {
    setState(() {
      dateString = current.toIso8601String().split('T').first;
      dailyNutrition = nutritionBox.get(dateString);
      if (dailyNutrition == null) {
        dailyNutrition = DailyNutrition(
          breakfastCalories: 0,
          lunchCalories: 0,
          dinnerCalories: 0,
          protein: 0,
          carbs: 0,
          fats: 0,
        );
        nutritionBox.put(dateString, dailyNutrition);
      } else {
        lunchCalories = dailyNutrition?.lunchCalories.roundToDouble() ?? 0;
        dinnerCalories = dailyNutrition?.dinnerCalories.roundToDouble() ?? 0;
        breakfastCalories =
            dailyNutrition?.breakfastCalories.roundToDouble() ?? 0;

        currentProtein = dailyNutrition?.protein.roundToDouble() ?? 0;
        currentCarbs = dailyNutrition?.carbs.roundToDouble() ?? 0;
        currentFat = dailyNutrition?.fats.roundToDouble() ?? 0;

        currentCalories = dinnerCalories + lunchCalories + breakfastCalories;
      }
    });
  }

  Future<void> _loadData() async {
    estimatedCalories = await getPrefsData("estimatedCalories");
    estimatedFats = await getPrefsData("estimatedFats");
    estimatedCarbs = await getPrefsData("estimatedCarbs");
    estimatedProtein = await getPrefsData("estimatedProtein");

    setState(() {
      dataLoaded = true;
    });
  }

  Future<double> getPrefsData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    // await nutritionBox.clear();
    return prefs.getDouble(key) ?? 0;
  }

  void changeScreen(int index) {
    switch (index) {
      case 0:
        return;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CameraScreen(
                    selectedDate: dateString,
                  )),
        );
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(
              selectedDate: dateString,
            ),
          ),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!dataLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.menu,
          color: Color(0xFF4CAF50),
          size: 35,
        ),
        title: Text(
          "Your Dashboard",
          style: CustomTextStyles.dashboardText,
        ),
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        elevation: 0,
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: currentPage,
        onDestinationSelected: (index) {
          changeScreen(index);
        },
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        overlayColor: WidgetStateProperty.all(Colors.black),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: "Scan",
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              dateSelector(),
              const SizedBox(height: 24),
              _card(
                title: "Calories",
                child: SizedBox(
                  height: 250,
                  child: caloriesData(),
                ),
              ),
              const SizedBox(height: 24),
              _card(
                title: "Macronutrient Breakdown",
                child:
                    SizedBox(height: 300, child: BarChart(macronutrientData())),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
    );
  }

  Widget caloriesData() {
    final double ratio =
        estimatedCalories > 0 ? currentCalories / estimatedCalories : 0;
    final double percent = ratio.clamp(0.0, 1.0);
    final int displayPercent = (ratio * 100).clamp(0, 999).round();

    const mealColors = [
      AppColors.secondaryAccent,
      Color(0xFF7AA9FF),
      Color(0xFFFFB86C),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        value: percent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondaryAccent,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$displayPercent%",
                          style: percent <= 1.1 && percent >= .9
                              ? CustomTextStyles.percentText2
                              : CustomTextStyles.percentText,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "of goal",
                          style: CustomTextStyles.calsLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    "${currentCalories.toInt()} / ${estimatedCalories.toInt()}",
                    style: CustomTextStyles.calsText.copyWith(
                      color: AppColors.secondaryAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "kcal",
                    style: CustomTextStyles.calsLabel.copyWith(
                      color: AppColors.secondaryAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _mealRow(
                "Breakfast",
                breakfastCalories,
                accent: mealColors[0],
                showDivider: true,
              ),
              const SizedBox(height: 8),
              _mealRow(
                "Lunch",
                lunchCalories,
                accent: mealColors[1],
                showDivider: true,
              ),
              const SizedBox(height: 8),
              _mealRow(
                "Dinner",
                dinnerCalories,
                accent: mealColors[2],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mealRow(
    String label,
    double calories, {
    required Color accent,
    bool showDivider = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stackVertically = constraints.maxWidth < 160;

        Widget content;
        if (stackVertically) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: CustomTextStyles.calsText2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: _calorieAmountText(calories, accent),
              ),
            ],
          );
        } else {
          content = Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: CustomTextStyles.calsText2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _calorieAmountText(calories, accent),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            content,
            if (showDivider) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _calorieAmountText(double calories, Color accent) {
    final Color color = calories > 0 ? accent : Colors.white38;
    return RichText(
      text: TextSpan(
        style: CustomTextStyles.calsText3.copyWith(color: color),
        children: [
          TextSpan(text: calories.toInt().toString()),
          const TextSpan(text: " "),
          TextSpan(
            text: "kcal",
            style: CustomTextStyles.calsLabel.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Container dateSelector() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                current = current.subtract(const Duration(days: 1));
                updateDate();
              });
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formatter.format(current),
              style: CustomTextStyles.configBody2,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              setState(() {
                current = current.add(const Duration(days: 1));
                updateDate();
              });
            },
            icon: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  BarChartData macronutrientData() {
    final goals = <double>[estimatedProtein, estimatedCarbs, estimatedFats];
    final actuals = <double>[currentProtein, currentCarbs, currentFat];
    final highest = math
        .max(
          goals.fold<double>(0, (prev, value) => math.max(prev, value)),
          actuals.fold<double>(0, (prev, value) => math.max(prev, value)),
        )
        .ceilToDouble();
    final maxY = highest == 0 ? 10.0 : (highest * 1.2).clamp(10.0, 500.0);

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String macroName = "";
            switch (groupIndex) {
              case 0:
                macroName = "Protein";
              case 1:
                macroName = "Carbs";
              case 2:
                macroName = "Fat";
            }
            return BarTooltipItem(
              '$macroName\n',
              TextStyle(
                color: macroColors[groupIndex],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: rod.toY.round().toString(),
                  style: TextStyle(
                    color: macroColors[groupIndex],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      alignment: BarChartAlignment.spaceAround,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          if (value == 0) {
            return const FlLine(
              color: Colors.white,
              strokeWidth: 2,
            );
          }
          return FlLine(
            color: Colors.white.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 40,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  maxLines: 1,
                  value.toInt().toString(),
                  style: CustomTextStyles.barText,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 42,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return Text(
                    'Protein\n$currentProtein g',
                    style: CustomTextStyles.barText2.copyWith(
                      color: macroColors[0],
                    ),
                    textAlign: TextAlign.center,
                  );
                case 1:
                  return Text(
                    'Carbs\n$currentCarbs g',
                    style: CustomTextStyles.barText2.copyWith(
                      color: macroColors[1],
                    ),
                    textAlign: TextAlign.center,
                  );
                case 2:
                  return Text(
                    'Fat\n$currentFat g',
                    style: CustomTextStyles.barText2.copyWith(
                      color: macroColors[2],
                    ),
                    textAlign: TextAlign.center,
                  );
                default:
                  return const Text('');
              }
            },
          ),
        ),
      ),
      maxY: maxY,
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: macroColors[0].withValues(alpha: 0.25),
              toY: estimatedProtein,
            ),
            toY: currentProtein,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                macroColors[0],
                macroColors[0].withValues(alpha: 0.7),
              ],
            ),
            width: 18,
            borderRadius: BorderRadius.circular(8),
          )
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: macroColors[1].withValues(alpha: 0.25),
              toY: estimatedCarbs,
            ),
            toY: currentCarbs,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                macroColors[1],
                macroColors[1].withValues(alpha: 0.7),
              ],
            ),
            width: 18,
            borderRadius: BorderRadius.circular(8),
          )
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: macroColors[2].withValues(alpha: 0.25),
              toY: estimatedFats,
            ),
            toY: currentFat,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                macroColors[2],
                macroColors[2].withValues(alpha: 0.7),
              ],
            ),
            width: 18,
            borderRadius: BorderRadius.circular(8),
          )
        ]),
      ],
    );
  }
}
