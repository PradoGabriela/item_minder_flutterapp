import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:item_minder_flutterapp/base/item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageManager {
  static ImageManager? _instance;

  static ImageManager get instance {
    _instance ??= ImageManager._init();
    return _instance!;
  }

  ImageManager._init();

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  File? _lastImage;

  void clearAllImages(dynamic) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_images');

    // Optionally delete the actual files
    for (var image in _images) {
      try {
        await image.delete();
      } catch (e) {
        debugPrint("Error deleting file: ${image.path}");
      }
    }
    _images.clear();
    _lastImage = null;
    ScaffoldMessenger.of(dynamic.context).showSnackBar(
      const SnackBar(
        content: Text("All images cleared"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPaths = prefs.getStringList('saved_images') ?? [];

    // Filter out paths that no longer exist (if files were deleted externally)
    final existingPaths = await Future.wait(
        savedPaths.map((path) async => await File(path).exists()));

    final validPaths = <String>[];
    for (int i = 0; i < savedPaths.length; i++) {
      if (existingPaths[i]) {
        validPaths.add(savedPaths[i]);
      }
    }

    // Update SharedPreferences with only valid paths
    if (validPaths.length != savedPaths.length) {
      await prefs.setStringList('saved_images', validPaths);
    }

    _images.addAll(validPaths.map((path) => File(path)));
    if (_images.isNotEmpty) {
      _lastImage = _images.last;
    }
    debugPrint("Loaded images: ${_images.length} valid images found.");
  }

  Future<void> pickImage(ImageSource source, AppItem item) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      // Get the custom name before proceeding
      final String customName = item.category;

      if (customName == null || customName.isEmpty) return;

      final File imageFile = File(pickedFile.path);
      final File savedImage = await saveImage(imageFile, item);

      _images.add(savedImage);
      _lastImage = savedImage;

      debugPrint("Image saved successfully!");
    } catch (e) {
      debugPrint("Error picking image: ${e.toString()}");
    }
  }

  Future<File> saveImage(File image, AppItem item) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String customName = item.category;
    // Sanitize the custom name to remove invalid characters
    String sanitizedCustomName = customName.replaceAll(RegExp(r'[^\w-]'), '_');

    // Get file extension from original image
    String extension = extensionFromPath(image.path);

    // Create filename with custom name and timestamp to ensure uniqueness
    final String fileName =
        '${sanitizedCustomName}_${DateTime.now().millisecondsSinceEpoch}$extension';

    final File savedImage = await image.copy('${directory.path}/$fileName');

    final prefs = await SharedPreferences.getInstance();
    List<String> savedPaths = prefs.getStringList('saved_images') ?? [];
    savedPaths.add(savedImage.path);
    await prefs.setStringList('saved_images', savedPaths);
    item.imageUrl = fileName;
    printFileList();
    // Debugging line to print the list of files
    return savedImage;
  }

  String extensionFromPath(String path) {
    // Extract extension including the dot (e.g., '.jpg', '.png')
    final ext = path.substring(path.lastIndexOf('.'));
    return ext.toLowerCase(); // return lowercase for consistency
  }

  void printFileList() {
    debugPrint("List of files: ${_images.map((file) => file.path).toList()}");
  }

  File get lastImage {
    return _lastImage!;
  }

  File? getImageByName(String imageName) {
    try {
      final searchName = imageName.toLowerCase();
      File foundImage = _images.firstWhere(
        (file) => file.path.toLowerCase().contains(searchName),
        orElse: () => throw Exception('Image not found'),
      );
      return foundImage;
    } catch (e) {
      debugPrint("Image not found: $imageName");
      return null;
    }
  }
}
