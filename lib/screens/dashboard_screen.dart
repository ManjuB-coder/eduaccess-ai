import 'package:flutter/material.dart';

import 'audio_learning_screen.dart';
import 'chatbot_screen.dart';
import 'live_lecture_screen.dart';
import 'profile_screen.dart';
import 'simplify_screen.dart';
import 'translate_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // 🔹 FEATURE CARD
  Widget featureButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B9BFF), Color(0xFF5B7BFE)],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),

              blurRadius: 8,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // 🔹 ICON
              Container(
                height: 36,
                width: 36,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),

                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: Colors.white, size: 18),
              ),

              const SizedBox(height: 8),

              Text(
                title,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.white,

                  fontSize: 12,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "Open Tool",

                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),

                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),

      body: SafeArea(
        child: Column(
          children: [
            // 🔷 HEADER
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B9BFF), Color(0xFF5B7BFE)],

                  begin: Alignment.topLeft,

                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(38),

                  bottomRight: Radius.circular(38),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Hello Student 👋",

                            style: TextStyle(
                              fontSize: 26,

                              fontWeight: FontWeight.bold,

                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "Welcome to EduAccess AI",

                            style: TextStyle(
                              fontSize: 14,

                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      // 👤 PROFILE BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },

                        child: Container(
                          height: 50,
                          width: 50,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.person,

                            color: Colors.white,

                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 🔍 SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70, size: 20),

                        SizedBox(width: 12),

                        Text(
                          "Search learning tools...",

                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 🔷 TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    "Accessibility Tools",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Explore",

                    style: TextStyle(
                      color: Color(0xFF5B7BFE),

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 🔷 FEATURE GRID
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),

                mainAxisSpacing: 12,
                crossAxisSpacing: 12,

                // ✅ SMALLER CARDS
                childAspectRatio: 1.7,

                children: [
                  featureButton(
                    context,

                    "Live Lecture",

                    Icons.mic_rounded,

                    const LiveLectureScreen(),
                  ),

                  featureButton(
                    context,

                    "Simplify",

                    Icons.menu_book_rounded,

                    const SimplifyScreen(),
                  ),

                  featureButton(
                    context,

                    "Translate",

                    Icons.translate_rounded,

                    const TranslateScreen(),
                  ),

                  featureButton(
                    context,

                    "Audio Learning",

                    Icons.volume_up_rounded,

                    const AudioLearningScreen(),
                  ),

                  featureButton(
                    context,

                    "AI Chatbot",

                    Icons.smart_toy_rounded,

                    const ChatbotScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
