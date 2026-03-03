import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/meal_builder_models.dart';

class DraggableComponentCard extends StatelessWidget {
  final MealComponent component;
  final int quantity;
  final bool isDragMode;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const DraggableComponentCard({
    super.key,
    required this.component,
    required this.quantity,
    required this.isDragMode,
    required this.onIncrement,
    required this.onDecrement,
  });

  String get _emoji {
    switch (component.category) {
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
    final card = _buildCard();

    if (!isDragMode) return card;

    return LongPressDraggable<MealComponent>(
      data: component,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.brandOrange, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 4),
              Text(
                component.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  Widget _buildCard() {
    final isSelected = quantity > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.brandOrange : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Text(_emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              component.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${component.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.brandOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${component.calories} cal',
              style: const TextStyle(fontSize: 11, color: AppColors.warmGrey500),
            ),
            const Spacer(),
            quantity == 0
                ? GestureDetector(
                    onTap: onIncrement,
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QtyBtn(icon: Icons.remove, onTap: onDecrement),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _QtyBtn(icon: Icons.add, onTap: onIncrement),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.brandOrange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.brandOrange),
      ),
    );
  }
}
