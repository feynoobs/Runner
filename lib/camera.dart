import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

class Camera extends StatefulWidget
{
    const Camera({Key? key}) : super(key: key);

    @override
    _CameraState createState() => _CameraState();
}


class _CameraState extends State<Camera>
{
    final logger = Logger();

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
        });
    }

    @override
    Widget build(BuildContext context)
    {
        return MaterialApp(
            home: Scaffold(
                floatingActionButton: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.back_hand),
                )
            )
        );
    }
}
