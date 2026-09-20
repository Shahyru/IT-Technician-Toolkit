import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/models/tool_item.dart';
import '../../../core/models/history_item.dart';
import '../../../core/services/search_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/tool_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/favorite_button.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(String route) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LocalStorageService _storage = LocalStorageService();
  List<HistoryItem> _recentHistory = [];
  List<ToolItem> _favoriteTools = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final history = _storage.getHistory().where((h) => h.type == 'tool').take(4).toList();
    final favoriteIds = _storage.getFavorites();
    final favTools = SearchService.allTools.where((t) => favoriteIds.contains(t.id)).toList();

    setState(() {
      _recentHistory = history;
      _favoriteTools = favTools;
    });
  }

  void _openTool(ToolItem tool) {
    _storage.saveHistory(HistoryItem(
      id: tool.id,
      title: tool.title,
      subtitle: tool.description,
      route: tool.route,
      type: 'tool',
      timestamp: DateTime.now(),
    ));
    widget.onNavigate(tool.route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = _storage.getCompactCards();
    final quickTools = SearchService.allTools.where((t) => t.isQuickTool).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Technical Hero Header with Quick Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.18),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4)),
                        ),
                        child: Icon(Icons.terminal, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'IT Technician Toolkit',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Offline Diagnostics & Engineering Utilities',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Search Box trigger
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => widget.onNavigate(AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search tools, commands, ports, checklists... (Ctrl + K)',
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: const Text('Offline', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Tools Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SectionHeader(
                title: 'Quick Tools',
                subtitle: 'Most frequent networking & admin utilities',
                icon: Icons.bolt,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 148,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tool = quickTools[index];
                  return ToolCard(
                    tool: tool,
                    compact: false,
                    onTap: () => _openTool(tool),
                    trailing: FavoriteButton(
                      itemId: tool.id,
                      onChanged: _loadData,
                    ),
                  );
                },
                childCount: quickTools.length,
              ),
            ),
          ),

          // Categories Grid
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: SectionHeader(
                title: 'Categories',
                subtitle: 'Browse all tool suites and modules',
                icon: Icons.grid_view,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 80,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = ToolCategory.values[index];
                  String targetRoute;
                  switch (cat) {
                    case ToolCategory.network:
                      targetRoute = AppRoutes.network;
                      break;
                    case ToolCategory.calculators:
                      targetRoute = AppRoutes.calculators;
                      break;
                    case ToolCategory.generators:
                      targetRoute = AppRoutes.generators;
                      break;
                    case ToolCategory.references:
                      targetRoute = AppRoutes.references;
                      break;
                    case ToolCategory.troubleshooting:
                      targetRoute = AppRoutes.troubleshooting;
                      break;
                  }

                  return AppCard(
                    onTap: () => widget.onNavigate(targetRoute),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(cat.icon, color: theme.colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18, color: theme.iconTheme.color?.withOpacity(0.4)),
                      ],
                    ),
                  );
                },
                childCount: ToolCategory.values.length,
              ),
            ),
          ),

          // Favorites Section (if any)
          if (_favoriteTools.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: SectionHeader(
                  title: 'Favorite Tools',
                  subtitle: 'Quick access to your starred utilities',
                  icon: Icons.star,
                  action: TextButton(
                    onPressed: () => widget.onNavigate(AppRoutes.favorites),
                    child: const Text('View All'),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: isCompact ? 64 : 130,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tool = _favoriteTools[index];
                    return ToolCard(
                      tool: tool,
                      compact: isCompact,
                      onTap: () => _openTool(tool),
                      trailing: FavoriteButton(
                        itemId: tool.id,
                        onChanged: _loadData,
                      ),
                    );
                  },
                  childCount: _favoriteTools.length,
                ),
              ),
            ),
          ],

          // Recent Tools (if enabled in settings)
          if (_storage.getShowRecentTools() && _recentHistory.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: SectionHeader(
                  title: 'Recently Used',
                  subtitle: 'Recently opened tools on this device',
                  icon: Icons.history,
                  action: TextButton(
                    onPressed: () => widget.onNavigate(AppRoutes.history),
                    child: const Text('History'),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hist = _recentHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        onTap: () => widget.onNavigate(hist.route),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hist.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Text(
                                    hist.subtitle,
                                    style: TextStyle(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: theme.iconTheme.color?.withOpacity(0.3)),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _recentHistory.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }
}
