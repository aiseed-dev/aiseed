import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/farming_method.dart';

/// 農法選択ウィジェット
///
/// 責務: 農法の選択UIを提供
class FarmingMethodSelector extends StatelessWidget {
  final FarmingMethod selectedMethod;
  final ValueChanged<FarmingMethod> onChanged;

  const FarmingMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FarmingMethod.values.map((method) {
        final isSelected = method == selectedMethod;
        return GestureDetector(
          onTap: () => onChanged(method),
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
                Text(method.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  method.nameJa,
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

/// 農法選択ボトムシート
void showFarmingMethodPicker({
  required BuildContext context,
  required FarmingMethod selectedMethod,
  required ValueChanged<FarmingMethod> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _FarmingMethodPickerSheet(
      selectedMethod: selectedMethod,
      onSelected: (method) {
        onSelected(method);
        Navigator.pop(context);
      },
    ),
  );
}

class _FarmingMethodPickerSheet extends StatelessWidget {
  final FarmingMethod selectedMethod;
  final ValueChanged<FarmingMethod> onSelected;

  const _FarmingMethodPickerSheet({
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '農法を選択',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: FarmingMethod.values.length,
              itemBuilder: (context, index) {
                final method = FarmingMethod.values[index];
                final isSelected = method == selectedMethod;
                return ListTile(
                  leading: Text(method.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(method.nameJa),
                  subtitle: Text(
                    method.nameEn,
                    style: TextStyle(
                      color: GrowColors.drySoil,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: GrowColors.lifeGreen)
                      : null,
                  onTap: () => onSelected(method),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
