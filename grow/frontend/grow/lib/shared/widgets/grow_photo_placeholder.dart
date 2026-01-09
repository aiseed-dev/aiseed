import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 写真プレースホルダーウィジェット
///
/// 責務: 写真がない場合のプレースホルダーを表示
class GrowPhotoPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final String emoji;
  final VoidCallback? onTap;

  const GrowPhotoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.emoji = '📷',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: GrowColors.paleGreen,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: (height ?? 80) * 0.4,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// 写真表示ウィジェット（実際の写真またはプレースホルダー）
class GrowPhoto extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final VoidCallback? onTap;

  const GrowPhoto({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return GrowPhotoPlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        onTap: onTap,
      );
    }

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return GrowPhotoPlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: GrowColors.lightSoil,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: GrowColors.lifeGreen,
              ),
            ),
          );
        },
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: image,
      );
    }

    return image;
  }
}
