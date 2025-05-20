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
  // Variables for drag gesture
  double _dragStartPosition = 0;
  bool _isDragging = false;

  // Zoom variables
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 10.0;
  double _currentZoom = 1.0;
  double _baseScale = 1.0;
  bool _isUltrawideAvailable = false;

  // Camera type tracking
  CameraDescription? _mainCamera;
  CameraDescription? _ultrawideCamera;
  bool _isUsingUltrawide = false;

  // Scale tracking
  double _previousScale = 1.0;

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

    // Find main camera and ultrawide camera
    if (_cameras!.length > 0) {
      // Main camera is typically the first back camera
      _mainCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    }

    // Use cameras[3] as the ultrawide camera if available
    if (_cameras!.length > 3) {
      _ultrawideCamera = _cameras![3];
      _isUltrawideAvailable = true;
      print("Ultrawide camera found: ${_ultrawideCamera?.name}");
    } else {
      print(
        "Ultrawide camera not available. Only ${_cameras!.length} cameras found.",
      );
    }

    // Default to main camera if available
    final cameraToUse = _mainCamera ?? _cameras!.first;
    _isUsingUltrawide = false;

    _controller = CameraController(
      cameraToUse,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller?.initialize();
      await _getZoomLevels();
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _getZoomLevels() async {
    if (_controller == null) return;

    try {
      _minAvailableZoom = await _controller!.getMinZoomLevel();
      double maxZoom = await _controller!.getMaxZoomLevel();
      _maxAvailableZoom = math.min(maxZoom, 10.0); // Cap at 10x

      // If this is a selfie camera, disable zoom by setting min and max to 1.0
      if (_controller!.description.lensDirection == CameraLensDirection.front) {
        _minAvailableZoom = 1.0;
        _maxAvailableZoom = 1.0;
        _currentZoom = 1.0;
      }

      setState(() {});
    } catch (e) {
      print('Failed to get zoom levels: $e');
    }
  }

  Future<void> _switchToCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    setState(() {
      _isReady = false;
      _currentZoom = 1.0;
    });

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      await _getZoomLevels();
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_controller == null || _cameras == null || _cameras!.isEmpty) return;

    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.front) {
      // If using front camera, switch to the main back camera (not ultrawide)
      newCamera =
          _mainCamera ??
          _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          );
      _isUsingUltrawide = false;
    } else {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
    }

    await _switchToCamera(newCamera);
  }

  Future<void> _setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Don't allow zoom changes on selfie camera
    if (_controller!.description.lensDirection == CameraLensDirection.front) {
      return;
    }

    // Ensure the zoom is within bounds
    zoom = zoom.clamp(_minAvailableZoom, _maxAvailableZoom);

    try {
      await _controller!.setZoomLevel(zoom);
      setState(() => _currentZoom = zoom);
    } catch (e) {
      print('Error setting zoom level: $e');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentZoom;
    _previousScale = 1.0;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Calculate new zoom level
    double newScale = details.scale;
    double scaleFactor = newScale / _previousScale;
    _previousScale = newScale;

    double newZoomLevel = (_currentZoom * scaleFactor).clamp(
      _minAvailableZoom,
      _maxAvailableZoom,
    );

    // Handle camera switching for ultrawide
    if (_isUltrawideAvailable &&
        _ultrawideCamera != null &&
        _mainCamera != null) {
      if (newZoomLevel < 1.0 &&
          !_isUsingUltrawide &&
          _controller!.description == _mainCamera) {
        // Switch to ultrawide camera
        _switchToCamera(_ultrawideCamera!);
        _isUsingUltrawide = true;
        return;
      } else if (newZoomLevel >= 1.0 &&
          _isUsingUltrawide &&
          _controller!.description == _ultrawideCamera) {
        // Switch back to main camera
        _switchToCamera(_mainCamera!);
        _isUsingUltrawide = false;
        return;
      }
    }

    // Only update if zoom changed significantly to avoid too many updates
    if ((newZoomLevel - _currentZoom).abs() > 0.05) {
      _setZoomLevel(newZoomLevel);
    }
  }

  // Toggle zoom between 1x and 2x
  void _toggleZoom() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.description.lensDirection == CameraLensDirection.front)
      return;

    // If using ultrawide, switch to main camera at 1x
    if (_isUsingUltrawide && _mainCamera != null) {
      _switchToCamera(_mainCamera!);
      _isUsingUltrawide = false;
      return;
    }

    if (_currentZoom < 1.8) {
      // If we're below ~2x, go to 2x
      _setZoomLevel(2.0);
    } else {
      // Otherwise go back to 1x
      _setZoomLevel(1.0);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

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

  void _navigateToHistoryPage() {
    context.push('/history');
  }

  // Handle vertical drag gesture for history
  void _onVerticalDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition.dy;
    _isDragging = true;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    // If dragged up more than 100 pixels, navigate to history
    if (_dragStartPosition - details.globalPosition.dy > 200) {
      _isDragging = false;
      _navigateToHistoryPage();
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
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
        child: GestureDetector(
          onScaleStart:
              _controller!.description.lensDirection !=
                      CameraLensDirection.front
                  ? _handleScaleStart
                  : null,
          onScaleUpdate:
              _controller!.description.lensDirection !=
                      CameraLensDirection.front
                  ? _handleScaleUpdate
                  : null,
          child: Stack(
            children: [
              OverflowBox(
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
              if (_controller!.description.lensDirection !=
                  CameraLensDirection.front)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleZoom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isUsingUltrawide
                            ? '0.5x'
                            : '${_currentZoom.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF6),
      body: GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Profile image on the left
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/avatar.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Chat button on the right
                    IconButton(
                      onPressed: () {
                        // Navigate to chat or open chat dialog
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
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
                      onPressed: _flipCamera,
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _navigateToHistoryPage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'History',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
