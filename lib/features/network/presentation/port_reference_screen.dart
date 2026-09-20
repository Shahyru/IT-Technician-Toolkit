import 'package:flutter/material.dart';
import '../../../core/models/port_item.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/favorite_button.dart';
import '../data/port_repository.dart';

class PortReferenceScreen extends StatefulWidget {
  const PortReferenceScreen({super.key});

  @override
  State<PortReferenceScreen> createState() => _PortReferenceScreenState();
}

class _PortReferenceScreenState extends State<PortReferenceScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PortItem> _allPorts = [];
  List<PortItem> _filteredPorts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Web',
    'Email',
    'DNS',
    'File Sharing',
    'Remote Access',
    'Database',
    'Directory Services',
    'Monitoring',
    'Networking',
    'Security',
  ];

  @override
  void initState() {
    super.initState();
    _loadPorts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPorts() async {
    final list = await PortRepository.getPorts();
    if (mounted) {
      setState(() {
        _allPorts = list;
        _filteredPorts = list;
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredPorts = _allPorts.where((p) {
        final matchesCat = _selectedCategory == 'All' || p.category == _selectedCategory;
        if (!matchesCat) return false;
        if (query.isEmpty) return true;

        return p.port.toString().contains(query) ||
            p.service.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.protocol.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  Color _badgeColorForCategory(String category) {
    switch (category) {
      case 'Web':
        return Colors.blue;
      case 'Email':
        return Colors.purple;
      case 'Remote Access':
        return Colors.orange;
      case 'Database':
        return Colors.teal;
      case 'Security':
        return Colors.redAccent;
      case 'Monitoring':
        return Colors.green;
      case 'Directory Services':
        return Colors.indigo;
      default:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Port Reference'),
        actions: const [
          FavoriteButton(itemId: 'tool-port-ref'),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              decoration: InputDecoration(
                hintText: 'Search by port (e.g. 443, 22), service, or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Categories filter horizontal bar
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
                      _applyFilter();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPorts.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No Ports Found',
                        message: 'No matching network ports found. Try another port number or category filter.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPorts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final port = _filteredPorts[index];
                          final badgeColor = _badgeColorForCategory(port.category);

                          return AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Port Number Box
                                Container(
                                  width: 68,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: theme.dividerColor),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        port.port.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      Text(
                                        port.protocol,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Port Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              port.service,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badgeColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: badgeColor.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              port.category,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: badgeColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        port.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FavoriteButton(itemId: port.id),
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
