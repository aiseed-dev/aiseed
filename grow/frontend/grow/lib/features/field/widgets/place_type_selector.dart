import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/place_type.dart';

/// 栽培場所タイプ選択ウィジェット
///
/// 責務: 栽培場所タイプの選択UIを提供
class PlaceTypeSelector extends StatelessWidget {
  final PlaceType selectedType;
  final ValueChanged<PlaceType> onChanged;

  const PlaceTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PlaceType.values.map((type) {
        final isSelected = type == selectedType;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? GrowColors.lifeGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? GrowColors.lifeGreen : GrowColors.lightSoil,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  type.nameJa,
                  style: TextStyle(
                    color: isSelected ? Colors.white : GrowColors.darkSoil,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
