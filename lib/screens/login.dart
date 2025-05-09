import 'package:echo_trail/screens/dashboard.dart';
import 'package:echo_trail/screens/sign_up.dart';
import 'package:flutter/material.dart'; // Required for SystemUiOverlayStyle

// --- Color Constants --- (Extracted from the image)
const Color kBackgroundColor = Color(0xFFE3F2FD); // Light blue background
const Color kPrimaryTextColor = Color(
  0xFF1A237E,
); // Dark blue for headings/buttons
const Color kSecondaryTextColor = Color(
  0xFF5A6A7D,
); // Darker Gray for subheadings
const Color kHintTextColor = Color(0xFF757575); // Grey for hints
const Color kButtonBlueColor = Color(0xFF10164D); // Dark blue for active button
const Color kButtonGreyColor = Color(0xFFBDBDBD); // Grey for inactive button
const Color kButtonTextLightColor = Color(
  0xFF10164D,
); // Very light grey/white for grey button text
const Color kUnderlineColor = Color(0xFF2196F3); // Bright blue for underline

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              SizedBox(height: 4),
              Container(height: 4, width: 100, color: kUnderlineColor),
              SizedBox(height: 12),
              Text(
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
                            transitionDuration: const Duration(
                              milliseconds: 900,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignUpScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
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
                      child: Text('Sign Up'),
                    ),
                  ),
                  SizedBox(width: 15),
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
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),

              // --- Login Form Section ---
              Text(
                'Login into your account',
                style: TextStyle(fontSize: 16, color: kSecondaryTextColor),
              ),
              SizedBox(height: 20),

              Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(10.0),
                // ignore: deprecated_member_use
                shadowColor: Colors.grey.withOpacity(0.3),
                child: TextField(
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
                // ignore: deprecated_member_use
                shadowColor: Colors.grey.withOpacity(0.3),
                child: TextField(
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
                  width:
                      screenWidth * 0.3, // Adjusted width (60% of screen width)
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 900),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HomeScreen(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonBlueColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text('Login'),
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
