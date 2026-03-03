import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/meal_builder_models.dart';

class MealTabsWidget extends StatelessWidget {
  final List<MealDraft> meals;
  final int activeIndex;
  final void Function(int) onSelect;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final void Function(int, String) onRename;
  final int maxMeals;

  const MealTabsWidget({
    super.key,
    required this.meals,
    required this.activeIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onRemove,
    required this.onRename,
    this.maxMeals = 5,
  });

  void _showRenameDialog(BuildContext context, int index) {
    final controller = TextEditingController(text: meals[index].label);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Meal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Meal name'),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) onRename(index, val.trim());
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) onRename(index, val);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...List.generate(meals.length, (i) {
            final meal = meals[i];
            final isActive = i == activeIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(i),
                onLongPress: () => _showRenameDialog(context, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.brandOrange.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.brandOrange : Colors.grey.shade300,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        meal.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.brandOrange : Colors.grey.shade600,
                        ),
                      ),
                      if (meal.ingredients.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '(${meal.ingredients.length})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? AppColors.brandOrange.withValues(alpha: 0.7)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      if (meals.length > 1) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onRemove(i),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          // Add meal button
          GestureDetector(
            onTap: meals.length < maxMeals ? onAdd : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Add Meal',
                    style: TextStyle(
                      fontSize: 13,
                      color: meals.length < maxMeals
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
