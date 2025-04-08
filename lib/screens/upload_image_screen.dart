import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  File? _lastImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImages(); // Load saved images when the widget initializes
  }

  Future<void> _loadSavedImages() async {
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

    setState(() {
      _images.addAll(validPaths.map((path) => File(path)));
      if (_images.isNotEmpty) {
        _lastImage = _images.last;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      // Get the custom name before proceeding
      final String? customName = await _showFilenameDialog();
      if (customName == null || customName.isEmpty) return;

      final File imageFile = File(pickedFile.path);
      final File savedImage = await _saveImage(imageFile, customName);

      setState(() {
        _images.add(savedImage);
        _lastImage = savedImage;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text("Image saved successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text("Error saving image: ${e.toString()}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> _showFilenameDialog() async {
    String? filename;
    await showDialog<String>(
      context: this.context, // Using the widget's context directly
      builder: (BuildContext dialogContext) {
        // Renamed to dialogContext to avoid conflict
        return AlertDialog(
          title: const Text('Name your image'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter a name for your image',
              labelText: 'Image name',
            ),
            onChanged: (value) => filename = value,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () => Navigator.pop(dialogContext, filename),
            ),
          ],
        );
      },
    );
    return filename;
  }

  Future<File> _saveImage(File image, String customName) async {
    final Directory directory = await getApplicationDocumentsDirectory();

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

    return savedImage;
  }

  String extensionFromPath(String path) {
    // Extract extension including the dot (e.g., '.jpg', '.png')
    final ext = path.substring(path.lastIndexOf('.'));
    return ext.toLowerCase(); // return lowercase for consistency
  }

  void _printFileList() {
    debugPrint("List of files: ${_images.map((file) => file.path).toList()}");
  }

  void _clearAllImages() async {
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

    setState(() {
      _images.clear();
      _lastImage = null;
    });

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(
        content: Text("All images cleared!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
        actions: [
          if (_images.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearAllImages,
              tooltip: 'Clear all images',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text('Take a Picture'),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text('Pick from Gallery'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _printFileList,
                child: const Text('Print File List'),
              ),
              const SizedBox(height: 20),
              if (_images.isNotEmpty)
                Text(
                  "Total images: ${_images.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 20),
              if (_lastImage != null)
                Column(
                  children: [
                    const Text("Latest Image:", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _lastImage!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (_images.isNotEmpty)
                ..._images.reversed
                    .map((image) => ListTile(
                          leading: Image.file(
                            image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(basename(image.path)),
                        ))
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
