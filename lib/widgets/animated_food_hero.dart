import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFoodHero extends StatefulWidget {
  final double size;

  const AnimatedFoodHero({super.key, this.size = 80.0});

  @override
  State<AnimatedFoodHero> createState() => _AnimatedFoodHeroState();
}

class _AnimatedFoodHeroState extends State<AnimatedFoodHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _rotationAnimation;

  final List<IconData> _foodIcons = [
    Icons.fastfood,
    Icons.local_pizza,
    Icons.ramen_dining,
    Icons.icecream,
    Icons.lunch_dining,
    Icons.bakery_dining,
    Icons.local_cafe,
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: false);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutSine),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.5 && _controller.status == AnimationStatus.forward) {
         // Switch halfway through 
      }
    });

    _startIconTimer();
  }

  void _startIconTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _foodIcons.length;
      });
      _startIconTimer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Floating effect using sin wave
        final floatOffset = math.sin(_controller.value * 2 * math.pi) * 15.0;
        // Subtle rocking
        final rotation = math.sin(_controller.value * 2 * math.pi) * 0.15;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              padding: EdgeInsets.all(widget.size * 0.4), // proportional padding
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _foodIcons[_currentIndex],
                  key: ValueKey<int>(_currentIndex),
                  size: widget.size,
                  color: Colors.orange.shade600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
