// echotrail_frontend\echo_trail\lib\screens\login.dart

import 'package:echo_trail/screens/dashboard.dart';
import 'package:echo_trail/screens/sign_up.dart';
import 'package:echo_trail/services/auth_service.dart';
import 'package:flutter/material.dart';

// --- Color Constants ---
const Color kBackgroundColor = Color(0xFFE3F2FD);
const Color kPrimaryTextColor = Color(0xFF1A237E);
const Color kSecondaryTextColor = Color(0xFF5A6A7D);
const Color kHintTextColor = Color(0xFF757575);
const Color kButtonBlueColor = Color(0xFF10164D);
const Color kButtonGreyColor = Color(0xFFBDBDBD);
const Color kButtonTextLightColor = Color(0xFF10164D);
const Color kUnderlineColor = Color(0xFF2196F3);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);

    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(height: 4, width: 100, color: kUnderlineColor),
              const SizedBox(height: 12),
              const Text(
                'Login to your account.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: screenHeight * 0.04),

              // --- Sign Up / Login Tabs ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 900),
                            pageBuilder: (_, __, ___) => const SignUpScreen(),
                            transitionsBuilder: (_, animation, __, child) =>
                                FadeTransition(opacity: animation, child: child),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonGreyColor,
                        foregroundColor: kButtonTextLightColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonBlueColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),

              // --- Login Form Section ---
              const Text(
                'Login into your account',
                style: TextStyle(fontSize: 16, color: kSecondaryTextColor),
              ),
              const SizedBox(height: 20),

              // --- Email Field ---
              Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10.0),
                shadowColor: Colors.grey.withAlpha((0.3 * 255).toInt()),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'EMAIL',
                    hintStyle: const TextStyle(
                      color: kHintTextColor,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Password Field ---
              Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10.0),
                shadowColor: Colors.grey.withAlpha((0.3 * 255).toInt()),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'PASSWORD',
                    hintStyle: const TextStyle(
                      color: kHintTextColor,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // --- Login Button ---
              Center(
                child: SizedBox(
                  width: screenWidth * 0.5,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonBlueColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(isLoading ? 'Logging in...' : 'Login'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
