import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

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
  String _detectedObject = 'Scan an item...';
  bool _isProcessing = false;


  final Set<String> _recyclableKeywords = {
    'plastic', 'bottle', 'can', 'paper', 'cardboard', 'glass', 'metal', 'aluminum', 'tin', 
    'container', 'recyclable', 'carton', 'box', 'jug', 'wrapper', 'bag', 'polyethylene', 
    'polystyrene', 'pet', 'hdpe', 'steel', 'scrap'
  };

  @override
  void initState() {
    super.initState();
    _initializeVision();
  }

  Future<void> _initializeVision() async {
    // No explicit initialization needed for googleapis, but we can validate credentials exist
    try {
      await rootBundle.loadString('lib/assets/service_credentials.json');
    } catch (e) {
      debugPrint('Error finding service credentials: $e');
    }
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraOpen = true;
        _capturedImage = null;
        _resultText = '';
        _detectedObject = 'Unknown';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Camera error: $e')));
    }
  }

  Future<void> _scanAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    AutoRefreshingAuthClient? client;
    try {
      final XFile pic = await _controller!.takePicture();
      final imageFile = File(pic.path);
      
      String detected = 'Unknown';
      bool recyclable = false;

      // Load Service Account Credentials
      final jsonString = await rootBundle.loadString('lib/assets/service_credentials.json');
      final credentials = ServiceAccountCredentials.fromJson(jsonString);
      
      // Get Authenticated Client
      client = await clientViaServiceAccount(credentials, [vision.VisionApi.cloudPlatformScope]);
      final visionApi = vision.VisionApi(client);

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = vision.AnnotateImageRequest(
        image: vision.Image(content: base64Image),
        features: [
          vision.Feature(maxResults: 10, type: 'LABEL_DETECTION'),
          vision.Feature(maxResults: 5, type: 'OBJECT_LOCALIZATION'),
        ],
      );

      final batchRequest = vision.BatchAnnotateImagesRequest(requests: [request]);
      final batchResponse = await visionApi.images.annotate(batchRequest);

      if (batchResponse.responses != null && batchResponse.responses!.isNotEmpty) {
        final response = batchResponse.responses!.first;
        
        // Prioritize object localization if available, otherwise labels
        if (response.localizedObjectAnnotations != null && response.localizedObjectAnnotations!.isNotEmpty) {
           detected = response.localizedObjectAnnotations!.first.name ?? 'Unknown Object';
        } else if (response.labelAnnotations != null && response.labelAnnotations!.isNotEmpty) {
           detected = response.labelAnnotations!.first.description ?? 'Unknown Label';
        }
         
        // Check recyclability against all labels found
        final allLabels = <String>[];
        if (response.localizedObjectAnnotations != null) {
          allLabels.addAll(response.localizedObjectAnnotations!.map((e) => e.name ?? '').where((s) => s.isNotEmpty));
        }
        if (response.labelAnnotations != null) {
          allLabels.addAll(response.labelAnnotations!.map((e) => e.description ?? '').where((s) => s.isNotEmpty));
        }
        
        recyclable = allLabels.any((label) =>
            _recyclableKeywords.any((kw) => label.toLowerCase().contains(kw)));
      } else {
        detected = "No response from Vision API";
      }

      setState(() {
        _capturedImage = imageFile;
        _detectedObject = detected;
        _isRecyclable = recyclable;
        _resultText = recyclable ? "Recyclable" : "Not Recyclable";
        _isCameraOpen = false;
      });

      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      debugPrint('Scan error: $e');
      setState(() {
        _resultText = "Scan error";
        _isCameraOpen = false;
      });
    } finally {
      client?.close();
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraOpen) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null && _controller!.value.isInitialized) CameraPreview(_controller!),
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
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : FloatingActionButton.extended(
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

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Scanning result'),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
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
                child: Image.file(_capturedImage!, height: 320, width: double.infinity, fit: BoxFit.cover),
              )
            else
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Text(
                _detectedObject,
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening map...'))),
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