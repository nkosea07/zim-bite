import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/meal_builder_models.dart';

class MealPlateWidget extends StatelessWidget {
  final List<PlateIngredient> ingredients;
  final bool isHovering;
  final void Function(String componentId) onRemove;
  final void Function(MealComponent data) onAccept;

  const MealPlateWidget({
    super.key,
    required this.ingredients,
    this.isHovering = false,
    required this.onRemove,
    required this.onAccept,
  });

  String _emojiForCategory(String category) {
    switch (category) {
      case 'Proteins':
        return '🥩';
      case 'Carbs':
        return '🍚';
      case 'Vegetables':
        return '🥦';
      case 'Drinks':
        return '🥤';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<MealComponent>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hovering
                ? AppColors.brandOrange.withValues(alpha: 0.08)
                : Colors.grey.shade50,
            border: Border.all(
              color: hovering ? AppColors.brandOrange : Colors.grey.shade300,
              width: hovering ? 3 : 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Inner ring
              Center(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Empty state
              if (ingredients.isEmpty)
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🍽️', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 4),
                      Text(
                        'Long-press &\ndrag here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              // Ingredients using golden-angle placement
              ...List.generate(ingredients.length, (i) {
                final ing = ingredients[i];
                final pos = _goldenAnglePosition(i, ingredients.length, 70);
                return Positioned(
                  left: 100 + pos.dx - 20,
                  top: 100 + pos.dy - 20,
                  child: GestureDetector(
                    onTap: () => onRemove(ing.componentId),
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                _emojiForCategory(ing.category),
                                style: const TextStyle(fontSize: 28),
                              ),
                              if (ing.quantity > 1)
                                Positioned(
                                  top: -4,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandOrange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${ing.quantity}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            ing.name,
                            style: const TextStyle(fontSize: 8),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Offset _goldenAnglePosition(int index, int total, double radius) {
    if (total == 1) return Offset.zero;
    const goldenAngle = 137.508 * pi / 180;
    final angle = index * goldenAngle;
    final r = sqrt((index + 1) / (total + 1)) * radius;
    return Offset(r * cos(angle), r * sin(angle));
  }
}
