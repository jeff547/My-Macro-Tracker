import 'package:flutter/material.dart';
import 'package:food_diary/presentation/widgets/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: Text(
          'About Cal Counter AI',
          style: CustomTextStyles.dashboardText,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Smart Nutrition Companion',
              style: CustomTextStyles.configTitle,
            ),
            const SizedBox(height: 16),
            Text(
              'Cal Counter AI helps you stay on top of your nutrition by combining powerful tracking tools with on-device food recognition.',
              style: CustomTextStyles.configBody,
            ),
            const SizedBox(height: 24),
            const _AboutHighlight(
              icon: Icons.camera_alt,
              title: 'AI-powered food scanning',
              description:
                  'Snap a photo of your meals and get instant macro estimates using an on-device model.',
            ),
            const SizedBox(height: 16),
            const _AboutHighlight(
              icon: Icons.analytics_outlined,
              title: 'Daily macro dashboard',
              description:
                  'Log meals and review progress against your personalized nutrition plan.',
            ),
            const SizedBox(height: 16),
            const _AboutHighlight(
              icon: Icons.favorite_outline,
              title: 'Tailored recommendations',
              description:
                  'Set goals, track habits, and receive feedback based on your activity level and preferences.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutHighlight extends StatelessWidget {
  const _AboutHighlight({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryAccent, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CustomTextStyles.configBody1),
                const SizedBox(height: 8),
                Text(description, style: CustomTextStyles.configBody2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
