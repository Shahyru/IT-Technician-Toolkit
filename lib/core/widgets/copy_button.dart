import 'package:flutter/material.dart';
import '../utils/clipboard_utils.dart';

class CopyButton extends StatelessWidget {
  final String textToCopy;
  final String message;
  final String? tooltip;
  final Widget? label;
  final bool isIconButton;

  const CopyButton({
    super.key,
    required this.textToCopy,
    this.message = 'Command copied',
    this.tooltip = 'Copy to clipboard',
    this.label,
    this.isIconButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isIconButton) {
      return IconButton(
        icon: const Icon(Icons.copy, size: 18),
        tooltip: tooltip,
        onPressed: () => ClipboardUtils.copyWithFeedback(context, textToCopy, message: message),
      );
    }

    return OutlinedButton.icon(
      icon: const Icon(Icons.copy, size: 16),
      label: label ?? const Text('Copy'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () => ClipboardUtils.copyWithFeedback(context, textToCopy, message: message),
    );
  }
}
