import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeLogo;
  late Animation<double> _scaleLogo;
  late Animation<double> _glowLogo;
  late Animation<double> _fadeText;
  late Animation<Offset> _slideText;
  late Animation<double> _fadeLoading;

  @override
  void initState() {
    super.initState();

    // MAIN CONTROLLER
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // LOGO FADE IN
    _fadeLogo = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut))
    );

    // LOGO SCALE (POP UP + BOUNCE)
    _scaleLogo = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
    );

    // LOGO GLOW (PULSE EFFECT)
    _glowLogo = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeInOut))
    );

    // TEXT (Fade + Slide)
    _fadeText = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeIn))
    );

    _slideText = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut))
    );

    // LOADING INDICATOR
    _fadeLoading = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0))
    );

    // START ANIMATION
    _controller.forward();

    // Move to next screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // =========================
            //      LOGO ANIMATION
            // =========================
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Opacity(
                  opacity: _fadeLogo.value,
                  child: Transform.scale(
                    scale: _scaleLogo.value,
                    child: Container(
                      padding: EdgeInsets.all(_glowLogo.value),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 255, 102).withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 217, 0, 255).withValues(alpha: 0.03),
                            blurRadius: _glowLogo.value,
                            spreadRadius: _glowLogo.value / 2,
                          )
                        ],
                      ),
                      child: SizedBox(
                        height: 150,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // =========================
            //   TEXT SLIDE + FADE
            // =========================
            FadeTransition(
              opacity: _fadeText,
              child: SlideTransition(
                position: _slideText,
                child: const Text(
                  "Sistem Informasi Peternakan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Color(0xFF6A3BF8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // LOADING INDICATOR FADE
            // =========================
            FadeTransition(
              opacity: _fadeLoading,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF6A3BF8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
