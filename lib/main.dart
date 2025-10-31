import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_diary/presentation/screens/main_pages/dashboard.dart';
import 'package:food_diary/presentation/screens/welcome_pages/home.dart';
import 'package:food_diary/presentation/widgets/daily_nutrition.dart';
import 'package:food_diary/presentation/widgets/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();
  Hive.registerAdapter(DailyNutritionAdapter());
  Hive.registerAdapter(MealTypeAdapter());

  await Hive.openBox('nutritionBox');

  // Reset persisted user state so onboarding always runs on launch.
  // await _resetUserState();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Macro Tracker',
      theme: myTheme(),
      home: const SplashScreen(), // Change to SplashScreen
    );
  }
}

Future<void> _resetUserState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final nutritionBox = Hive.box('nutritionBox');
  await nutritionBox.clear();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkIfFirst();
  }

  Future<void> checkIfFirst() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? completed = prefs.getBool('hasCompletedOnboarding');
    final double? calories = prefs.getDouble('estimatedCalories');

    final bool shouldSkipWelcome;
    if (completed != null) {
      shouldSkipWelcome = completed;
    } else {
      shouldSkipWelcome = calories != null;
      if (shouldSkipWelcome) {
        await prefs.setBool('hasCompletedOnboarding', true);
      }
    }

    if (shouldSkipWelcome) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NutritionDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'My Macro Tracker')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
