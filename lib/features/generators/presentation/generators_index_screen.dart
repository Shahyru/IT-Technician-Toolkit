import 'package:flutter/material.dart';
import '../../../core/models/tool_item.dart';
import '../../../core/services/search_service.dart';
import '../../../core/widgets/tool_card.dart';
import '../../../core/widgets/favorite_button.dart';

class GeneratorsIndexScreen extends StatelessWidget {
  final void Function(String route) onNavigate;

  const GeneratorsIndexScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final tools = SearchService.allTools.where((t) => t.category == ToolCategory.generators).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generators'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          mainAxisExtent: 140,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return ToolCard(
            tool: tool,
            onTap: () => onNavigate(tool.route),
            trailing: FavoriteButton(itemId: tool.id),
          );
        },
      ),
    );
  }
}
