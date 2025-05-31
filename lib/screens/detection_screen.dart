import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:typed_data';
import '../utils/ar_overlay_painter.dart';
import '../utils/image_processor.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({Key? key}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  String _detectionStatus = "Initializing...";
  List<dynamic>? _recognitions;
  int _alertLevel = 0; // 0: Normal, 1: Warning, 2: Danger
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _alertTimer;
  bool _modelLoaded = false;
  bool _showAROverlay = true;

  late Interpreter _interpreter;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadModelAndLabels();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _alertTimer?.cancel();
    _interpreter.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _loadModelAndLabels() async {
    try {
      // Carga modelo
      _interpreter =
          await Interpreter.fromAsset('modelo_somnolencia_4clases.tflite');

      // Carga labels
      final labelsData =
          await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelsData.split('\n');

      if (mounted) {
        setState(() {
          _modelLoaded = true;
          _detectionStatus = "Ready";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectionStatus = "Failed to load model: $e";
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    if (_cameras != null && _cameras!.isNotEmpty) {
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {});
        _startImageStream();
      }
    } else {
      if (mounted) {
        setState(() {
          _detectionStatus = "No camera available";
        });
      }
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting || !_modelLoaded) return;

      _isDetecting = true;

      // Procesar la imagen y correr inferencia
      final inputBuffer = await ImageProcessor.processImage(image);
      if (inputBuffer != null) {
        final outputBuffer = Float32List(_labels.length);

        // Ejecutar inferencia
        _interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

        // Procesar resultados
        final results = List<Map<String, dynamic>>.generate(
          _labels.length,
          (index) => {
            'label': _labels[index],
            'confidence': outputBuffer[index],
          },
        );

        if (mounted) {
          setState(() {
            _recognitions = results;
            _updateDetectionStatus();
          });
        }
      }

      _isDetecting = false;
    });
  }

  void _updateDetectionStatus() {
    if (_recognitions == null || _recognitions!.isEmpty) {
      _detectionStatus = "No detection";
      _alertLevel = 0;
      return;
    }

    final highestConfidence = _recognitions!.reduce((curr, next) =>
        (curr["confidence"] > next["confidence"]) ? curr : next);

    final label = highestConfidence["label"] as String;
    final confidence =
        (highestConfidence["confidence"] * 100).toStringAsFixed(1);

    if (mounted) {
      setState(() {
        switch (label) {
          case "Awake":
            _detectionStatus = "Awake";
            _alertLevel = 0;
            break;
          case "Drowsy":
            _detectionStatus = "Drowsy";
            _alertLevel = 1;
            _triggerWarning();
            break;
          case "Yawning":
            _detectionStatus = "Yawning";
            _alertLevel = 1;
            _triggerWarning();
            break;
          case "Eyes Closed":
            _detectionStatus = "Eyes Closed";
            _alertLevel = 2;
            _triggerAlert();
            break;
          default:
            _detectionStatus = "Unknown";
            _alertLevel = 0;
        }
      });
    }
  }

  void _triggerWarning() {
    if (_alertTimer != null && _alertTimer!.isActive) return;

    _alertTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _alertLevel < 1) {
        timer.cancel();
        return;
      }

      Vibration.vibrate(duration: 300);
    });
  }

  void _triggerAlert() {
    if (_alertTimer != null && _alertTimer!.isActive) {
      _alertTimer!.cancel();
    }

    _alertTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _alertLevel < 2) {
        timer.cancel();
        return;
      }

      Vibration.vibrate(duration: 500, amplitude: 255);
      _audioPlayer.play(AssetSource('alerta.mp3'));
    });
  }

  Color _getStatusColor() {
    switch (_alertLevel) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon() {
    switch (_alertLevel) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.warning;
      case 2:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          if (_showAROverlay)
            CustomPaint(
              painter: AROverlayPainter(
                alertLevel: _alertLevel,
                recognitions: _recognitions,
              ),
              size: Size.infinite,
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Text(
                _detectionStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
