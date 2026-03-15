import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jyoti_ai/theme/app_theme.dart';
import 'package:jyoti_ai/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _glowAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: JyotiTheme.background,
      ),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const OnboardingScreen(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JyotiTheme.background,
      body: Stack(
        children: [
          // Cosmic background with stars effect
          ...List.generate(30, (i) {
            final x = (i * 37 + 13) % 100 / 100.0;
            final y = (i * 53 + 7) % 100 / 100.0;
            final size = (i % 3 + 1) * 1.0;
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Opacity(
                  opacity:
                      0.2 + (_glowAnimation.value * 0.3 * ((i % 3 + 1) / 3)),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i % 5 == 0 ? JyotiTheme.goldLight : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Central glow
          Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                width: 350 * _glowAnimation.value,
                height: 350 * _glowAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      JyotiTheme.gold.withValues(
                        alpha: 0.15 * _glowAnimation.value,
                      ),
                      JyotiTheme.cosmic.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Logo + Text
          Center(
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (_, __) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Om/Sun icon
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              JyotiTheme.goldLight,
                              JyotiTheme.gold,
                              JyotiTheme.goldDark,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: JyotiTheme.gold.withValues(alpha: 0.5),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🕉️', style: TextStyle(fontSize: 48)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: JyotiTheme.spacingLg),

                  // App name
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                JyotiTheme.goldGradient.createShader(bounds),
                            child: const Text(
                              'Jyoti',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: JyotiTheme.cosmicLight,
                              letterSpacing: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom tagline
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (_, __) => Opacity(
                opacity: _logoOpacity.value * 0.6,
                child: const Column(
                  children: [
                    Text(
                      'ज्योतिषम् सुप्रभातम्',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: JyotiTheme.goldLight,
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your AI Vedic Astrologer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: JyotiTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
