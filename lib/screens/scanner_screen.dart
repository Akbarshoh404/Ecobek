import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isCameraOpen = false;
  CameraController? _controller;
  String _resultText = '';
  bool _isRecyclable = false;
  File? _capturedImage;

  final ImageLabeler _labeler = ImageLabeler(options: ImageLabelerOptions());

  final Set<String> _recyclableKeywords = {
    'plastic', 'paper', 'glass', 'metal', 'cardboard', 'aluminum', 'tin',
    'bottle', 'can', 'recyclable', 'recycling', 'package', 'container'
  };

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(cameras[0], ResolutionPreset.high);
      await _controller!.initialize();

      if (!mounted) return;

      setState(() => _isCameraOpen = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  Future<void> _scanAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile pic = await _controller!.takePicture();
      final imageFile = File(pic.path);

      final inputImage = InputImage.fromFilePath(pic.path);
      final labels = await _labeler.processImage(inputImage);

      bool recyclable = labels.any((label) =>
          _recyclableKeywords.any((kw) => label.label.toLowerCase().contains(kw)));

      setState(() {
        _capturedImage = imageFile;
        _isRecyclable = recyclable;
        _resultText = recyclable ? "It's Recyclable" : "Not Recyclable";
        _isCameraOpen = false; // exit camera
      });

      // Optional: clean up controller
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      setState(() {
        _resultText = "Error during scan";
        _isCameraOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _labeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraOpen) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              CameraPreview(_controller!),

            // Scan frame
            Center(
              child: Container(
                width: 280,
                height: 380,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 48,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () {
                  setState(() => _isCameraOpen = false);
                  _controller?.dispose();
                  _controller = null;
                },
              ),
            ),

            // Scan button
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF4CAF50),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text('Scan', style: TextStyle(color: Colors.white)),
                  onPressed: _scanAndProcess,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Result screen (after scan or initial state)
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Scanning result'),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            if (_capturedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _capturedImage!,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
              ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _capturedImage != null
                    ? (_isRecyclable ? 'Plastic bottle' : 'Unknown item') // can be improved with label
                    : 'No scan yet',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _resultText.isEmpty ? 'Scan something...' : _resultText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _isRecyclable ? const Color(0xFF4CAF50) : Colors.redAccent,
              ),
            ),

            const Spacer(),

            if (_capturedImage != null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // TODO: opens eco news screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening map...')),
                    );
                  },
                  child: const Text('Show Container in Map', style: TextStyle(fontSize: 18)),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: _capturedImage == null
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Start Scan', style: TextStyle(color: Colors.white)),
        onPressed: _openCamera,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}