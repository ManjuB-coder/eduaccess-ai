import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String gender = "Male";

  // 🔥 CREATE ACCOUNT USING FIREBASE
  void createAccount() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        dobController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      // 🔥 CREATE FIREBASE USER
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // 🔥 SAVE USER DATA TO FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "firstName": firstNameController.text.trim(),
            "lastName": lastNameController.text.trim(),
            "dob": dobController.text.trim(),
            "phone": phoneController.text.trim(),
            "email": emailController.text.trim(),
            "gender": gender,
          });

      // ✅ SAVE LOGIN STATUS
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Signup failed";

      if (e.code == 'email-already-in-use') {
        message = "Email already exists";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ✨ CUSTOM FIELD
  Widget customField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool confirmPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: TextField(
        controller: controller,

        obscureText: isPassword
            ? (confirmPassword ? obscureConfirmPassword : obscurePassword)
            : false,

        decoration: InputDecoration(
          hintText: hint,

          prefixIcon: Icon(icon, color: const Color(0xFF5B7BFE)),

          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    confirmPassword
                        ? (obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility)
                        : (obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                  ),

                  onPressed: () {
                    setState(() {
                      if (confirmPassword) {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      } else {
                        obscurePassword = !obscurePassword;
                      }
                    });
                  },
                )
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),

      body: Stack(
        children: [
          // 🔵 TOP DESIGN
          Container(
            height: 270,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B9BFF), Color(0xFF5B7BFE)],

                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 🎓 ICON
                  Container(
                    height: 85,
                    width: 85,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Fill your details below",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const SizedBox(height: 35),

                  // 📦 FORM CARD
                  Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: customField(
                                controller: firstNameController,
                                hint: "First Name",
                                icon: Icons.person_outline,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: customField(
                                controller: lastNameController,
                                hint: "Last Name",
                                icon: Icons.person_outline,
                              ),
                            ),
                          ],
                        ),

                        customField(
                          controller: dobController,
                          hint: "Date of Birth",
                          icon: Icons.calendar_month_outlined,
                        ),

                        customField(
                          controller: phoneController,
                          hint: "Phone Number",
                          icon: Icons.phone_outlined,
                        ),

                        // 👤 GENDER
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),

                          margin: const EdgeInsets.only(bottom: 18),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: gender,
                              isExpanded: true,

                              items: const [
                                DropdownMenuItem(
                                  value: "Male",
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                  value: "Female",
                                  child: Text("Female"),
                                ),
                                DropdownMenuItem(
                                  value: "Other",
                                  child: Text("Other"),
                                ),
                              ],

                              onChanged: (value) {
                                setState(() {
                                  gender = value!;
                                });
                              },
                            ),
                          ),
                        ),

                        customField(
                          controller: emailController,
                          hint: "Email Address",
                          icon: Icons.email_outlined,
                        ),

                        customField(
                          controller: passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        customField(
                          controller: confirmPasswordController,
                          hint: "Confirm Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          confirmPassword: true,
                        ),

                        const SizedBox(height: 15),

                        // 🔥 BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 58,

                          child: ElevatedButton(
                            onPressed: createAccount,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B7BFE),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },

                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Color(0xFF5B7BFE),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
