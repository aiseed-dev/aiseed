import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/farming_method.dart';

/// 栽培方法の段階的選択ウィジェット
///
/// 責務: 栽培方法を3段階で選択するUIを提供
/// 1. 化学肥料・農薬を使う/使わない
/// 2. 有機栽培/自然系栽培（使わない場合のみ）
/// 3. 具体的な方法（自然系の場合のみ）
class CultivationMethodSelector extends StatefulWidget {
  final CultivationMethod? selectedMethod;
  final ValueChanged<CultivationMethod> onChanged;

  const CultivationMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  State<CultivationMethodSelector> createState() => _CultivationMethodSelectorState();
}

class _CultivationMethodSelectorState extends State<CultivationMethodSelector> {
  late CultivationCategory _selectedCategory;
  CultivationType? _selectedType;

  @override
  void initState() {
    super.initState();
    _initFromMethod(widget.selectedMethod);
  }

  @override
  void didUpdateWidget(CultivationMethodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMethod != widget.selectedMethod) {
      _initFromMethod(widget.selectedMethod);
    }
  }

  void _initFromMethod(CultivationMethod? method) {
    if (method == null) {
      _selectedCategory = CultivationCategory.nonChemical;
      _selectedType = CultivationType.natural;
    } else {
      _selectedCategory = method.category;
      _selectedType = method.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第1段階：化学肥料・農薬
        _buildStepTitle('1. 化学肥料・農薬'),
        const SizedBox(height: 8),
        _buildCategorySelector(),
        const SizedBox(height: 16),

        // 第2段階：有機 or 自然系（化学を使わない場合のみ）
        if (_selectedCategory == CultivationCategory.nonChemical) ...[
          _buildStepTitle('2. 栽培タイプ'),
          const SizedBox(height: 8),
          _buildTypeSelector(),
          const SizedBox(height: 16),

          // 第3段階：具体的な方法（自然系の場合のみ）
          if (_selectedType == CultivationType.natural) ...[
            _buildStepTitle('3. 具体的な方法（任意）'),
            const SizedBox(height: 8),
            _buildMethodSelector(),
          ],
        ],
      ],
    );
  }

  Widget _buildStepTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: GrowColors.deepGreen,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: CultivationCategory.values.map((category) {
        final isSelected = category == _selectedCategory;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: category == CultivationCategory.chemical ? 8 : 0,
            ),
            child: _buildOptionCard(
              emoji: category.emoji,
              label: category.nameJa,
              isSelected: isSelected,
              onTap: () => _onCategoryChanged(category),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: CultivationType.values.map((type) {
        final isSelected = type == _selectedType;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == CultivationType.organic ? 8 : 0,
            ),
            child: _buildOptionCard(
              emoji: type.emoji,
              label: type.nameJa,
              subtitle: type.description,
              isSelected: isSelected,
              onTap: () => _onTypeChanged(type),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMethodSelector() {
    final methods = CultivationMethod.naturalMethods;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map((method) {
        final isSelected = widget.selectedMethod == method;
        return GestureDetector(
          onTap: () => widget.onChanged(method),
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
                Text(method.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  method.nameJa,
                  style: TextStyle(
                    color: isSelected ? Colors.white : GrowColors.darkSoil,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionCard({
    required String emoji,
    required String label,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? GrowColors.lifeGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? GrowColors.lifeGreen : GrowColors.lightSoil,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : GrowColors.darkSoil,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : GrowColors.drySoil,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onCategoryChanged(CultivationCategory category) {
    setState(() {
      _selectedCategory = category;
      if (category == CultivationCategory.chemical) {
        _selectedType = null;
        widget.onChanged(CultivationMethod.conventional);
      } else {
        _selectedType = CultivationType.natural;
        widget.onChanged(CultivationMethod.naturalCultivation);
      }
    });
  }

  void _onTypeChanged(CultivationType type) {
    setState(() {
      _selectedType = type;
      if (type == CultivationType.organic) {
        widget.onChanged(CultivationMethod.organic);
      } else {
        widget.onChanged(CultivationMethod.naturalCultivation);
      }
    });
  }
}
