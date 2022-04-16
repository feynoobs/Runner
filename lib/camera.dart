import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class Camera extends StatefulWidget
{
    const Camera({Key? key}) : super(key: key);

    @override
    _CameraState createState() => _CameraState();
}


class _CameraState extends State<Camera>
{
    final _logger = Logger();
    bool _isRunning = false;
    CameraController? _controller;
    String _text = 'aaaaa';

    @override
    void initState()
    {
        super.initState();
        availableCameras().then((cameras) {
            CameraDescription? camera;
            for (var element in cameras) {
                if (element.lensDirection == CameraLensDirection.back) {
                    camera = element;
                }
            }
            if (camera == null) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AlertDialog(
                        title: Text('確認'),
                        content: Text('このアプリはリアカメラが必要です'),
                        actions: [
                            TextButton(child: Text('OK'), onPressed: () => Navigator.pop(context))
                        ]
                    )
                );
            }
            else {
                _controller = CameraController(camera, ResolutionPreset.max);
                _controller!.initialize().then((_) {
                    _controller?.startImageStream((CameraImage image) async {
                        if (_isRunning == false) {
                            _isRunning = true;
                            _text = '';
                            final RecognisedText rt = await GoogleMlKit.vision.textDetector().processImage(_createInputImageFromCameraImage(image));
                            for (TextBlock block in rt.blocks) {
                                for (TextLine line in block.lines) {
                                    for (TextElement elem in line.elements) {
                                        _text += elem.text;
                                    }
                                }
                            }
                            _logger.v(_text);
                            if (mounted == true) {
                                setState(() {});
                            }
                            _isRunning = false;
                        }
                    });
                });
            }
        });
    }

    @override
    Widget build(BuildContext context)
    {
        Widget preview;

        if (_controller == null) {
            preview = Container();
        }
        else {
            preview = CameraPreview(_controller!);
        }

        return MaterialApp(
            home: Scaffold(
                body: Center(child: Stack(
                    children: <Widget>[
                        preview,
                        Text(
                            _text,
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.orange
                            ),
                        )
                    ])
                ),
                floatingActionButton: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.back_hand),
                )
            )
        );
    }

    @override
    void dispose()
    {
        _controller?.dispose();
        super.dispose();
    }

    InputImage _createInputImageFromCameraImage(CameraImage cameraImage)
    {
        final WriteBuffer buffer = WriteBuffer();
        for (Plane plane in cameraImage.planes) {
            buffer.putUint8List(plane.bytes);
        }

        InputImageRotation rotate = InputImageRotation.Rotation_0deg;
        switch (_controller?.description.sensorOrientation) {
            case 0:
                rotate = InputImageRotation.Rotation_0deg;
                break;
            case 90:
                rotate = InputImageRotation.Rotation_90deg;
                break;
            case 180:
                rotate = InputImageRotation.Rotation_180deg;
                break;
            case 270:
                rotate = InputImageRotation.Rotation_270deg;
                break;
        }

        final InputImageData data = InputImageData(
            size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
            imageRotation: rotate,
            inputImageFormat: InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ?? InputImageFormat.NV21,
            planeData: cameraImage.planes.map((Plane plane) => InputImagePlaneMetadata(bytesPerRow: plane.bytesPerRow, height: plane.height, width: plane.width)).toList()
        );

        return InputImage.fromBytes(bytes: buffer.done().buffer.asUint8List(), inputImageData: data);
    }
}
