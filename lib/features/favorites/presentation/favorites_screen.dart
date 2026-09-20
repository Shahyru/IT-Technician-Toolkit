import 'package:flutter/material.dart';
import '../../../core/models/tool_item.dart';
import '../../../core/models/command_item.dart';
import '../../../core/models/port_item.dart';
import '../../../core/models/checklist_item.dart';
import '../../../core/services/search_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../network/data/port_repository.dart';
import '../../references/data/reference_repository.dart';
import '../../troubleshooting/data/troubleshooting_repository.dart';
import '../../troubleshooting/presentation/checklist_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final void Function(String route) onNavigate;

  const FavoritesScreen({super.key, required this.onNavigate});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LocalStorageService _storage = LocalStorageService();
  bool _isLoading = true;

  List<ToolItem> _favTools = [];
  List<CommandItem> _favCommands = [];
  List<PortItem> _favPorts = [];
  List<ChecklistItem> _favChecklists = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favIds = _storage.getFavorites().toSet();

    // Tools
    final tools = SearchService.allTools.where((t) => favIds.contains(t.id)).toList();

    // Ports
    final allPorts = await PortRepository.getPorts();
    final ports = allPorts.where((p) => favIds.contains(p.id)).toList();

    // Commands
    final allCmds = await ReferenceRepository.getAllCommands();
    final cmds = allCmds.where((c) => favIds.contains(c.id)).toList();

    // Checklists
    final allCl = await TroubleshootingRepository.getChecklists();
    final cls = allCl.where((c) => favIds.contains(c.id)).toList();

    if (mounted) {
      setState(() {
        _favTools = tools;
        _favPorts = ports;
        _favCommands = cmds;
        _favChecklists = cls;
        _isLoading = false;
      });
    }
  }

  bool get _isEmpty =>
      _favTools.isEmpty && _favPorts.isEmpty && _favCommands.isEmpty && _favChecklists.isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Favorites'),
        actions: [
          if (!_isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all favorites',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Favorites?'),
                    content: const Text('This will remove all starred tools, commands, ports, and checklists.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _storage.clearFavorites();
                  _loadFavorites();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEmpty
              ? const EmptyState(
                  icon: Icons.star_border,
                  title: 'No Favorites Saved',
                  message: 'Tap the star icon on any tool, command, port, or checklist to pin it here for instant access.',
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_favTools.isNotEmpty) ...[
                      _sectionTitle('Favorite Tools'),
                      ..._favTools.map((tool) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              onTap: () => widget.onNavigate(tool.route),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(tool.icon, color: theme.colorScheme.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(tool.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                  FavoriteButton(itemId: tool.id, onChanged: _loadFavorites),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (_favCommands.isNotEmpty) ...[
                      _sectionTitle('Favorite Commands'),
                      ..._favCommands.map((cmd) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.terminal, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cmd.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                        Text(cmd.syntax, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1),
                                      ],
                                    ),
                                  ),
                                  FavoriteButton(itemId: cmd.id, onChanged: _loadFavorites),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (_favPorts.isNotEmpty) ...[
                      _sectionTitle('Favorite Ports'),
                      ..._favPorts.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.lan_outlined, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Port ${p.port} (${p.protocol}) - ${p.service}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  FavoriteButton(itemId: p.id, onChanged: _loadFavorites),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],

                    if (_favChecklists.isNotEmpty) ...[
                      _sectionTitle('Favorite Checklists'),
                      ..._favChecklists.map((cl) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ChecklistDetailScreen(checklist: cl)),
                                );
                                _loadFavorites();
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.checklist_rtl, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(cl.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  FavoriteButton(itemId: cl.id, onChanged: _loadFavorites),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
