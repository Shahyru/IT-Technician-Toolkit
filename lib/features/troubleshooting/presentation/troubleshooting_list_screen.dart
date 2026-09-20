import 'package:flutter/material.dart';
import '../../../core/models/checklist_item.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/favorite_button.dart';
import '../data/troubleshooting_repository.dart';
import 'checklist_detail_screen.dart';

class TroubleshootingListScreen extends StatefulWidget {
  const TroubleshootingListScreen({super.key});

  @override
  State<TroubleshootingListScreen> createState() => _TroubleshootingListScreenState();
}

class _TroubleshootingListScreenState extends State<TroubleshootingListScreen> {
  final LocalStorageService _storage = LocalStorageService();
  final TextEditingController _searchController = TextEditingController();

  List<ChecklistItem> _checklists = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChecklists() async {
    final list = await TroubleshootingRepository.getChecklists();
    if (mounted) {
      setState(() {
        _checklists = list;
        _isLoading = false;
      });
    }
  }

  List<String> get _categories {
    final cats = _checklists.map((c) => c.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<ChecklistItem> get _filteredChecklists {
    final q = _searchController.text.trim().toLowerCase();
    return _checklists.where((c) {
      final matchCat = _selectedCategory == 'All' || c.category == _selectedCategory;
      if (!matchCat) return false;
      if (q.isEmpty) return true;

      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.steps.any((s) => s.title.toLowerCase().contains(q) || s.description.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayed = _filteredChecklists;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshooting Checklists'),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search diagnostic workflows (e.g. BSOD, display, wifi)...',
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

          // Categories Filter
          if (_categories.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (val) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const Divider(height: 1),

          // Checklists List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayed.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No Checklists Found',
                        message: 'No troubleshooting workflows match your query.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = displayed[index];
                          final completed = _storage.getChecklistState(item.id);
                          final total = item.steps.length;
                          final progress = total > 0 ? (completed.length / total) : 0.0;

                          return AppCard(
                            padding: const EdgeInsets.all(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChecklistDetailScreen(checklist: item),
                                ),
                              );
                              setState(() {}); // Refresh progress on return
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FavoriteButton(itemId: item.id),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.8)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor: theme.colorScheme.surface,
                                          valueColor: AlwaysStoppedAnimation(
                                            progress == 1.0 ? Colors.greenAccent : theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${completed.length}/$total steps',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
