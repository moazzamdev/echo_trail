// Navigation.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/navigation_service.dart';
import 'dart:io';


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationService _navService = NavigationService();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _captureAndSend() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _navService.sendImageToBackend(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Navigation Assistant")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _captureAndSend,
              child: Text("Capture & Detect"),
            ),
            if (_image != null) Image.file(_image!, height: 200),
          ],
        ),
      ),
    );
  }
}
