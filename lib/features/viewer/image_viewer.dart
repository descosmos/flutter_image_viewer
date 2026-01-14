import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_viewer/features/viewer/image_wrapper.dart';
import '../../models/image_model.dart';

const double minScale = 0.1;
const double maxScale = 10.0;

class ImageViewerController {
  _ImageViewerState? _state;

  void scaleTo(double newScale) {
    _state?._animateToScale(newScale);
  }

  double scale() {
    return _state?._targetScale ?? 1.0;
  }

  void rotationTo(double newRotation) {
    _state?._animateRotation(newRotation);
  }

  double rotation() {
    return _state?._targetRotation ?? 0.0;
  }

  void reset() {
    scaleTo(1.0);
  }

  void _bindState(_ImageViewerState state) {
    _state = state;
  }

  void _unbind() {
    _state = null;
  }
}

class ImageViewer extends StatefulWidget {
  const ImageViewer({
    Key? key,
    required this.controller,
    required this.image,
    required this.onPickImage,
    required this.onLoadSample,
  }) : super(key: key);
  final ImageModel? image;
  final VoidCallback onPickImage;
  final VoidCallback onLoadSample;
  final ImageViewerController controller;

  @override
  _ImageViewerState createState() =>
      _ImageViewerState(image: image, onPickImage: onPickImage, onLoadSample: onLoadSample);
}

class _ImageViewerState extends State<ImageViewer>
    with TickerProviderStateMixin {
  _ImageViewerState({
    required this.image,
    required this.onPickImage,
    required this.onLoadSample,
  });

  final ImageModel? image;
  final VoidCallback onPickImage;
  final VoidCallback onLoadSample;
  TransformationController? _transformationController;
  late AnimationController _animationController;
  double _targetScale = 1.0;
  double _fromScale = 0.0;
  double _targetRotation = 0.0;
  double _fromRotation = 0.0;
  bool _isScaleAnimate = false;
  double? _scaleStart;
  late Size size;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    widget.controller._bindState(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animationController.addListener(_tick);
  }

  @override
  void didUpdateWidget(covariant ImageViewer oldWidget) {
    // reset transform
    if (oldWidget.image != widget.image) {
      _targetScale = 1.0;
      _targetRotation = 0.0;
      _transformationController = TransformationController();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toScale(double newScale) {
    final newTarget = newScale.clamp(0.1, 5.0);
    if (_targetScale == newTarget) {
      return;
    }
    _targetScale = newTarget;
    final center = size.center(Offset.zero);
    final anchor = _transformationController!.toScene(center);
    _transformationController!.value = composeMatrixFromOffsets(
      scale:_targetScale,
      anchor: anchor,
      translate: center,
      rotation:_targetRotation,
    );
  }

  void _animateToScale(double newScale) {
    final newTarget = newScale.clamp(0.1, 5.0);
    if (_targetScale == newTarget) {
      return;
    }
    _fromScale = _targetScale;
    _targetScale = newTarget;
    _isScaleAnimate = true;
    _animationController.forward(from: 0);
  }

  void _animateRotation(double newRotation) {
    if (_targetRotation == newRotation) {
      return;
    }
    _fromRotation = _targetRotation;
    _targetRotation = newRotation;
    _isScaleAnimate = false;
    _animationController.forward(from: 0);
  }

  void _tick() {
    final center = size.center(Offset.zero);
    final anchor = _transformationController!.toScene(center);
    _transformationController!.value = composeMatrixFromOffsets(
      scale: _isScaleAnimate
          ? ui.lerpDouble(_fromScale, _targetScale, _animationController.value)!
          : _targetScale,
      anchor: anchor,
      translate: center,
      rotation: _isScaleAnimate
          ? _targetRotation
          : ui.lerpDouble(
              _fromRotation, _targetRotation, _animationController.value)!,
    );
  }

  Matrix4 composeMatrixFromOffsets({
    double scale = 1,
    double rotation = 0,
    Offset translate = Offset.zero,
    Offset anchor = Offset.zero,
  }) {
    final double c = cos(rotation) * scale;
    final double s = sin(rotation) * scale;
    final double dx = translate.dx - c * anchor.dx + s * anchor.dy;
    final double dy = translate.dy - s * anchor.dx - c * anchor.dy;
    return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
  }

  @override
  void dispose() {
    widget.controller._unbind();
    _transformationController?.dispose();
    _transformationController = null;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No image selected',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onLoadSample();
            },
            child: const Text('加载示例图片'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onPickImage();
            },
            child: const Text('或者选择图片/拖拽图片到这里'),
          ),
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      size = constraints.biggest;
      return InteractiveViewer(
        alignment: Alignment.topLeft,
        maxScale: maxScale,
        minScale: minScale,
        panEnabled: false,
        scaleEnabled: false,
        boundaryMargin: EdgeInsets.all(double.infinity),
        transformationController: _transformationController,
        onInteractionStart: (details) {
          _scaleStart = _targetScale;
        },
        onInteractionUpdate: (details) {
          if (_scaleStart != null) {
            _toScale(_scaleStart! * details.scale);
          }
        },
        onInteractionEnd: (details) {
          _scaleStart = null;
        },
        child: ImageWrapper(source: widget.image),
      );
    });
  }
}
