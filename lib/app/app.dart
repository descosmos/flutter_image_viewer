import 'dart:io';
import 'dart:math' as math;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../features/toolbar/toolbar.dart';
import '../features/viewer/image_viewer.dart';
import '../models/image_model.dart';
import '../models/sample_models.dart';
import 'constants.dart';

class ImageBrowserApp extends StatelessWidget {
  const ImageBrowserApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Browser',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.card,
      ),
      home: const ImageBrowserScreen(),
    );
  }
}

class ImageBrowserScreen extends StatefulWidget {
  const ImageBrowserScreen({Key? key}) : super(key: key);

  @override
  State<ImageBrowserScreen> createState() => _ImageBrowserScreenState();
}

class _ImageBrowserScreenState extends State<ImageBrowserScreen> {
  final List<ImageModel> _history = [];
  ImageModel? _currentImage;
  bool _showPre = false;
  bool _showNext = false;
  bool _loadedSample = false;
  final ImageViewerController _controller = ImageViewerController();

  void _pickImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    final file = File(result.files.single.path!);
    final newImage = ImageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: result.files.single.name,
      path: file.path,
      file: file,
      isSvg: result.files.single.extension == 'svg',
    );

    setState(() {
      _currentImage = newImage;
      _history.add(newImage);
      _updateHistory();
    });
  }

  void _updateHistory() {
    if (_history.isEmpty) {
      setState(() {
        _showPre = false;
        _showNext = false;
      });
      return;
    }
    _showPre = true;
    _showNext = true;
    final index = _history.indexOf(_currentImage!);
    if (index == 0) {
      _showPre = false;
    }
    if (index == _history.length - 1) {
      _showNext = false;
    }
    setState(() {});
  }

  void _togglePrevImage() {
    if (_history.isEmpty) {
      return;
    }
    final index = _history.indexOf(_currentImage!);
    if (index == 0) {
      return;
    }
    setState(() {
      _currentImage = _history[index - 1];
      _updateHistory();
    });
  }

  void _toggleNextImage() {
    if (_history.isEmpty) {
      return;
    }
    final index = _history.indexOf(_currentImage!);
    if (index == _history.length - 1) {
      return;
    }
    setState(() {
      _currentImage = _history[index + 1];
      _updateHistory();
    });
  }

  void _toggleZoomOut() {
    _controller.scaleTo(_controller.scale() * 0.8);
  }

  void _toggleZoomIn() {
    _controller.scaleTo(_controller.scale() * 1.2);
  }

  void _toggleRotateLeft() {
    _controller.rotationTo(_controller.rotation() - (math.pi / 2));
  }

  void _toggleRotateRight() {
    _controller.rotationTo(_controller.rotation() + (math.pi / 2));
  }

  void _toggleResetToFit() {
    _controller.reset();
  }

  void _loadSample() {
    if (_loadedSample) {
      final index = _history.indexOf(sampleItems.first);
      setState(() {
        _currentImage = _history[index];
        _updateHistory();
      });
      return;
    }
    final currentIndex =
        _history.isEmpty ? -1 : _history.indexOf(_currentImage!);
    sampleItems.forEach((model) {
      _history.add(model);
    });
    setState(() {
      _currentImage = _history[currentIndex + 1];
      _updateHistory();
    });
    _loadedSample = true;
  }

  void _returnToStart() {
    setState(() {
      _currentImage = null;
      _showPre = false;
      _showNext = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppToolbar(
            image: _currentImage,
            showPre: _showPre,
            showNext: _showNext,
            onPrevImage: _togglePrevImage,
            onNextImage: _toggleNextImage,
            onZoomOut: _toggleZoomOut,
            onZoomIn: _toggleZoomIn,
            onRotateLeft: _toggleRotateLeft,
            onRotateRight: _toggleRotateRight,
            onResetFit: _toggleResetToFit,
            onPickFiles: _pickImage,
            onLoadSample: _loadSample,
            onReturnToStart: _returnToStart,
          ),
          Expanded(
            child: DropTarget(
              onDragDone: (detail) {
                setState(() {
                  final newImage = ImageModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: detail.files[0].name,
                    path: detail.files[0].path,
                    file: File(detail.files[0].path),
                    isSvg: detail.files[0].name.split('.').last == '.svg',
                  );
                  _history.add(newImage);
                  _currentImage = newImage;
                  _updateHistory();
                });
              },
              child: SizedBox.expand(
                child: ImageViewer(
                  controller: _controller,
                  image: _currentImage,
                  onPickImage: _pickImage,
                  onLoadSample: _loadSample,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
