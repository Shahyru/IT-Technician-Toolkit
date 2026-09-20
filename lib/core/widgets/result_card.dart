import 'package:flutter/material.dart';
import '../utils/clipboard_utils.dart';
import 'app_card.dart';

class ResultRowData {
  final String label;
  final String value;
  final bool isMonospace;
  final Color? valueColor;
  final String? tooltip;
  final bool allowCopy;

  const ResultRowData({
    required this.label,
    required this.value,
    this.isMonospace = true,
    this.valueColor,
    this.tooltip,
    this.allowCopy = true,
  });
}

class ResultCard extends StatelessWidget {
  final String title;
  final List<ResultRowData> rows;
  final Widget? trailing;

  const ResultCard({
    super.key,
    required this.title,
    required this.rows,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      row.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: row.isMonospace ? 'monospace' : null,
                        color: row.valueColor ?? theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  if (row.allowCopy)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 14),
                      tooltip: 'Copy ${row.label}',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      onPressed: () => ClipboardUtils.copyWithFeedback(
                        context,
                        row.value,
                        message: '${row.label} copied',
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
