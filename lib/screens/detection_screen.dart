import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:typed_data';
import '../utils/ar_overlay_painter.dart';
import '../utils/image_processor.dart';
import 'driver_profile_screen.dart';
import 'detection_history_screen.dart';
import 'emergency_data_screen.dart';

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
      debugPrint('Iniciando carga del modelo...');

      // Verificar que el archivo existe usando una ruta más específica
      final modelFile = await DefaultAssetBundle.of(context)
          .load('assets/modelo_somnolencia_4clases.tflite');
      debugPrint(
          'Tamaño del archivo del modelo: ${modelFile.lengthInBytes} bytes');

      // Carga modelo usando la ruta completa
      _interpreter = await Interpreter.fromAsset(
          'assets/modelo_somnolencia_4clases.tflite');
      debugPrint('Modelo cargado exitosamente');

      // Carga labels
      final labelsData =
          await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      debugPrint('Etiquetas cargadas: ${_labels.join(", ")}');

      if (mounted) {
        setState(() {
          _modelLoaded = true;
          _detectionStatus = "Ready";
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error al cargar el modelo: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _detectionStatus = "Error al cargar el modelo: $e";
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

    // Reducir la frecuencia de procesamiento
    Timer? processingTimer;
    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting || !_modelLoaded) return;

      // Procesar solo cada 500ms
      if (processingTimer?.isActive ?? false) return;
      processingTimer = Timer(const Duration(milliseconds: 500), () {});

      _isDetecting = true;

      try {
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

          // Ordenar resultados por confianza
          results.sort((a, b) =>
              (b['confidence'] as double).compareTo(a['confidence'] as double));

          if (mounted) {
            setState(() {
              _recognitions = results;
              _updateDetectionStatus();
            });
          }
        }
      } catch (e) {
        debugPrint('Error en la detección: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  void _updateDetectionStatus() {
    if (_recognitions == null || _recognitions!.isEmpty) {
      _detectionStatus = "No detection";
      _alertLevel = 0;
      return;
    }

    final highestConfidence = _recognitions!.first;
    final label = highestConfidence["label"] as String;
    final confidence = highestConfidence["confidence"] as double;

    if (mounted) {
      setState(() {
        switch (label) {
          case "Awake":
            _detectionStatus =
                "Awake (${(confidence * 100).toStringAsFixed(1)}%)";
            _alertLevel = 0;
            break;
          case "Drowsy":
            _detectionStatus =
                "Drowsy (${(confidence * 100).toStringAsFixed(1)}%)";
            _alertLevel = 1;
            _triggerWarning();
            break;
          case "Yawning":
            _detectionStatus =
                "Yawning (${(confidence * 100).toStringAsFixed(1)}%)";
            _alertLevel = 1;
            _triggerWarning();
            break;
          case "Eyes Closed":
            _detectionStatus =
                "Eyes Closed (${(confidence * 100).toStringAsFixed(1)}%)";
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
      appBar: AppBar(
        title: const Text('Detección de Somnolencia'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetectionHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emergency),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyDataScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          if (_showAROverlay)
            CustomPaint(
              painter: AROverlayPainter(
                alertLevel: _alertLevel,
                recognitions: _recognitions,
                screenSize: MediaQuery.of(context).size,
              ),
              size: Size.infinite,
            ),
          // Estado de detección en la parte inferior
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.black54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _detectionStatus,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_recognitions != null && _recognitions!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ..._recognitions!.map((recognition) {
                      final confidence =
                          (recognition["confidence"] * 100).toStringAsFixed(1);
                      return Text(
                        '${recognition["label"]}: $confidence%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
          // Indicador de estado en la esquina superior derecha
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
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
}
