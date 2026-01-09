import 'dart:io';
import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

/// 写真選択ウィジェット
///
/// 責務: 観察記録用の写真選択UIを提供
class PhotoPicker extends StatelessWidget {
  final List<String> photoPaths;
  final ValueChanged<List<String>> onPhotosChanged;
  final int maxPhotos;

  const PhotoPicker({
    super.key,
    required this.photoPaths,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photoPaths.isEmpty)
          _buildEmptyState(context)
        else
          _buildPhotoGrid(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: GrowColors.paleGreen.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GrowColors.lightSoil,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: GrowColors.drySoil,
            ),
            const SizedBox(height: 12),
            Text(
              '写真を追加',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: GrowColors.drySoil,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'タップして撮影または選択',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: GrowColors.drySoil,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoPaths.length + (photoPaths.length < maxPhotos ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == photoPaths.length) {
                // 追加ボタン
                return _buildAddButton(context);
              }
              return _buildPhotoItem(context, index);
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${photoPaths.length}/$maxPhotos枚',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: GrowColors.drySoil,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(BuildContext context, int index) {
    final photoPath = photoPaths[index];
    final isLocalFile = !photoPath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isLocalFile
                ? Image.file(
                    File(photoPath),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  )
                : Image.network(
                    photoPath,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  ),
          ),
          // 削除ボタン
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                final newPaths = List<String>.from(photoPaths);
                newPaths.removeAt(index);
                onPhotosChanged(newPaths);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: GrowColors.lightSoil,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: GrowColors.drySoil),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GrowColors.lightSoil),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: GrowColors.drySoil, size: 32),
            SizedBox(height: 4),
            Text(
              '追加',
              style: TextStyle(
                color: GrowColors.drySoil,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GrowColors.lightSoil,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '写真を追加',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt,
                  label: '写真を撮る',
                  onTap: () {
                    Navigator.pop(context);
                    _handleCameraCapture(context);
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'アルバムから選ぶ',
                  onTap: () {
                    Navigator.pop(context);
                    _handleGalleryPick(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: GrowColors.paleGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: GrowColors.deepGreen, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _handleCameraCapture(BuildContext context) {
    // TODO: image_picker パッケージを使用してカメラを起動
    // 現在はプレースホルダー
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('カメラ機能は後で実装されます'),
        backgroundColor: GrowColors.drySoil,
      ),
    );
  }

  void _handleGalleryPick(BuildContext context) {
    // TODO: image_picker パッケージを使用してギャラリーを開く
    // 現在はプレースホルダー
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ギャラリー機能は後で実装されます'),
        backgroundColor: GrowColors.drySoil,
      ),
    );
  }
}
