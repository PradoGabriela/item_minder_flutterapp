import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:item_minder_flutterapp/base/managers/image_manager.dart';

class UploadImageWidget extends StatefulWidget {
  final dynamic passItem;
  final bool isEditMode;

  const UploadImageWidget({
    super.key,
    required this.passItem,
    required this.isEditMode,
  });
  @override
  State<UploadImageWidget> createState() => _UploadImageWidgetState();
}

class _UploadImageWidgetState extends State<UploadImageWidget> {
  File? _currentImage;
  void _addNewImage(ImageSource source) async {
    await ImageManager.instance.pickImage(source, widget.passItem);
    setState(() {
      _currentImage =
          ImageManager.instance.getImageByName(widget.passItem.imageUrl);
    });
  }

  File? _loadItemImages() {
    if (widget.passItem.imageUrl == null) {
      return null;
    }
    setState(() {
      _currentImage =
          ImageManager.instance.getImageByName(widget.passItem.imageUrl);
    });

    return _currentImage;
  }

  @override
  void initState() {
    super.initState();
    ImageManager.instance
        .loadSavedImages(); // Load saved images when the widget initializes
    _loadItemImages(); // Load the image for the specific item
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Visibility(
          visible: widget.isEditMode,
          child: Column(
            children: [
              const Text("Upload Image", style: TextStyle(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () => _addNewImage(ImageSource.camera),
                      icon: const Icon(FontAwesomeIcons.camera)),
                  const Text("or", style: TextStyle(fontSize: 16)),
                  IconButton(
                      onPressed: () => _addNewImage(ImageSource.gallery),
                      icon: const Icon(FontAwesomeIcons.image)),
                ],
              ),
            ],
          ),
        ),
        if (_currentImage != null)
          Column(
            children: [
              const Text("Item Image", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _currentImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
