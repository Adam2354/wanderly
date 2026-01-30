import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFB8E6F5), // Light blue background
          child: Stack(
            children: [
              // Decorative circle at the bottom
              Positioned(
                bottom: -150,
                left: -80,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/images/Circle.png',
                    width: 500,
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Adjustable spacing above logo
                    SizedBox(height: 50),
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
                    SizedBox(
                      height: 100,
                    ), // Atur nilai ini untuk spacing bawah logo
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
