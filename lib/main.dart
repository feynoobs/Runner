import 'package:flutter/material.dart';

import 'camera.dart';

void main()
{
    runApp(MaterialApp(
        initialRoute: '/home',
        routes: {
            '/home': (context) => const Runner(),
            '/camera': (context) => const Camera()
        },
    ));
}

class Runner extends StatelessWidget
{
    const Runner({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                floatingActionButton: FloatingActionButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Camera())),
                    child: const Icon(Icons.camera),
                )
            )
        );
    }
}
