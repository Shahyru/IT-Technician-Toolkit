import 'package:flutter/material.dart';

enum ToolCategory {
  network,
  calculators,
  generators,
  references,
  troubleshooting,
}

extension ToolCategoryExtension on ToolCategory {
  String get displayName {
    switch (this) {
      case ToolCategory.network:
        return 'Network';
      case ToolCategory.calculators:
        return 'Calculators';
      case ToolCategory.generators:
        return 'Generators';
      case ToolCategory.references:
        return 'References';
      case ToolCategory.troubleshooting:
        return 'Troubleshooting';
    }
  }

  IconData get icon {
    switch (this) {
      case ToolCategory.network:
        return Icons.hub_outlined;
      case ToolCategory.calculators:
        return Icons.calculate_outlined;
      case ToolCategory.generators:
        return Icons.auto_awesome_outlined;
      case ToolCategory.references:
        return Icons.menu_book_outlined;
      case ToolCategory.troubleshooting:
        return Icons.build_circle_outlined;
    }
  }
}

class ToolItem {
  final String id;
  final String title;
  final String description;
  final ToolCategory category;
  final String route;
  final IconData icon;
  final List<String> tags;
  final bool isQuickTool;

  const ToolItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.route,
    required this.icon,
    this.tags = const [],
    this.isQuickTool = false,
  });
}
