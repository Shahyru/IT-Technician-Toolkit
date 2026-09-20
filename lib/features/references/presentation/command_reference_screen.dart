import 'package:flutter/material.dart';
import '../../../core/models/command_item.dart';
import '../../../core/utils/clipboard_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/favorite_button.dart';
import '../data/reference_repository.dart';

class CommandReferenceScreen extends StatefulWidget {
  final String initialPlatform; // 'windows', 'linux', 'powershell'

  const CommandReferenceScreen({super.key, this.initialPlatform = 'windows'});

  @override
  State<CommandReferenceScreen> createState() => _CommandReferenceScreenState();
}

class _CommandReferenceScreenState extends State<CommandReferenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<CommandItem> _windowsCmds = [];
  List<CommandItem> _linuxCmds = [];
  List<CommandItem> _powershellCmds = [];
  bool _isLoading = true;

  final String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialPlatform == 'linux') initialIndex = 1;
    if (widget.initialPlatform == 'powershell') initialIndex = 2;

    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _loadAllCommands();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCommands() async {
    final win = await ReferenceRepository.getWindowsCommands();
    final lin = await ReferenceRepository.getLinuxCommands();
    final ps = await ReferenceRepository.getPowerShellCommands();

    if (mounted) {
      setState(() {
        _windowsCmds = win;
        _linuxCmds = lin;
        _powershellCmds = ps;
        _isLoading = false;
      });
    }
  }

  List<CommandItem> _filterList(List<CommandItem> items) {
    final q = _searchController.text.trim().toLowerCase();
    return items.where((cmd) {
      final matchCat = _selectedCategory == 'All' || cmd.category == _selectedCategory;
      if (!matchCat) return false;
      if (q.isEmpty) return true;

      return cmd.name.toLowerCase().contains(q) ||
          cmd.description.toLowerCase().contains(q) ||
          cmd.syntax.toLowerCase().contains(q) ||
          cmd.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  void _showCommandDetail(CommandItem cmd) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cmd.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ),
                      FavoriteButton(itemId: cmd.id),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${cmd.platform.toUpperCase()} • ${cmd.category}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(cmd.description, style: const TextStyle(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 18),

                  if (cmd.warning != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(cmd.warning!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Syntax
                  const Text('Syntax', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            cmd.syntax,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: 'Copy syntax',
                          onPressed: () => ClipboardUtils.copyWithFeedback(
                            ctx,
                            cmd.syntax,
                            message: 'Command syntax copied',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Examples
                  if (cmd.examples.isNotEmpty) ...[
                    const Text('Examples', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...cmd.examples.map((ex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  ex,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                tooltip: 'Copy example',
                                onPressed: () => ClipboardUtils.copyWithFeedback(
                                  ctx,
                                  ex,
                                  message: 'Command copied',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command References'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.window), text: 'Windows CMD'),
            Tab(icon: Icon(Icons.terminal), text: 'Linux CLI'),
            Tab(icon: Icon(Icons.code), text: 'PowerShell'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search commands by name, syntax, or keywords...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCommandsList(_filterList(_windowsCmds)),
                      _buildCommandsList(_filterList(_linuxCmds)),
                      _buildCommandsList(_filterList(_powershellCmds)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandsList(List<CommandItem> items) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No Commands Found',
        message: 'No commands match your query. Try searching with different terms.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cmd = items[index];
        return AppCard(
          padding: const EdgeInsets.all(14),
          onTap: () => _showCommandDetail(cmd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cmd.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'monospace'),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cmd.category,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FavoriteButton(itemId: cmd.id),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                cmd.description,
                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Text(
                        cmd.syntax,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Copy syntax',
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                    onPressed: () => ClipboardUtils.copyWithFeedback(
                      context,
                      cmd.syntax,
                      message: 'Command copied',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
