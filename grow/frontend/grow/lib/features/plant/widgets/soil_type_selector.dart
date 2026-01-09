import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/soil_type.dart';

/// 土壌タイプ選択ウィジェット
///
/// 責務: 土壌タイプの選択UIを提供
class SoilTypeSelector extends StatelessWidget {
  final SoilType? selectedSoilType;
  final ValueChanged<SoilType?> onChanged;
  final bool showAllTypes;

  const SoilTypeSelector({
    super.key,
    required this.selectedSoilType,
    required this.onChanged,
    this.showAllTypes = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSoilTypePicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GrowColors.lightSoil),
        ),
        child: Row(
          children: [
            if (selectedSoilType != null) ...[
              Text(selectedSoilType!.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedSoilType!.nameJa,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      selectedSoilType!.nameEn,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: GrowColors.drySoil,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Icon(Icons.landscape_outlined, color: GrowColors.drySoil),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '土壌タイプを選択（任意）',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: GrowColors.drySoil,
                  ),
                ),
              ),
            ],
            const Icon(Icons.chevron_right, color: GrowColors.drySoil),
          ],
        ),
      ),
    );
  }

  void _showSoilTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _SoilTypePickerSheet(
          selectedSoilType: selectedSoilType,
          showAllTypes: showAllTypes,
          scrollController: scrollController,
          onSelected: (soilType) {
            onChanged(soilType);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _SoilTypePickerSheet extends StatefulWidget {
  final SoilType? selectedSoilType;
  final bool showAllTypes;
  final ScrollController scrollController;
  final ValueChanged<SoilType?> onSelected;

  const _SoilTypePickerSheet({
    required this.selectedSoilType,
    required this.showAllTypes,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  State<_SoilTypePickerSheet> createState() => _SoilTypePickerSheetState();
}

class _SoilTypePickerSheetState extends State<_SoilTypePickerSheet> {
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _showAll = widget.showAllTypes;
  }

  @override
  Widget build(BuildContext context) {
    final japanCommon = SoilType.getJapanCommon();
    final allTypes = SoilType.values.where((t) => t != SoilType.unknown).toList();
    final displayTypes = _showAll ? allTypes : japanCommon;

    return Container(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '土壌タイプを選択',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () => widget.onSelected(null),
                  child: const Text('クリア'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: GrowColors.drySoil),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'WRB国際土壌分類に基づいています',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: GrowColors.drySoil,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('日本で一般的'),
                  selected: !_showAll,
                  onSelected: (selected) {
                    setState(() {
                      _showAll = !selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('すべて表示'),
                  selected: _showAll,
                  onSelected: (selected) {
                    setState(() {
                      _showAll = selected;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: displayTypes.length,
              itemBuilder: (context, index) {
                final soilType = displayTypes[index];
                final isSelected = soilType == widget.selectedSoilType;
                return ListTile(
                  leading: Text(soilType.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(soilType.nameJa),
                  subtitle: Text(
                    soilType.nameEn,
                    style: TextStyle(
                      color: GrowColors.drySoil,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: GrowColors.lifeGreen)
                      : null,
                  onTap: () => widget.onSelected(soilType),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
