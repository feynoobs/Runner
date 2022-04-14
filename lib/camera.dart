import 'package:flutter/material.dart';

class Camera extends StatelessWidget
{
    const Camera({Key? key}) : super(key: key);

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
