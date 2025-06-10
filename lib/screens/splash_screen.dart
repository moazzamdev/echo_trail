import 'package:echo_trail/screens/login.dart';
import 'package:flutter/material.dart';

class SplashImage extends StatefulWidget {
  const SplashImage({super.key});

  @override
  State<SplashImage> createState() => _SplashImageState();
}

class _SplashImageState extends State<SplashImage>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _fade1;
  late Animation<double> _fade2;
  late Animation<double> _fade3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade1 = CurvedAnimation(parent: _controller1, curve: Curves.easeIn);
    _fade2 = CurvedAnimation(parent: _controller2, curve: Curves.easeIn);
    _fade3 = CurvedAnimation(parent: _controller3, curve: Curves.easeIn);

    _controller1.forward().then((_) {
      _controller2.forward().then((_) {
        _controller3.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 400), () {
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust widths proportionally to screen width
    final part1Width = screenWidth * 0.20;
    final part2Width = screenWidth * 0.40;
    final part3Width = screenWidth * 0.27;

    return Scaffold(
      backgroundColor: Color(0xFFE3F2FD),
      body: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fade1,
                child: Image.asset(
                  'assets/images/frame_part1.png',
                  width: part1Width,
                ),
              ),
              FadeTransition(
                opacity: _fade2,
                child: Image.asset(
                  'assets/images/frame_part2.png',
                  width: part2Width,
                ),
              ),
              FadeTransition(
                opacity: _fade3,
                child: Image.asset(
                  'assets/images/frame_part3.png',
                  width: part3Width,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
