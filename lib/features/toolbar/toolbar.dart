import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/image_model.dart';
import 'toolbar_button.dart';

class AppToolbar extends StatelessWidget {
  const AppToolbar({
    Key? key,
    required this.image,
    required this.showPre,
    required this.showNext,
    required this.onPrevImage,
    required this.onNextImage,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onResetFit,
    required this.onPickFiles,
    required this.onLoadSample,
  }) : super(key: key);

  final ImageModel? image;
  final bool showPre;
  final bool showNext;
  final VoidCallback onPrevImage;
  final VoidCallback onNextImage;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onResetFit;
  final VoidCallback onPickFiles;
  final VoidCallback onLoadSample;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.toolbarHeight,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox.shrink(),
          ),
          Expanded(
            flex: 1,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: ToolbarButton(
                  icon: Icons.navigate_before_outlined,
                  onPressed: showPre
                      ? () {
                          if (image != null) {
                            onPrevImage();
                          }
                        }
                      : null,
                ),
              ),
              Flexible(
                child: Tooltip(
                  message: image?.title ?? 'No image',
                  child: Text(
                    image?.title ?? 'No image',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                child: ToolbarButton(
                  icon: Icons.navigate_next_outlined,
                  onPressed: showNext
                      ? () {
                          if (image != null) {
                            onNextImage();
                          }
                        }
                      : null,
                ),
              ),
            ]),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToolbarButton(
                  icon: Icons.zoom_out,
                  onPressed: () {
                    if (image != null) {
                      onZoomOut();
                    }
                  },
                ),
                ToolbarButton(
                  icon: Icons.zoom_in,
                  onPressed: () {
                    if (image != null) {
                      onZoomIn();
                    }
                  },
                ),
                ToolbarButton(
                  icon: Icons.rotate_left,
                  onPressed: () {
                    if (image != null) {
                      onRotateLeft();
                    }
                  },
                  tooltip: "向左旋转",
                ),
                ToolbarButton(
                  icon: Icons.rotate_right,
                  onPressed: () {
                    if (image != null) {
                      onRotateRight();
                    }
                  },
                  tooltip: "向右旋转",
                ),
                ToolbarButton(
                  icon: Icons.aspect_ratio,
                  onPressed: () {
                    if (image != null) {
                      onResetFit();
                    }
                  },
                  tooltip: "适应屏幕",
                ),
                ToolbarButton(
                  icon: Icons.file_open,
                  onPressed: () {
                    onPickFiles();
                  },
                  tooltip: "选择文件",
                ),
                ToolbarButton(
                  icon: Icons.extension,
                  onPressed: () {
                    onLoadSample();
                  },
                  tooltip: "加载样例图片",
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
