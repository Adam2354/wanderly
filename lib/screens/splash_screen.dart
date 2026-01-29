import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Navigate to home screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFB8E6F5), // Light blue background
        child: Stack(
          children: [
            // Decorative circles at the bottom
            Positioned(
              bottom: -100,
              left: -50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/Circle.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: 80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/images/Circle.png',
                    width: 320,
                    height: 320,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -30,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/Circle.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/logo_wanderly.png',
                        width: 180,
                        height: 180,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // App Name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Wanderly',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'by Harisenin.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
