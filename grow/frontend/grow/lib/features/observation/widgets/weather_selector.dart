import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/models/weather.dart';

/// 天気選択ウィジェット
///
/// 責務: 天気の選択UIを提供
class WeatherSelector extends StatelessWidget {
  final Weather? selectedWeather;
  final ValueChanged<Weather?> onChanged;

  const WeatherSelector({
    super.key,
    required this.selectedWeather,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Weather.values.map((weather) {
          final isSelected = weather == selectedWeather;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (isSelected) {
                  onChanged(null);
                } else {
                  onChanged(weather);
                }
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected ? GrowColors.paleGreen : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? GrowColors.lifeGreen : GrowColors.lightSoil,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weather.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weather.nameJa,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? GrowColors.deepGreen : GrowColors.drySoil,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
