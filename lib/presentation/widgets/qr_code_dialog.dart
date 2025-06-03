import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lacquer/config/env.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

class QRCodeDialog extends StatefulWidget {
  final String? token;

  const QRCodeDialog({super.key, required this.token});

  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog>
    with TickerProviderStateMixin {
  String? qrCodeData;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _fetchQRCode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchQRCode() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        '${Env.serverURL}/auth/qrcode',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      print('QR Code Status: ${response.statusCode}'); // Debug print
      print('QR Code Response: ${response.data}'); // Debug print

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null && responseData is Map) {
          // Handle the actual API response format: {success: true, message: "...", data: {qrcode: "..."}}
          if (responseData.containsKey('data') && responseData['data'] is Map) {
            final data = responseData['data'] as Map;
            if (data.containsKey('qrcode')) {
              final qrCodeValue = data['qrcode'];
              print(
                'QR Code Value Type: ${qrCodeValue.runtimeType}',
              ); // Debug print
              print(
                'QR Code Value Length: ${qrCodeValue?.toString().length ?? 0}',
              ); // Debug print

              setState(() {
                qrCodeData = qrCodeValue?.toString();
                isLoading = false;
              });
            } else {
              setState(() {
                errorMessage = 'QR code not found in response data';
                isLoading = false;
              });
            }
          } else {
            // Fallback for direct qrcode format
            if (responseData.containsKey('qrcode')) {
              final qrCodeValue = responseData['qrcode'];
              setState(() {
                qrCodeData = qrCodeValue?.toString();
                isLoading = false;
              });
            } else {
              setState(() {
                errorMessage =
                    'Invalid response format: ${responseData.toString()}';
                isLoading = false;
              });
            }
          }
        } else {
          setState(() {
            errorMessage = 'Invalid response data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load QR code (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      print('QR Code Error: $e'); // Debug print
      print('QR Code Error Type: ${e.runtimeType}'); // Debug print
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Uint8List? _parseBase64Image(String base64String) {
    try {
      print(
        'Original base64 string: ${base64String.substring(0, math.min(100, base64String.length))}...',
      ); // Debug print first 100 chars

      String cleanBase64;

      // Handle different base64 formats
      if (base64String.startsWith('data:image/')) {
        // Format: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...
        final parts = base64String.split(',');
        if (parts.length >= 2) {
          cleanBase64 = parts[1];
        } else {
          // Malformed data URL
          cleanBase64 = base64String.replaceAll(
            RegExp(r'^data:image\/[^;]+;base64'),
            '',
          );
        }
      } else if (base64String.startsWith('iVBORw0KGgo') ||
          base64String.startsWith('/9j/') ||
          base64String.startsWith('R0lGOD')) {
        // Looks like pure base64 (PNG, JPEG, GIF signatures)
        cleanBase64 = base64String;
      } else {
        // Try to clean any non-base64 characters
        cleanBase64 = base64String.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      }

      // Add padding if necessary
      while (cleanBase64.length % 4 != 0) {
        cleanBase64 += '=';
      }

      print('Clean base64 length: ${cleanBase64.length}'); // Debug print
      print(
        'Clean base64 sample: ${cleanBase64.substring(0, math.min(50, cleanBase64.length))}...',
      ); // Debug print

      return base64Decode(cleanBase64);
    } catch (e) {
      print('Base64 decode error: $e'); // Debug print
      print('Base64 decode error type: ${e.runtimeType}'); // Debug print
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade50, Colors.white],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildContent(),
                      const SizedBox(height: 20),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.qr_code_2, color: Colors.orange.shade700, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My QR Code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Share your profile easily',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: Colors.grey.shade600),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.orange.shade600,
                  ),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Generating QR Code...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SizedBox(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (qrCodeData != null) {
      final imageData = _parseBase64Image(qrCodeData!);

      if (imageData != null) {
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Image.memory(
                imageData,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none, // Keep QR code crisp
                errorBuilder: (context, error, stackTrace) {
                  print('Image.memory error: $error'); // Debug print
                  return _buildErrorFallback();
                },
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    size: 48,
                    color: Colors.orange.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Invalid QR Code Format',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to parse the received data',
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade600),
                ),
              ],
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No QR code available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorFallback() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Failed to display QR code',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'The image data may be corrupted',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _testQRCode() {
    // A test QR code that says "Hello World" in base64 PNG format
    const testQRCode =
        'iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAYAAACtWK6eAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAEfklEQVR4nO2d23LbMAiF5/0fOdu02zTpJRkJCfF9Z2Y7ExvJ/wGExPl5+Xq93i0/Pz/v6+ur/Pv1+/1d/j8ej8f7+/t7eL7rOKrjGdVxer1erdvhfM5xWMdhHYcAAACA38c/1gEAAAAAAAAAAAAAAAAAAAAAAACAbxgRAAAAAAAAAAAAAAAAAAAAALANIwIAAAAAAAAAAAAAAAAAAAAAtmFEAAAAAAAAAAAAAAAAAAAAAMA2jAgAAAAAAAAAAAAAAAAAAAAA2IYRAQAAAAAAAAAAAAAAAAAAAADbMCIAAAAAAAAAAAAAAAAAAAAAYBtGBAAAAAAAAAAAAAAAAAAAAABsw4gAAAAAAAAAAAAAAAAAAAAAgG0YEQAAAAAAAAAAAAAAAAAAAACA/w+MCAAAAAAAAAAAAAAAAAAAAFAjAgAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANswIgAAAAAAAAAAAAAAAAAAAABgG0YEAAAAAAAAAAAAAAAAAAAAAGzDiAAAAAAAAAAAAAAAAAAAAAAAALZhRAAAAAAAAAAAAAAAAAAAAADANowIAAAAAAAAAAAAAAAAAAAAANiGEQEAAAAAAAAAAAAAAAAAAAAA2zAiAAAAAAAAAAAAAAAAAAAAAGAbRgQAAAAAAAAAAAAAAAAAAAAAbMOIAAAAAAAAAAAAAAAAAAAAAIBtGBEAAAAAAAAAAAAAAAAAAAAAsA0jAgAAAAAAAAAAAAAAAAAAAAC2YUQAAAAAAAAAAAAAAAAAAAAAwDaMCAAAAAAAAAAAAAAAAAAAAADYhhEBAAAAAAAAAAAAAAAAAAAAANv8D7AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

    setState(() {
      qrCodeData = testQRCode;
      isLoading = false;
      errorMessage = null;
    });
  }

  void _testApiResponse() {
    // Test with the exact API response format provided by the user
    const apiResponse =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOKSURBVO3BQW4kSQIDQWeg/v9lXx3mwL0EkKiSWtNDs/iFmX8cZsphphxmymGmHGbKYaYcZsphphxmymGmHGbKYaYcZsphphxmyos3JeEnqTyRhKbSktBUWhKayhNJ+Ekq7zjMlMNMOcyUFx+m8klJeCIJTeVG5YkkNJUnVD4pCZ90mCmHmXKYKS++WRKeUHkiCU3lJgk3KjcqLQlN5YkkPKHynQ4z5TBTDjPlxV8mCU2lqbQktCT8lx1mymGmHGbKi79cEprKjcpNEprK3+QwUw4z5TBTXnwzlZ+k0pLwm6n8JoeZcpgph5ny4sOS8DdJQlNpSWgqN0n4zQ4z5TBTDjPlxZtU/iZJuElCU7lR+Tc5zJTDTDnMlPiFNyShqbQkfJLKTRJuVN6RhBuVloRPUvlOh5lymCmHmRK/8IYk3Ki0JDyh8klJ+CSVJ5LQVH6Tw0w5zJTDTHnxh6ncJKGptCTcqDSVloSm0pJwk4QnVN6RhBuVdxxmymGmHGZK/MIHJaGp3CShqXynJDSVmyTcqLQkPKHSktBUWhKayicdZsphphxmSvzCG5LQVG6S8J1UWhJuVJ5IQlO5SUJTaUloKi0JT6i84zBTDjPlMFNefFgSmsqNyhNJaCotCU3lJglN5UalJeFGpSWhqdyotCQ0lU86zJTDTDnMlBcfptKS0FSeSMJNEt6h8kQSblRuVFoSnlBpSWgq7zjMlMNMOcyUF99MpSXhCZWWhBuVloSm0pJwo/KOJDSVptKS0FRuVD7pMFMOM+UwU178MiotCU3lO6m8Iwk3SbhRaUl4QuUdh5lymCmHmRK/8C+WhBuVJ5Jwo9KS0FSeSEJTuUlCU/mkw0w5zJTDTHnxpiT8JJWm0pJwk4QblU9KQlO5SUJTaSotCU3lHYeZcpgph5ny4sNUPikJN0loKk+otCR8ksoTKjdJaCqfdJgph5lymCkvvlkSnlD5SUloKjdJuEnCO5LwJx1mymGmHGbKi/8YlZaEloSm0lSeSMI7VG6S0FTecZgph5lymCkv5v+otCTcqLQkNJV3JKGpfKfDTDnMlMNMefHNVL6TSktCU3mHyk0SmsoTSWgqTeUnHWbKYaYcZsqLD0vCT0rCTRKayhNJuFFpSbhRaSotCX/SYaYcZsphpsQvzPzjMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwU/4Ht9ii7fBkMHgAAAAASUVORK5CYII=';

    print('Testing with API response format');
    setState(() {
      qrCodeData = apiResponse;
      isLoading = false;
      errorMessage = null;
    });
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Debug buttons for testing
        if (errorMessage != null) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testQRCode,
                  icon: const Icon(Icons.bug_report, size: 16),
                  label: const Text('Test QR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    side: BorderSide(color: Colors.blue.shade600),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testApiResponse,
                  icon: const Icon(Icons.api, size: 16),
                  label: const Text('Test API'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                    side: BorderSide(color: Colors.green.shade600),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Main action buttons
        Row(
          children: [
            if (errorMessage != null || qrCodeData == null) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchQRCode,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fetchQRCode,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade600,
                    side: BorderSide(color: Colors.orange.shade600),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
