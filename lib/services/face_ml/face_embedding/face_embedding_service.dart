import 'dart:io';
import "dart:math" show min, max;
// import 'dart:math' as math show min, max;
import 'dart:typed_data' show Uint8List;

import "package:logging/logging.dart";
import 'package:photos/models/ml/ml_typedefs.dart';
import "package:photos/services/face_ml/face_detection/detection.dart";
import "package:photos/services/face_ml/face_embedding/face_embedding_exceptions.dart";
import "package:photos/services/face_ml/face_embedding/face_embedding_options.dart";
import "package:photos/services/face_ml/face_embedding/mobilefacenet_model_config.dart";
import 'package:photos/utils/image_ml_isolate.dart';
import 'package:photos/utils/image_ml_util.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// This class is responsible for running the MobileFaceNet model, and can be accessed through the singleton `FaceEmbedding.instance`.
class FaceEmbedding {
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  int get getAddress => _interpreter!.address;

  final outputShapes = <List<int>>[];
  final outputTypes = <TensorType>[];

  final _logger = Logger("FaceEmbeddingService");

  final MobileFaceNetModelConfig config;
  late final FaceEmbeddingOptions embeddingOptions;
  // singleton pattern
  FaceEmbedding._privateConstructor({required this.config});

  /// Use this instance to access the FaceEmbedding service. Make sure to call `init()` before using it.
  /// e.g. `await FaceEmbedding.instance.init();`
  ///
  /// Then you can use `predict()` to get the embedding of a face, so `FaceEmbedding.instance.predict(imageData)`
  ///
  /// config options: faceEmbeddingEnte
  static final instance =
      FaceEmbedding._privateConstructor(config: faceEmbeddingEnte);
  factory FaceEmbedding() => instance;

  /// Check if the interpreter is initialized, if not initialize it with `loadModel()`
  Future<void> init() async {
    if (_interpreter == null || _isolateInterpreter == null) {
      await _loadModel();
    }
  }

  /// WARNING: This function only works for one face at a time. it's better to use [predict], which can handle both single and multiple faces.
  Future<List<double>> predictSingle(
    Uint8List imageData,
    FaceDetectionRelative face,
  ) async {
    assert(_interpreter != null && _isolateInterpreter != null);

    final stopwatch = Stopwatch()..start();

    // Image decoding and preprocessing
    List<List<List<List<double>>>> input;
    List output;
    try {
      final stopwatchDecoding = Stopwatch()..start();
      final (inputImageMatrix, transformationMatrices) =
          await ImageMlIsolate.instance.preprocessMobileFaceNet(
        imageData,
        [face],
      );
      input = inputImageMatrix;
      stopwatchDecoding.stop();
      _logger.info(
        'Image decoding and preprocessing is finished, in ${stopwatchDecoding.elapsedMilliseconds}ms',
      );

      output = createEmptyOutputMatrix(outputShapes[0]);
    } catch (e) {
      _logger.severe('Error while decoding and preprocessing image: $e');
      throw MobileFaceNetImagePreprocessingException();
    }

    _logger.info('interpreter.run is called');
    // Run inference
    try {
      await _isolateInterpreter!.run(input, output);
      // _interpreter!.run(input, output);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _logger.severe('Error while running inference: $e');
      throw MobileFaceNetInterpreterRunException();
    }
    _logger.info('interpreter.run is finished');

    // Get output tensors
    final embedding = output[0] as List<double>;

    stopwatch.stop();
    _logger.info(
      'predict() executed in ${stopwatch.elapsedMilliseconds}ms',
    );

    // _logger.info(
    //   'results (only first few numbers): embedding ${embedding.sublist(0, 5)}',
    // );
    // _logger.info(
    //   'Mean of embedding: ${embedding.reduce((a, b) => a + b) / embedding.length}',
    // );
    // _logger.info(
    //   'Max of embedding: ${embedding.reduce(math.max)}',
    // );
    // _logger.info(
    //   'Min of embedding: ${embedding.reduce(math.min)}',
    // );

    return embedding;
  }

  Future<List<List<double>>> predict(
    List<Double3DInputMatrix> inputImageMatrix,
  ) async {
    assert(_interpreter != null && _isolateInterpreter != null);

    final stopwatch = Stopwatch()..start();

    _checkPreprocessedInput(inputImageMatrix); // [inputHeight, inputWidth, 3]
    final input = [inputImageMatrix];

    final output = <int, Object>{};
    final outputShape = outputShapes[0];
    outputShape[0] = inputImageMatrix.length;
    output[0] = createEmptyOutputMatrix(outputShape);
    // for (int i = 0; i < faces.length; i++) {
    //   output[i] = createEmptyOutputMatrix(outputShapes[0]);
    // }

    _logger.info('interpreter.run is called');
    // Run inference
    final stopwatchInterpreter = Stopwatch()..start();
    try {
      await _isolateInterpreter!.runForMultipleInputs(input, output);
      // _interpreter!.runForMultipleInputs(input, output);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _logger.severe('Error while running inference: $e');
      throw MobileFaceNetInterpreterRunException();
    }
    stopwatchInterpreter.stop();
    _logger.info(
      'interpreter.run is finished, in ${stopwatchInterpreter.elapsedMilliseconds}ms',
    );
    // _logger.info('output: $output');

    // Get output tensors
    final embeddings = <List<double>>[];
    final outerEmbedding = output[0]! as Iterable<dynamic>;
    for (int i = 0; i < inputImageMatrix.length; i++) {
      final embedding = List<double>.from(outerEmbedding.toList()[i]);
      // _logger.info("The $i-th embedding: $embedding");
      embeddings.add(embedding);
    }

    stopwatch.stop();
    _logger.info(
      'predictBatch() executed in ${stopwatch.elapsedMilliseconds}ms',
    );

    return embeddings;
  }

  Future<void> _loadModel() async {
    _logger.info('loadModel is called');

    embeddingOptions = config.faceEmbeddingOptions;

    try {
      final interpreterOptions = InterpreterOptions();

      // Android Delegates
      // TODO: Make sure this works on both platforms: Android and iOS
      if (Platform.isAndroid) {
        // Use GPU Delegate (GPU). WARNING: It doesn't work on emulator
        interpreterOptions.addDelegate(GpuDelegateV2());
        // Use XNNPACK Delegate (CPU)
        interpreterOptions.addDelegate(XNNPackDelegate());
      }

      // iOS Delegates
      if (Platform.isIOS) {
        // Use Metal Delegate (GPU)
        interpreterOptions.addDelegate(GpuDelegate());
      }

      // Load model from assets
      _interpreter ??= await Interpreter.fromAsset(
        config.modelPath,
        options: interpreterOptions,
      );
      _isolateInterpreter ??=
          IsolateInterpreter(address: _interpreter!.address);

      _logger.info('Interpreter created from asset: ${config.modelPath}');

      // Get tensor input shape [1, 112, 112, 3]
      final inputTensors = _interpreter!.getInputTensors().first;
      _logger.info('Input Tensors: $inputTensors');
      // Get tensour output shape [1, 192]
      final outputTensors = _interpreter!.getOutputTensors();
      final outputTensor = outputTensors.first;
      _logger.info('Output Tensors: $outputTensor');

      for (var tensor in outputTensors) {
        outputShapes.add(tensor.shape);
        outputTypes.add(tensor.type);
      }
      _logger.info('outputShapes: $outputShapes');
      _logger.info('loadModel is finished');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _logger.severe('Error while creating interpreter: $e');
      throw MobileFaceNetInterpreterInitializationException();
    }
  }

  void _checkPreprocessedInput(
    List<Double3DInputMatrix> inputMatrix,
  ) {
    final embeddingOptions = config.faceEmbeddingOptions;

    if (inputMatrix.isEmpty) {
      // Check if the input is empty
      throw MobileFaceNetEmptyInput();
    }

    // Check if the input is the correct size
    if (inputMatrix[0].length != embeddingOptions.inputHeight ||
        inputMatrix[0][0].length != embeddingOptions.inputWidth) {
      throw MobileFaceNetWrongInputSize();
    }

    final flattened = inputMatrix[0].expand((i) => i).expand((i) => i);
    final minValue = flattened.reduce(min);
    final maxValue = flattened.reduce(max);

    if (minValue < -1 || maxValue > 1) {
      throw MobileFaceNetWrongInputRange();
    }
  }
}
