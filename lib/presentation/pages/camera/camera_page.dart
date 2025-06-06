import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../services/location_weather_service.dart';
import 'dart:async';
import 'package:gal/gal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/post/bloc/post_bloc.dart';
import '../../../features/post/bloc/post_event.dart';
import '../../../features/post/bloc/post_state.dart';
import '../../../services/user_service.dart';
import '../../widgets/qr_scanner_dialog.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
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

  // Camera type tracking
  CameraDescription? _mainCamera;

  // Scale tracking
  double _previousScale = 1.0;

  // Slider overlay variables
  int _currentSliderIndex = 0;
  final List<String> _sliderOptions = [
    'Caption',
    'Time',
    '✨AI✨',
    'Location',
    'Weather',
  ];

  // Caption variables
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _captionFocusNode = FocusNode();
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  // Data variables
  String _currentTime = '';
  String _locationName = 'Getting location...';
  String _weatherInfo = 'Getting weather...';

  // Shot mode variables
  bool _isShotMode = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _slideOutAnimation;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initSliderFeatures();
  }

  void _initSliderFeatures() {
    // Initialize wiggle animation for caption
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.elasticIn),
    );

    // Initialize slide animation for slider options
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Initialize time updates
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _updateTime();
    });

    // Initialize location and weather
    _getLocationAndWeather();

    // Listen to caption changes
    _captionController.addListener(_onCaptionChanged);
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
  }

  void _onCaptionChanged() {
    if (_captionController.text.length > 12) {
      _wiggleController.forward().then((_) {
        _wiggleController.reverse();
      });
      // Trim to 12 characters
      final text = _captionController.text.substring(0, 12);
      _captionController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  Future<void> _getLocationAndWeather() async {
    try {
      setState(() {
        _locationName = 'Getting location...';
        _weatherInfo = 'Getting weather...';
      });

      final position = await LocationWeatherService.getCurrentLocation();
      if (position != null) {
        // Get location name
        final locationName = await LocationWeatherService.getLocationName(
          position,
        );

        // Get weather info
        final weatherInfo = await LocationWeatherService.getWeatherInfo(
          position,
        );

        if (mounted) {
          setState(() {
            _locationName = locationName;
            _weatherInfo = weatherInfo;
          });
        }
      } else {
        // Check if it's a permission issue or service issue
        final serviceEnabled =
            await LocationWeatherService.isLocationServiceEnabled();
        final hasPermission =
            await LocationWeatherService.checkLocationPermission();

        if (mounted) {
          setState(() {
            if (!serviceEnabled) {
              _locationName = 'Enable location services';
              _weatherInfo = 'Tap to open settings';
            } else if (!hasPermission) {
              _locationName = 'Tap to allow location';
              _weatherInfo = 'Permission required';
            } else {
              _locationName = 'Location unavailable';
              _weatherInfo = 'Weather unavailable';
            }
          });
        }
      }
    } catch (e) {
      print('Error getting location/weather: $e');
      if (mounted) {
        setState(() {
          _locationName = 'Location error';
          _weatherInfo = 'Weather error';
        });
      }
    }
  }

  Future<void> _handleLocationTap() async {
    final serviceEnabled =
        await LocationWeatherService.isLocationServiceEnabled();
    final hasPermission =
        await LocationWeatherService.checkLocationPermission();

    if (!serviceEnabled) {
      // Open location settings
      await LocationWeatherService.openLocationSettings();
    } else if (!hasPermission) {
      // Try to request permission again, or open app settings if permanently denied
      final position = await LocationWeatherService.getCurrentLocation();
      if (position == null) {
        // If still no permission, open app settings
        await LocationWeatherService.openAppSettings();
      }
    } else {
      // Just retry getting location
      _getLocationAndWeather();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _wiggleController.dispose();
    _slideController.dispose();
    _captionController.dispose();
    _captionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    // Find main camera
    if (_cameras!.isNotEmpty) {
      // Main camera is typically the first back camera
      _mainCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    }

    // Default to main camera if available
    final cameraToUse = _mainCamera ?? _cameras!.first;

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
      // If using front camera, switch to the main back camera
      newCamera =
          _mainCamera ??
          _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          );
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

    // Only update if zoom changed significantly to avoid too many updates
    if ((newZoomLevel - _currentZoom).abs() > 0.05) {
      _setZoomLevel(newZoomLevel);
    }
  }

  // Toggle zoom between 1x and 2x
  void _toggleZoom() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.description.lensDirection == CameraLensDirection.front) {
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
        _isShotMode = true;
      });
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
        // Reset the image and shot mode when returning from about screen
        setState(() {
          _image = null;
          _isShotMode = false;
          _currentSliderIndex = 0;
        });
      });
    }
  }

  void _navigateToHistoryPage() {
    context.push('/history');
  }

  void _sendImage() {
    if (_image == null) return;

    // If AI option is selected, navigate to about screen
    if (_currentSliderIndex == 2) {
      // ✨AI✨ option
      _navigateToAboutScreen();
      return;
    }

    // For other options, create a post
    _createPost();
  }

  void _createPost() async {
    if (_image == null) return;

    // First, verify authentication by making a simple API call
    try {
      final userService = UserService();
      await userService.getProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String? caption;

    // Prepare caption based on selected option
    switch (_currentSliderIndex) {
      case 0: // Caption
        caption =
            _captionController.text.isNotEmpty ? _captionController.text : null;
        break;
      case 1: // Time
        caption = '📅 $_currentTime';
        break;
      case 3: // Location
        caption = '📍 $_locationName';
        break;
      case 4: // Weather
        caption = '🌤️ $_weatherInfo';
        break;
    }

    // Create post with image upload
    if (mounted) {
      context.read<PostBloc>().add(
        PostEventCreatePostWithUpload(
          image: _image!,
          caption: caption,
          isPrivate: false, // Default to public posts
        ),
      );
    }
  }

  void _discardImage() {
    setState(() {
      _image = null;
      _isShotMode = false;
      _currentSliderIndex = 0;
    });
  }

  Future<void> _saveToDevice() async {
    if (_image != null) {
      try {
        final bytes = await _image!.readAsBytes();
        await Gal.putImageBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to device'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save image'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _slideToOption(int newIndex) {
    if (newIndex == _currentSliderIndex) return;

    final isSlideRight = newIndex > _currentSliderIndex;

    // Update slide animation direction
    _slideAnimation = Tween<Offset>(
      begin: Offset(isSlideRight ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isSlideRight ? -1.0 : 1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    setState(() {
      _currentSliderIndex = newIndex;
    });

    _slideController.forward().then((_) {
      _slideController.reset();
    });
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

  Widget _buildSliderOverlay() {
    if (!_isShotMode) return const SizedBox.shrink();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swiped right - go to previous option
          if (_currentSliderIndex > 0) {
            _slideToOption(_currentSliderIndex - 1);
          }
        } else if (details.primaryVelocity! < 0) {
          // Swiped left - go to next option
          if (_currentSliderIndex < _sliderOptions.length - 1) {
            _slideToOption(_currentSliderIndex + 1);
          }
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            // Current option
            AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return SlideTransition(
                  position:
                      _slideController.isAnimating
                          ? _slideOutAnimation
                          : Tween<Offset>(
                            begin: Offset.zero,
                            end: Offset.zero,
                          ).animate(_slideController),
                  child: Center(
                    child: Text(
                      _sliderOptions[_currentSliderIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Incoming option during animation
            if (_slideController.isAnimating)
              AnimatedBuilder(
                animation: _slideController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: Center(
                      child: Text(
                        _sliderOptions[_currentSliderIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            // Indicators
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_sliderOptions.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index == _currentSliderIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    if (!_isShotMode) return const SizedBox.shrink();

    switch (_currentSliderIndex) {
      case 0: // Caption
        return AnimatedBuilder(
          animation: _wiggleAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_wiggleAnimation.value, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _captionController,
                  focusNode: _captionFocusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Enter caption (max 12 chars)',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                  maxLength: 12,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) {
                    return Text(
                      '$currentLength/12',
                      style: TextStyle(
                        color: currentLength > 12 ? Colors.red : Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      case 1: // Time
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case 2: // AI
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '✨AI✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case 3: // Location
        return GestureDetector(
          onTap: _handleLocationTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _locationName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_locationName.contains('Getting') ||
                    _locationName.contains('unavailable'))
                  const SizedBox(width: 4),
                if (_locationName.contains('Getting') ||
                    _locationName.contains('unavailable'))
                  const Icon(Icons.refresh, color: Colors.white70, size: 14),
              ],
            ),
          ),
        );
      case 4: // Weather
        return GestureDetector(
          onTap: _handleLocationTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _weatherInfo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_weatherInfo.contains('Getting') ||
                    _weatherInfo.contains('unavailable'))
                  const SizedBox(width: 4),
                if (_weatherInfo.contains('Getting') ||
                    _weatherInfo.contains('unavailable'))
                  const Icon(Icons.refresh, color: Colors.white70, size: 14),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
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

    return GestureDetector(
      onScaleStart:
          _controller!.description.lensDirection != CameraLensDirection.front
              ? _handleScaleStart
              : null,
      onScaleUpdate:
          _controller!.description.lensDirection != CameraLensDirection.front
              ? _handleScaleUpdate
              : null,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
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
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentZoom.toStringAsFixed(1)}x',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostCreatePostWithUploadInProgress) {
          // Show loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Text('Creating post...'),
                ],
              ),
              duration: Duration(seconds: 30),
            ),
          );
        } else if (state is PostCreatePostWithUploadSuccess) {
          // Hide loading and show success
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Reset the camera state
          setState(() {
            _image = null;
            _isShotMode = false;
            _currentSliderIndex = 0;
            _captionController.clear();
          });
        } else if (state is PostCreatePostWithUploadFailure) {
          // Hide loading and show error
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create post: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
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
                      // QR scan button on the left (replacing profile image)
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const QRScannerDialog(),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.shade600,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Chat button on the right
                      IconButton(
                        onPressed: () {
                          context.push('/chat');
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
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 400,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child:
                                  _image != null
                                      ? Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                      : _buildCameraPreview(),
                            ),
                          ),
                          // Slider overlay at the top (only in shot mode)
                          if (_isShotMode)
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: _buildSliderOverlay(),
                            ),
                          // Content display in the center (only in shot mode)
                          if (_isShotMode)
                            Positioned(
                              top: 80,
                              left: 16,
                              right: 16,
                              child: _buildOverlayContent(),
                            ),
                        ],
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
                        onPressed:
                            _isShotMode ? _discardImage : _getImageFromGallery,
                        icon: Icon(
                          _isShotMode ? Icons.close : Icons.photo_library,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: _isShotMode ? _sendImage : _takePicture,
                        backgroundColor: Colors.white,
                        child: Icon(
                          _isShotMode ? Icons.send : Icons.camera,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: _isShotMode ? _saveToDevice : _flipCamera,
                        icon: Icon(
                          _isShotMode ? Icons.save_alt : Icons.flip_camera_ios,
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
      ),
    );
  }
}
