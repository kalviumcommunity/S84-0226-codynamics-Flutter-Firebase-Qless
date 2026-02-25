import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _letterController;
  late AnimationController _steamController;
  late AnimationController _quoteController;
  late AnimationController _pulseController;
  
  final String _text = 'QLess';
  final List<Animation<double>> _letterAnimations = [];
  final List<Animation<double>> _letterFadeAnimations = [];
  
  @override
  void initState() {
    super.initState();
    
    // Letter animation controller - each letter appears sequentially
    _letterController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Steam animation controller - continuous
    _steamController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    // Quote fade in controller
    _quoteController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Pulse controller for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // Create staggered animations for each letter
    for (int i = 0; i < _text.length; i++) {
      final startTime = i / _text.length;
      final endTime = (i + 1) / _text.length;
      
      // Scale animation (letter appears)
      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _letterController,
            curve: Interval(startTime, endTime, curve: Curves.elasticOut),
          ),
        ),
      );
      
      // Fade animation (light to dark effect)
      _letterFadeAnimations.add(
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.3), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 25),
        ]).animate(
          CurvedAnimation(
            parent: _letterController,
            curve: Interval(startTime, math.min(endTime + 0.2, 1.0)),
          ),
        ),
      );
    }
    
    // Start animations
    _letterController.forward().then((_) {
      _quoteController.forward();
    });
    
    // Navigate after splash
    Future.delayed(const Duration(milliseconds: 4500), () {
      widget.onComplete();
    });
  }
  
  @override
  void dispose() {
    _letterController.dispose();
    _steamController.dispose();
    _quoteController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade800,
              Colors.deepOrange.shade900,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Main logo area with steam effect
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Steam particles
                    ...List.generate(8, (index) => _buildSteamParticle(index)),
                    
                    // Food icons around
                    _buildFoodIcons(),
                    
                    // Plate decoration
                    _buildPlateDecoration(),
                    
                    // Main text with glow
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3 + (_pulseController.value * 0.2)),
                                blurRadius: 30 + (_pulseController.value * 20),
                                spreadRadius: 5 + (_pulseController.value * 10),
                              ),
                            ],
                          ),
                          child: _buildAnimatedText(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Quote
              FadeTransition(
                opacity: _quoteController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
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
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant, color: Colors.white.withOpacity(0.6), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Delicious food, zero wait',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.restaurant, color: Colors.white.withOpacity(0.6), size: 16),
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
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Preparing your experience...',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
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
      animation: _letterController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (index) {
            final scale = _letterAnimations[index].value;
            final opacity = _letterFadeAnimations[index].value;
            
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Text(
                  _text[index],
                  style: GoogleFonts.righteous(
                    fontSize: 76,
                    fontWeight: FontWeight.w400,
                    color: Color.lerp(
                      Colors.yellow.shade200,
                      Colors.white,
                      opacity.clamp(0.0, 1.0),
                    ),
                    shadows: [
                      Shadow(
                        color: Colors.orange.shade900,
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                      Shadow(
                        color: Colors.yellow.withOpacity(0.5 * opacity),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
  
  Widget _buildSteamParticle(int index) {
    final random = math.Random(index);
    final xOffset = (random.nextDouble() - 0.5) * 120;
    final delay = random.nextDouble();
    final size = 8 + random.nextDouble() * 12;
    
    return AnimatedBuilder(
      animation: _steamController,
      builder: (context, child) {
        final progress = ((_steamController.value + delay) % 1.0);
        final yOffset = -progress * 150;
        final opacity = (1 - progress) * 0.6;
        final scale = 0.5 + progress * 1.5;
        
        return Transform.translate(
          offset: Offset(xOffset + math.sin(progress * math.pi * 2) * 15, -60 + yOffset),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPlateDecoration() {
    return AnimatedBuilder(
      animation: _letterController,
      builder: (context, child) {
        final progress = _letterController.value;
        
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: const Offset(0, 45),
            child: Container(
              width: 280,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.shade700.withOpacity(0.3),
                    Colors.deepOrange.shade900.withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFoodIcons() {
    final icons = [
      Icons.local_pizza,
      Icons.ramen_dining,
      Icons.fastfood,
      Icons.icecream,
      Icons.local_cafe,
      Icons.rice_bowl,
    ];
    
    return AnimatedBuilder(
      animation: Listenable.merge([_letterController, _pulseController]),
      builder: (context, child) {
        final progress = _letterController.value;
        
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Stack(
            children: List.generate(icons.length, (index) {
              final angle = (index / icons.length) * math.pi * 2 - math.pi / 2;
              final radius = 140.0;
              final x = math.cos(angle) * radius;
              final y = math.sin(angle) * radius;
              
              return Transform.translate(
                offset: Offset(x, y),
                child: Transform.scale(
                  scale: 0.9 + (_pulseController.value * 0.1),
                  child: Icon(
                    icons[index],
                    color: Colors.white.withOpacity(0.15 + (_pulseController.value * 0.1)),
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
