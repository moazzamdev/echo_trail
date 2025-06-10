// echotrail_frontend\echo_trail\lib\screens\sign_up.dart
import 'package:echo_trail/screens/login.dart';
import 'package:echo_trail/services/auth_service.dart';
import 'package:echo_trail/screens/dashboard.dart';
import 'package:flutter/material.dart';

const Color kBackgroundColor = Color(0xFFE3F2FD);
const Color kPrimaryTextColor = Color(0xFF1A237E);
const Color kSecondaryTextColor = Color(0xFF5A6A7D);
const Color kHintTextColor = Color(0xFF757575);
const Color kButtonBlueColor = Color(0xFF10164D);
const Color kButtonGreyColor = Color(0xFFBDBDBD);
const Color kButtonTextLightColor = Color(0xFF10164D);
const Color kUnderlineColor = Color(0xFF2196F3);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;

  void handleSignUp() async {
    setState(() => isLoading = true);

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      setState(() => isLoading = false);
      return;
    }

    // Use AuthService to handle registration
    final success = await auth.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Attempt login
      final loginSuccess = await auth.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (loginSuccess) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 900),
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }

    if (!mounted) return;
    setState(() => isLoading = false);
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
                "Let's get you Started!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor,
                ),
              ),
              SizedBox(height: 4),
              Container(height: 4, width: 150, color: kUnderlineColor),
              SizedBox(height: 12),
              Text(
                'Sign Up using your Prefered Option.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonBlueColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Text('Sign Up'),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 900),
                            pageBuilder: (context, animation, secondaryAnimation) =>
                            const LoginScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kButtonGreyColor,
                        foregroundColor: kButtonTextLightColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Create your account',
                style: TextStyle(fontSize: 16, color: kSecondaryTextColor),
              ),
              SizedBox(height: 20),
              Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10.0),
                shadowColor: Colors.grey.withOpacity(0.3),
                child: TextField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'NAME',
                    hintStyle: TextStyle(
                      color: kHintTextColor,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10.0),
                shadowColor: Colors.grey.withOpacity(0.3),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'EMAIL',
                    hintStyle: TextStyle(
                      color: kHintTextColor,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10.0),
                shadowColor: Colors.grey.withOpacity(0.3),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'PASSWORD',
                    hintStyle: TextStyle(
                      color: kHintTextColor,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.3,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonBlueColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(isLoading ? 'Signing up...' : 'Sign Up'),
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