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
    String _text = '';

    @override
    void initState()
    {
        super.initState();
        availableCameras().then((cameras) {
            // 最初に見つかった背面カメラを使用する
            CameraDescription? camera;
            for (var element in cameras) {
                if (element.lensDirection == CameraLensDirection.back) {
                    camera = element;
                    break;
                }
            }
            // 背面カメラがなかったらアラートを出す
            if (camera == null) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AlertDialog(
                        title: const Text('確認'),
                        content: const Text('このアプリはリアカメラが必要です'),
                        actions: [
                            TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))
                        ]
                    )
                );
            }
            // 背面カメラがあれば処理継続
            else {
                _controller = CameraController(camera, ResolutionPreset.max);
                // initializeがカメラ起動処理完了待ちらしい
                _controller!.initialize().then((_) {
                    // 画像読み込み
                    _controller?.startImageStream((CameraImage image) async {
                        // OCR処理中はスキップ
                        if (_isRunning == false) {
                            _isRunning = true;
                            final RecognisedText rt = await GoogleMlKit.vision.textDetector().processImage(_createInputImageFromCameraImage(image));
                            // とりあえず認識したテキストを全部つなげてみる
                            _text = '';
                            for (TextBlock block in rt.blocks) {
                                for (TextLine line in block.lines) {
                                    for (TextElement elem in line.elements) {
                                        _text += elem.text;
                                    }
                                }
                            }
                            _logger.v(_text);
                            // 認識したテキストをsetStateで描画する
                            // 画面が終わったあとにOCRの処理が戻ってくることがあるので
                            // mountedでチェックする
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

        // カメラ起動前はとりあえずコンテナ表示する
        if (_controller == null) {
            preview = Container();
        }
        // カメラ起動後はプレビューを表示する
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

    // CameraImageをOCRが処理できるInputImageに変換するメソッド
    // https://pub.dev/documentation/google_ml_kit/latest/
    // にあるソースをほぼコピペ.ぶっちゃけ全くわからない
    InputImage _createInputImageFromCameraImage(CameraImage cameraImage)
    {
        final WriteBuffer buffer = WriteBuffer();
        for (Plane plane in cameraImage.planes) {
            buffer.putUint8List(plane.bytes);
        }

        final InputImageData data = InputImageData(
            size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
            imageRotation: InputImageRotationMethods.fromRawValue(_controller!.description.sensorOrientation) ?? InputImageRotation.Rotation_0deg,
            inputImageFormat: InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ?? InputImageFormat.NV21,
            planeData: cameraImage.planes.map((Plane plane) => InputImagePlaneMetadata(bytesPerRow: plane.bytesPerRow, height: plane.height, width: plane.width)).toList()
        );

        return InputImage.fromBytes(bytes: buffer.done().buffer.asUint8List(), inputImageData: data);
    }
}
