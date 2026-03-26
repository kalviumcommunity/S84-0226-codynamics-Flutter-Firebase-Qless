import 'package:flutter/material.dart';
import 'animated_food_hero.dart';

class FoodLoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;
  final ScrollPhysics? physics;

  const FoodLoadingIndicator({
    super.key,
    this.size = 60.0,
    this.message,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final loadingContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFoodHero(size: size),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    // If it's meant to be in a scrollable area (like ListView replacement), 
    // we center it directly.
    return Center(child: loadingContent);
  }
}
