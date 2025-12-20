import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';

class PicEditorHelper {
  static final ImagePicker _picker = ImagePicker();

  // Main public method to open photo editor flow
  static Future<File?> startPhotoEditor(
      BuildContext context, {
        ImageSource? initialSource,
        ProImageEditorConfigs? editorConfigs,
        Function(File)? onSuccess,
        Function(String)? onError,
      }) async {
    try {
      // If source is provided directly, use it
      if (initialSource != null) {
        return await _pickAndEditImage(
          context,
          initialSource,
          editorConfigs,
          onSuccess,
          onError,
        );
      }

      // Otherwise show bottom sheet to choose source
      final source = await _showImageSourcePicker(context);
      if (source != null) {
        return await _pickAndEditImage(
          context,
          source,
          editorConfigs,
          onSuccess,
          onError,
        );
      }
      return null;
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      } else {
        _showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
      return null;
    }
  }

  // Show bottom sheet for image source selection
  static Future<ImageSource?> _showImageSourcePicker(BuildContext context) async {
    return await showModalBottomSheet<ImageSource?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => _buildBottomSheet(context),
    );
  }

  static Widget _buildBottomSheet(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Center(
              child: Text(
                'Choose Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Camera Button
            _buildOptionButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              color: Colors.blue,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),

            // Gallery Button
            _buildOptionButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              color: Colors.green,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Pick image and open editor
  static Future<File?> _pickAndEditImage(
      BuildContext context,
      ImageSource source,
      ProImageEditorConfigs? editorConfigs,
      Function(File)? onSuccess,
      Function(String)? onError,
      ) async {
    try {
      // Show loading
      _showLoadingDialog(context);

      // Pick image
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      // Dismiss loading
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (pickedFile == null) return null;

      final imageFile = File(pickedFile.path);

      // Open editor
      final editedImage = await _openEditor(
        context,
        imageFile,
        editorConfigs,
      );

      if (editedImage != null) {
        // Call success callback
        if (onSuccess != null) {
          onSuccess(editedImage);
        } else {
          _showSuccessMessage(context);
        }
        return editedImage;
      }
      return null;
    } catch (e) {
      // Dismiss loading
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Handle error
      if (onError != null) {
        onError(e.toString());
      } else {
        _showErrorSnackBar(context, 'Failed to select image: ${e.toString()}');
      }
      return null;
    }
  }

  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Loading image...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Future<File?> _openEditor(
      BuildContext context,
      File imageFile,
      ProImageEditorConfigs? customConfigs,
      ) async {
    // Create callbacks
    final callbacks = ProImageEditorCallbacks(
      onImageEditingComplete: (Uint8List editedImage) async {
        try {
          Directory downloadsDir;

          if (Platform.isAndroid) {
            downloadsDir = Directory('/storage/emulated/0/DCIM/Unicap');
          } else {
            // iOS - save to documents (appears in Files app)
            final appDir = await getApplicationDocumentsDirectory();
            downloadsDir = Directory('${appDir.path}/Unicap');
          }

          // Create directory
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }

          // Create file
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'Unicap_Image_$timestamp.png';
          final file = File(path.join(downloadsDir.path, fileName));

          // Save
          await file.writeAsBytes(editedImage);

          Navigator.pop(context, file);
        } catch (e) {
          // Fallback
          final appDir = await getApplicationDocumentsDirectory();
          final file = File('${appDir.path}/unicap_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(editedImage);
          Navigator.pop(context, file);
        }
        return;
      },
      onCloseEditor: (EditorMode mode) async {
        Navigator.pop(context);
        return;
      },
    );


    // Use custom configs if provided, otherwise create default
    final configs = customConfigs ?? ProImageEditorConfigs();

    // The result will be returned through Navigator's pop
    // Note: We need to wait for the Future to complete and get the result
    // Actually, we should get the result from Navigator.push directly
    final result = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          imageFile,
          configs: configs,
          callbacks: callbacks,
        ),
      ),
    );

    return result;
  }

  static void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Photo Saved to DCIM/Unicap successfully!'),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}