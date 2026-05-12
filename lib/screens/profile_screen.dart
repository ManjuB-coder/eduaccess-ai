import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Student";
  String userEmail = "student@gmail.com";

  int savedNotesCount = 12;
  int savedTranslationsCount = 8;

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  // 📦 LOAD USER DATA
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString("name") ?? "Student";

      userEmail = prefs.getString("email") ?? "student@gmail.com";
    });
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("isLoggedIn", false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(builder: (context) => const LoginScreen()),

      (route) => false,
    );
  }

  // 🎨 PROFILE TILE
  Widget profileTile({
    required IconData icon,

    required String title,

    required String subtitle,

    Color color = const Color(0xFF5B7BFE),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),

              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7BFE),

        elevation: 0,

        title: const Text(
          "Profile",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // 👤 PROFILE CARD
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B9BFF), Color(0xFF5B7BFE)],
                ),

                borderRadius: BorderRadius.circular(30),
              ),

              child: Column(
                children: [
                  // 👤 PHOTO
                  const CircleAvatar(
                    radius: 50,

                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.person,

                      size: 55,

                      color: Color(0xFF5B7BFE),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 👤 NAME
                  Text(
                    userName,

                    style: const TextStyle(
                      fontSize: 26,

                      fontWeight: FontWeight.bold,

                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 📧 EMAIL
                  Text(
                    userEmail,

                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📊 STATS
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),

                          blurRadius: 8,
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        const Icon(
                          Icons.bookmark,

                          color: Color(0xFF5B7BFE),

                          size: 34,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          savedNotesCount.toString(),

                          style: const TextStyle(
                            fontSize: 24,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text("Saved Notes"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),

                          blurRadius: 8,
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        const Icon(
                          Icons.translate,

                          color: Colors.orange,

                          size: 34,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          savedTranslationsCount.toString(),

                          style: const TextStyle(
                            fontSize: 24,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text("Translations"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ⚙ SETTINGS
            profileTile(
              icon: Icons.settings,

              title: "App Settings",

              subtitle: "Manage application settings",
            ),

            profileTile(
              icon: Icons.dark_mode,

              title: "Dark Mode",

              subtitle: "Enable dark appearance",

              color: Colors.black87,
            ),

            profileTile(
              icon: Icons.help_outline,

              title: "Help & Support",

              subtitle: "Contact support team",

              color: Colors.green,
            ),

            profileTile(
              icon: Icons.info_outline,

              title: "About App",

              subtitle: "EduAccess AI v1.0",

              color: Colors.orange,
            ),

            const SizedBox(height: 25),

            // 🚪 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(
                onPressed: logout,

                icon: const Icon(Icons.logout),

                label: const Text("Logout"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
