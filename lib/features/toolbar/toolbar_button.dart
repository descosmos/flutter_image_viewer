import 'package:flutter/material.dart';

import '../../app/constants.dart';

class ToolbarButton extends StatelessWidget {

  const ToolbarButton({
    Key ? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  })  :super(key: key);
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      color: Colors.white,
      hoverColor: AppColors.primary.withOpacity(0.2),
    );
  }
}