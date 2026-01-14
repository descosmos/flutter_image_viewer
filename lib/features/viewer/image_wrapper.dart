import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/image_model.dart';

class ImageWrapper extends StatefulWidget {
  final ImageModel? source;
  final Widget? errorWidget;

  const ImageWrapper({
    Key? key,
    required this.source,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<ImageWrapper> createState() => _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper> {
  final _channel = const MethodChannel('io.flutter.image_viewer/texture');
  int? _textureId;
  bool _textureFallback = false;

  @override
  void initState() {
    super.initState();
    _createOrDestoryTextureIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ImageWrapper oldWidget) {
    if (oldWidget.source != widget.source) {
      _createOrDestoryTextureIfNeeded();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_textureId != null) {
      _channel.invokeMethod<void>('dispose', _textureId);
    }
    super.dispose();
  }

  Future<void> _createOrDestoryTextureIfNeeded() async {
    if (_textureId != null) {
      //  await _channel.invokeMethod<void>('dispose');
       await _channel.invokeMethod<void>('dispose', _textureId);
       _textureId = null;
    }

    if (!Platform.isMacOS || !(widget.source!.isHDR ?? false)) {
      return;
    }
    try {
      final textureId = await _channel.invokeMethod<int?>(
          'createTexture', widget.source!.path);
      if (textureId != null) {
        setState(() {
          _textureId = textureId;
        });
      } else {
        setState(() {
          _textureFallback = true;
        });
      }
    } on PlatformException catch (_) {
      setState(() {
        _textureFallback = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.source == null) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    // texture, currenly only macos
    if (Platform.isMacOS && (widget.source!.isHDR ?? false) && !_textureFallback) {
      return _textureId != null ? Texture(textureId: _textureId!) : SizedBox.shrink();
    }

    // svg
    if (widget.source!.isSvg ?? false) {
      return widget.source!.file != null
          ? SvgPicture.file(widget.source!.file!)
          : SvgPicture.asset(widget.source!.path);
    }

    // network image
    if (widget.source!.isRemote ?? false) {
      return Image.network(
        widget.source!.path,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildErrorWidget();
        },
      );
    }

    // local or assets image
    return widget.source!.file != null
        ? Image(image: FileImage(widget.source!.file!))
        : Image.asset(widget.source!.path);
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }
}
