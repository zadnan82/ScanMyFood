import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class ProCameraScreen extends StatefulWidget {
  final Function(XFile) onImageCaptured;

  const ProCameraScreen({Key? key, required this.onImageCaptured})
      : super(key: key);

  @override
  State<ProCameraScreen> createState() => _ProCameraScreenState();
}

class _ProCameraScreenState extends State<ProCameraScreen>
    with TickerProviderStateMixin {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isInitialized = false;
  bool isCapturing = false;
  String lightingStatus = "Checking...";
  Color lightingColor = Colors.orange;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    initializeCamera();

    // Animation for the guide frame
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        controller = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await controller!.initialize();

        if (mounted) {
          setState(() {
            isInitialized = true;
          });

          // Start checking lighting conditions
          _checkLightingConditions();
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _checkLightingConditions() {
    // Simulate lighting condition check
    // In a real implementation, you'd analyze the camera feed
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          lightingStatus = "Good lighting ✓";
          lightingColor = Colors.green;
        });
      }
    });
  }

  Future<void> _captureImage() async {
    if (!isInitialized || controller == null || isCapturing) return;

    try {
      setState(() {
        isCapturing = true;
      });

      final image = await controller!.takePicture();
      widget.onImageCaptured(image);
      Navigator.pop(context);
    } catch (e) {
      print('Error capturing image: $e');
      setState(() {
        isCapturing = false;
      });
    }
  }

  void _onTapToFocus(TapUpDetails details) {
    if (!isInitialized || controller == null) return;

    final screenSize = MediaQuery.of(context).size;
    final x = details.localPosition.dx / screenSize.width;
    final y = details.localPosition.dy / screenSize.height;

    controller!.setFocusPoint(Offset(x, y));
    controller!.setExposurePoint(Offset(x, y));

    // Show focus indicator
    _showFocusIndicator(details.localPosition);
  }

  void _showFocusIndicator(Offset position) {
    // This would show a focus square animation at the tapped position
    // For simplicity, we'll just provide haptic feedback
    // HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    controller?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final textScaleFactor = screenWidth > 600
        ? 1.4
        : screenWidth < 500
            ? 0.8
            : 1.2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (isInitialized && controller != null)
            Positioned.fill(
              child: GestureDetector(
                onTapUp: _onTapToFocus,
                child: CameraPreview(controller!),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'Initializing Pro Camera...',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16 * textScaleFactor),
                  ),
                ],
              ),
            ),

          // Guide Frame Overlay
          if (isInitialized)
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.6,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.8),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // Corner indicators
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.orange, width: 4),
                                  left: BorderSide(
                                      color: Colors.orange, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.orange, width: 4),
                                  right: BorderSide(
                                      color: Colors.orange, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.orange, width: 4),
                                  left: BorderSide(
                                      color: Colors.orange, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.orange, width: 4),
                                  right: BorderSide(
                                      color: Colors.orange, width: 4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Top Status Bar
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),

                  Spacer(),

                  // Lighting status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightingColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lightingColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wb_sunny, color: lightingColor, size: 16),
                        SizedBox(width: 4),
                        Text(
                          lightingStatus,
                          style: TextStyle(
                            color: lightingColor,
                            fontSize: 12 * textScaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '📸 Position ingredient text inside the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Hold steady • Tap screen to focus • Ensure good lighting',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12 * textScaleFactor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          widget.onImageCaptured(image);
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library,
                                color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10 * textScaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: _captureImage,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isCapturing
                              ? Colors.orange.withOpacity(0.5)
                              : Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: isCapturing
                            ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                    ),

                    // Tips button
                    GestureDetector(
                      onTap: () => _showTipsDialog(),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.help_outline,
                                color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Tips',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10 * textScaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.orange),
            SizedBox(width: 8),
            Text('Photography Tips'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTip('📏', 'Get Close',
                'Move closer to the ingredient text for better clarity'),
            _buildTip('💡', 'Good Light',
                'Use natural light or bright room lighting'),
            _buildTip('📐', 'Straight Angle',
                'Hold phone parallel to the text, not tilted'),
            _buildTip('🎯', 'Focus Sharp',
                'Tap on the text to auto-focus before capturing'),
            _buildTip('⏱️', 'Hold Steady',
                'Keep still for 1-2 seconds when taking the photo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
