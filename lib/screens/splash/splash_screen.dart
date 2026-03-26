import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/animated_food_hero.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _quoteController;

  final String _text = 'QLess';
  late final List<Animation<double>> _letterScaleAnims;
  late final List<Animation<double>> _letterFadeAnims;

  // Pre-cached styles
  late final TextStyle _quoteStyle;
  late final TextStyle _subtitleStyle;
  late final TextStyle _loadingStyle;
  late final TextStyle _letterStyle;
  late final Color _iconColor;
  late final Color _progressColor;

  @override
  void initState() {
    super.initState();

    // --- Pre-load Google Fonts to prevent jank on first frame ---
    GoogleFonts.pendingFonts([
      GoogleFonts.righteous(),
      GoogleFonts.playfairDisplay(),
      GoogleFonts.poppins(),
    ]).then((_) {
      if (mounted) _mainController.forward();
    });

    // --- Pre-cache all styles (zero allocation per frame) ---
    _letterStyle = GoogleFonts.righteous(
      fontSize: 56,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      shadows: [
        Shadow(
          color: Colors.orange.shade900,
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    );

    _quoteStyle = GoogleFonts.playfairDisplay(
      fontSize: 20,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.95),
      letterSpacing: 0.5,
    );

    _subtitleStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.7),
      letterSpacing: 2.5,
    );

    _loadingStyle = GoogleFonts.poppins(
      color: Colors.white.withOpacity(0.6),
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 1,
    );

    _iconColor = Colors.white.withOpacity(0.6);
    _progressColor = Colors.white.withOpacity(0.7);

    // --- Only 2 controllers instead of 4 ---
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Staggered letter animations — simple easeOutBack, no elasticOut
    _letterScaleAnims = [];
    _letterFadeAnims = [];
    for (int i = 0; i < _text.length; i++) {
      final start = i * 0.15;
      final end = (start + 0.4).clamp(0.0, 1.0);

      _letterScaleAnims.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
      );

      _letterFadeAnims.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(start, (start + 0.25).clamp(0.0, 1.0),
                curve: Curves.easeIn),
          ),
        ),
      );
    }

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _quoteController.forward();
      }
    });

    // Navigate after splash
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEF6C00), // orange.shade800
              Color(0xFFBF360C), // deepOrange.shade900
              Color(0xFFB71C1C), // red.shade900
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo area
              SizedBox(
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dynamic rotating food icon
                    const AnimatedFoodHero(size: 80.0),
                    const SizedBox(height: 20),
                    // Animated text
                    RepaintBoundary(child: _buildAnimatedText()),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Quote
              FadeTransition(
                opacity: _quoteController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _quoteController,
                    curve: Curves.easeOut,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          '"Skip the queue, savor the flavor"',
                          style: _quoteStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant,
                                color: _iconColor, size: 16),
                            const SizedBox(width: 8),
                            Text('Delicious food, zero wait',
                                style: _subtitleStyle),
                            const SizedBox(width: 8),
                            Icon(Icons.restaurant,
                                color: _iconColor, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Loading indicator
              FadeTransition(
                opacity: _quoteController,
                child: Column(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_progressColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Preparing your experience...',
                        style: _loadingStyle),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (index) {
            final scale = _letterScaleAnims[index].value;
            final opacity = _letterFadeAnims[index].value;

            if (opacity < 0.01) return const SizedBox(width: 0);

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(_text[index], style: _letterStyle),
              ),
            );
          }),
        );
      },
    );
  }
}
