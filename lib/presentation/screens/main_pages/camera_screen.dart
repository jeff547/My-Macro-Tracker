import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final String selectedDate;

  const CameraScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  bool cameraLoaded = false;
  CameraController? cameraController;
  Interpreter? interpreter;
  List<String>? labels;
  String? predictedLabel;

  @override
  void initState() {
    super.initState();
    setupCameraAndModel();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    interpreter?.close();
    super.dispose();
  }

  Future<void> setupCameraAndModel() async {
    await initCamera(); // Camera is initialized
    if (!mounted) return;
    await loadModelAndLabels(); // Load model
  }

  Future<void> initCamera() async {
    try {
      final List<CameraDescription> _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        setState(() {
          cameras = _cameras;
          cameraController = CameraController(
            cameras.first,
            ResolutionPreset.high,
          );
        });
        await cameraController?.initialize();
        if (!mounted) return;
        setState(() {
          cameraLoaded = true;
        });
      }
    } catch (e) {
      print('Error with camera: $e');
    }
  }

  Future<void> loadModelAndLabels() async {
    try {
      final delegate = switch (defaultTargetPlatform) {
        // Use Metal delegate for IOS
        TargetPlatform.iOS => CoreMlDelegate(),
        // Use XNN Pack delegate for android and other platforms
        _ => XNNPackDelegate(),
      };
      interpreter = await Interpreter.fromAsset(
        'assets/models/food101_vit.tflite',
        options: InterpreterOptions()..addDelegate(delegate),
      );
      labels = await loadLabels('assets/labels.txt');
    } catch (e) {
      log('Delegate failed, falling back to CPU: $e');
      interpreter = await Interpreter.fromAsset(
        'assets/models/food101_vit.tflite',
      );
    }
    print(interpreter.toString());
  }

  Future<List<String>> loadLabels(String path) async {
    final labelData = await rootBundle.loadString(path);
    return labelData.split('\n');
  }

  List<List<List<double>>> preprocessImage(img.Image image) {
    // Resize the image
    img.Image resizedImage = img.copyResize(image, width: 384, height: 384);

    // Instantiate the input tensor
    List<List<List<double>>> inputImage = List.generate(
        3,
        // 3 Color Channels: 0=R, 1=G, 2=B
        (color) => List.generate(
            384,
            (y) => List.generate(384, (x) {
                  final pixel = resizedImage.getPixel(x, y);
                  switch (color) {
                    case 0:
                      return pixel.rNormalized.toDouble();
                    case 1:
                      return pixel.gNormalized.toDouble();
                    case 2:
                      return pixel.bNormalized.toDouble();
                    default:
                      return 0.0;
                  }
                })));

    return inputImage;
  }

  Future<void> classifyImage(String imagePath) async {
    final imageFile = File(imagePath);
    img.Image? imageInput = img.decodeImage(imageFile.readAsBytesSync());

    if (imageInput != null) {
      var inputImage = preprocessImage(imageInput);

      var input = [inputImage];

      var output =
          List<List<double>>.generate(1, (_) => List<double>.filled(101, 0.0));

      interpreter?.run(input, output);

      var predictionIndex = output[0]
          .indexOf(output[0].reduce((curr, next) => curr > next ? curr : next));

      setState(() {
        predictedLabel = labels![predictionIndex];
      });
      print(predictedLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photo(),
            // On image capture button press
            onMediaTap: (mediaCapture) async {
              final path = mediaCapture.captureRequest.path;
              // Only classify pictures that were saved successfully.
              if (path == null || !mediaCapture.isPicture) {
                return;
              }
              await classifyImage(path);
            },
          ),
        ),
      ),
    );
  }
}

//  Stack(
//             children: [
//               CameraPreview(cameraController!),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: IconButton(
//                   onPressed: () async {
//                     XFile picture = await cameraController!.takePicture();
//                     await classifyImage(picture.path);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SearchPage(
//                           selectedDate: widget.selectedDate,
//                           predictedLabel: predictedLabel,
//                         ),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.camera_alt),
//                   iconSize: 100,
//                 ),
//               ),
//             ],
//           ),
