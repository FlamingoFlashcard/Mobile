import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    _controller = CameraController(
      _cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller?.initialize();
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      final XFile picture = await _controller!.takePicture();
      setState(() {
        _image = File(picture.path);
      });
      _navigateToAboutScreen();
      print("📸 Picture saved to: ${_image!.path}");
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _getImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _navigateToAboutScreen();
    }
  }

  void _navigateToAboutScreen() {
    if (_image != null) {
      context.push('/about', extra: _image!.path).then((_) {
        // Reset the image when returning from about screen
        setState(() {
          _image = null;
        });
      });
    }
  }

  // Thank you https://github.com/flutter/flutter/issues/15953#issuecomment-855182376
  Widget _buildCameraPreview() {
    if (!_isReady || _controller == null) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.camera_alt, color: Colors.white, size: 50),
        ),
      );
    }

    var size = MediaQuery.of(context).size;
    final screenH = math.max(size.height, size.width);
    final screenW = math.min(size.height, size.width);
    size = _controller!.value.previewSize!;
    final previewH = math.max(size.height, size.width);
    final previewW = math.min(size.height, size.width);
    final screenRatio = screenH / screenW;
    final previewRatio = previewH / previewW;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: OverflowBox(
          maxHeight:
              screenRatio > previewRatio
                  ? screenH
                  : screenW / previewW * previewH,
          maxWidth:
              screenRatio > previewRatio
                  ? screenH / previewH * previewW
                  : screenW,
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child:
                        _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : _buildCameraPreview(),
                  ),
                ),
              ),
            ),
            const Text(
              "Position landmark within the frame",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _getImageFromGallery,
                    icon: const Icon(
                      Icons.photo_library,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: _takePicture,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.camera,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Placeholder for MORE button
                    },
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
