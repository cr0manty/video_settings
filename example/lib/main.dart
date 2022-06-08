import 'package:flutter/material.dart';
import 'dart:async';

import 'package:video_settings/video_settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _render = ExampleVideoRenderer();
  final _cameraController = CameraController();
  bool _isCameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> init() async {
    _isCameraPermissionGranted = await _render.requestCameraPermission();

    if (_isCameraPermissionGranted) {
      final device = await _cameraController.defaultDevice();
      await _render.init(device);
      setState(() {});

    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          if (!_isCameraPermissionGranted) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const Center(
                child: Text(
                  'Permission is not granted',
                ),
              ),
            );
          }
          return VideoView(
            _render,
          );
        }),
      ),
    );
  }
}
