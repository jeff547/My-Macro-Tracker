import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinish});

  final VoidCallback? onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  bool isLast = false;

  final List<Map<String, dynamic>> pages = [
    {
      'image': 'assets/images/healthy_foods.gif',
      'title': 'Welcome to Cal Counter AI',
      'desc': [
        'Take control of your nutrition',
        'Huge database: Track all your favorites',
        'Easy and Enjoyable: Reach your health goals!'
      ],
    },
    {
      'image': 'assets/images/ai.gif',
      'title': 'AI Food Recognition',
      'desc': [
        'Snap a photo to identify food items',
        'Get instant calorie and macro estimates',
        'Smarter tracking, made effortless'
      ],
    },
    {
      'image': 'assets/images/fitness.gif',
      'title': 'Track and Improve',
      'desc': [
        'Log workouts, meals, and progress',
        'Visualize your health journey',
        'Achieve your goals with insights'
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (index) {
                  setState(() => isLast = index == pages.length - 1);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          page['image']!,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (page['desc'] as List<String>)
                                .map((text) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Text(
                                        '• $text',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: Colors.greenAccent,
                dotColor: Colors.white24,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  if (isLast) {
                    widget.onFinish?.call();
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  isLast ? 'Get Started 🍽️' : 'Next',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
