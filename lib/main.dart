import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  configWindow();
  runApp(const ImageBrowserApp());
}

void configWindow () async {
  PaintingBinding.instance.imageCache.maximumSize = 1;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1;

  await windowManager.restore();
  await windowManager.show();
  await windowManager.focus();
  await windowManager.setMinimumSize(const Size(870, 650));
}