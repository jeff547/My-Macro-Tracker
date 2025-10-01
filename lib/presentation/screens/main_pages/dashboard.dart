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
  final List<Color> macroColors = [
    Colors.orange,
    Colors.purple,
    Colors.greenAccent
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
        child: Center(
          child: Column(
            children: [
              dateSelector(),
              const SizedBox(height: 40),
              _card(
                title: "Calories",
                child: SizedBox(
                  height: 250,
                  child: caloriesData(),
                ),
              ),
              const SizedBox(height: 30),
              _card(
                title: "Macronutrient Breakdown",
                child:
                    SizedBox(height: 300, child: BarChart(macronutrientData())),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
    );
  }

  Row caloriesData() {
    double percent = currentCalories / estimatedCalories;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "  Calorie Budget:\n",
                      style: CustomTextStyles.calsLabel,
                    ),
                    TextSpan(
                      text:
                          "${currentCalories.toInt()} / ${estimatedCalories.toInt()} kcal",
                      style: CustomTextStyles.calsText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 10,
                      value: percent,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  Center(
                    child: Text(
                      "${(percent * 100).round()}%",
                      style: percent <= 1.1 && percent >= .9
                          ? CustomTextStyles.percentText2
                          : CustomTextStyles.percentText,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            const SizedBox(height: 55),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Breakfast: ",
                    style: CustomTextStyles.calsText2,
                  ),
                  TextSpan(
                    text: "${breakfastCalories.toInt()} kcal",
                    style: CustomTextStyles.calsText3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Lunch:  ",
                    style: CustomTextStyles.calsText2,
                  ),
                  TextSpan(
                    text: "${lunchCalories.toInt()} kcal",
                    style: CustomTextStyles.calsText3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Dinner:  ",
                    style: CustomTextStyles.calsText2,
                  ),
                  TextSpan(
                    text: "${dinnerCalories.toInt()} kcal",
                    style: CustomTextStyles.calsText3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container dateSelector() {
    return Container(
      height: 50,
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
          const SizedBox(width: 65),
          Text(
            formatter.format(current),
            style: CustomTextStyles.configBody2,
          ),
          const SizedBox(width: 65),
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
      width: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(35),
      child: Column(
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
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: rod.toY.round().toString(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 255, 8),
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
            color: Colors.white.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 30,
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
            reservedSize: 40,
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return Text(
                    'Protein\n$currentProtein g',
                    style: CustomTextStyles.barText2,
                    textAlign: TextAlign.center,
                  );
                case 1:
                  return Text(
                    'Carbs\n$currentCarbs g',
                    style: CustomTextStyles.barText2,
                    textAlign: TextAlign.center,
                  );
                case 2:
                  return Text('Fat\n$currentFat g',
                      style: CustomTextStyles.barText2);
                default:
                  return const Text('');
              }
            },
          ),
        ),
      ),
      maxY: 250,
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                color: const Color(0xFFB0B0B0),
                toY: estimatedProtein,
              ),
              toY: currentProtein,
              color: macroColors[0],
              width: 18,
              borderRadius: BorderRadius.circular(8))
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                color: const Color(0xFFB0B0B0),
                toY: estimatedCarbs,
              ),
              toY: currentCarbs,
              color: macroColors[2],
              width: 18,
              borderRadius: BorderRadius.circular(8))
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                color: const Color(0xFFB0B0B0),
                toY: estimatedFats,
              ),
              toY: currentFat,
              color: macroColors[1],
              width: 18,
              borderRadius: BorderRadius.circular(8))
        ]),
      ],
    );
  }
}
