import 'package:flutter/material.dart';
import 'package:food_diary/presentation/screens/welcome_pages/config_pages.dart';
import 'package:food_diary/presentation/screens/welcome_pages/onboarding_screen.dart';
import 'package:food_diary/presentation/widgets/theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _controller = PageController();
  bool _showConfigurator = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startConfiguration() {
    setState(() {
      _showConfigurator = true;
    });
  }

  void _handleBack() {
    if (!_controller.hasClients || _controller.page == 0) {
      setState(() {
        _showConfigurator = false;
      });
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showConfigurator
            ? _ConfigurationFlow(
                key: const ValueKey('config'),
                controller: _controller,
                onBack: _handleBack,
              )
            : OnboardingScreen(
                key: const ValueKey('onboarding'),
                onFinish: _startConfiguration,
              ),
      ),
    );
  }
}

class _ConfigurationFlow extends StatelessWidget {
  const _ConfigurationFlow({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final PageController controller;
  final VoidCallback onBack;

  static final List<Widget Function(PageController)> _pages = [
    (controller) => GenderPage(controller: controller),
    (controller) => WeightPage(controller: controller),
    (controller) => HeightPage(controller: controller),
    (controller) => AgePage(controller: controller),
    (controller) => ActivityPage(controller: controller),
    (controller) => GoalPage(controller: controller),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  'Create Your Plan',
                  style: CustomTextStyles.configTitle2,
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final current = controller.hasClients
                        ? ((controller.page ?? controller.initialPage.toDouble())
                                .round() +
                            1)
                        : 1;
                    return Text(
                      '$current/${_pages.length}',
                      style: CustomTextStyles.smallLabel,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final totalSteps = _pages.length - 1;
                double value = 0;
                if (controller.hasClients && totalSteps > 0) {
                  final page = controller.page ?? controller.initialPage.toDouble();
                  value = (page / totalSteps).clamp(0, 1);
                }
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.secondaryAccent,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index](controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}
