import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerDialog extends StatefulWidget {
  const QRScannerDialog({super.key});

  @override
  State<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<QRScannerDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // QR Scanner View
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.orange.shade600,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
              ),
            ),
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (isProcessing)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          'Sending friend request...',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Position the QR code within the frame to scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing && scanData.code != null) {
        _processScanResult(scanData.code!);
      }
    });
  }

  Future<void> _processScanResult(String qrContent) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      result = qrContent;
    });

    try {
      // Pause the scanner
      await controller?.pauseCamera();

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Make the friend request API call
      final response = await http.post(
        Uri.parse('https://lacquer-server.onrender.com/friend/request'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'friendId': qrContent}),
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        // Success - show success message and close dialog
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  responseData['message'] ??
                      'Friend request sent successfully!',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Handle different types of failures
        String errorMessage = 'Unknown QR';

        if (responseData['message'] != null) {
          final message = responseData['message'] as String;
          if (message.contains('Friend not found') ||
              message.contains('Cast to ObjectId failed')) {
            errorMessage = 'Unknown QR';
          } else {
            errorMessage = message;
          }
        }

        _showErrorAndRetry(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorAndRetry('Network error. Please try again.');
    }
  }

  void _showErrorAndRetry(String errorMessage) {
    // Show error snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(errorMessage)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reset state and resume camera for another scan
    setState(() {
      isProcessing = false;
      result = null;
    });

    // Resume camera after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      controller?.resumeCamera();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
