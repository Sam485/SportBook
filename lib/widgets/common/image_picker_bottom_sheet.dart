import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sportbook/core/theme.dart';

class ImagePickerBottomSheet {
  static Future<File?> show(BuildContext context) async {
    File? selectedImage;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ImagePickerSheet(onImageSelected: (file) => selectedImage = file),
    );

    return selectedImage;
  }
}

class _ImagePickerSheet extends StatelessWidget {
  final ValueChanged<File?> onImageSelected;
  _ImagePickerSheet({required this.onImageSelected});

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery(BuildContext context) async {
    Navigator.pop(context);
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) onImageSelected(File(image.path));
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(context, 'Gallery');
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    Navigator.pop(context);
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) onImageSelected(File(image.path));
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(context, 'Camera');
    }
  }

  void _showPermissionDeniedDialog(BuildContext context, String source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          '$source Access Denied',
          style: TextStyle(color: AppTheme.textPrimary(context)),
        ),
        content: Text(
          '$source permission was permanently denied. Please enable it in Settings to continue.',
          style: TextStyle(color: AppTheme.textSub(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSub(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: AppTheme.elevatedButtonStyle(),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Profile Photo', style: AppTheme.tsTitleAdaptive(context)),
          const SizedBox(height: 4),
          Text(
            'Choose how to update your photo',
            style: AppTheme.tsSubAdaptive(context),
          ),
          const SizedBox(height: 20),
          _optionTile(
            context,
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            sublabel: 'Pick a photo from your library',
            onTap: () => _pickFromGallery(context),
          ),
          const SizedBox(height: 10),
          _optionTile(
            context,
            icon: Icons.camera_alt_outlined,
            label: 'Take a Photo',
            sublabel: 'Use your camera',
            onTap: () => _pickFromCamera(context),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.border(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSub(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardAlt(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.kAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.kAccent.withOpacity(0.3)),
              ),
              child: Icon(icon, color: AppTheme.kAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.tsLabelAdaptive(
                      context,
                    ).copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(sublabel, style: AppTheme.tsSubAdaptive(context)),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSub(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
