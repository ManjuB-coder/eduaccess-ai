import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "image": "📚",
      "title": "Welcome to EduAccess AI",
      "subtitle":
          "An AI-powered inclusive learning platform for every student.",
    },
    {
      "image": "🎤",
      "title": "Live Lecture Capture",
      "subtitle":
          "Capture classroom lectures instantly using speech recognition.",
    },
    {
      "image": "🌍",
      "title": "Translate & Simplify",
      "subtitle": "Simplify difficult concepts and translate lessons easily.",
    },
    {
      "image": "🔊",
      "title": "Audio Learning",
      "subtitle": "Listen to lessons using smart Text-to-Speech support.",
    },
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentPage < 3) {
        currentPage++;

        controller.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        timer.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C8CF5),

      body: SafeArea(
        child: Column(
          children: [
            // 🔹 SKIP BUTTON
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 PAGEVIEW
            Expanded(
              child: PageView.builder(
                controller: controller,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemCount: pages.length,

                itemBuilder: (context, index) {
                  return buildPage(
                    emoji: pages[index]["image"],
                    title: pages[index]["title"],
                    subtitle: pages[index]["subtitle"],
                  );
                },
              ),
            ),

            // 🔹 DOT INDICATOR
            SmoothPageIndicator(
              controller: controller,
              count: 4,

              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.white,
                dotColor: Colors.white54,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 🔹 PAGE DESIGN
  Widget buildPage({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 GLASS CARD
          Container(
            height: 170,
            width: 170,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(35),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 70)),
            ),
          ),

          const SizedBox(height: 40),

          // 🔹 TITLE
          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 18),

          // 🔹 SUBTITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),

            child: Text(
              subtitle,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
