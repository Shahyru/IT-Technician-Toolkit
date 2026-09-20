import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/search_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  final void Function(String route) onNavigate;

  const SearchScreen({super.key, required this.onNavigate});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _activeCategoryFilter = 'All';

  final List<String> _filters = ['All', 'Tools', 'Ports', 'Commands', 'Troubleshooting'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      final list = await SearchService.search(query);
      if (mounted) {
        setState(() {
          _results = list;
          _isLoading = false;
        });
      }
    });
  }

  List<SearchResult> get _filteredResults {
    if (_activeCategoryFilter == 'All') return _results;
    if (_activeCategoryFilter == 'Tools') {
      return _results.where((r) => r.type == SearchResultType.tool).toList();
    }
    if (_activeCategoryFilter == 'Ports') {
      return _results.where((r) => r.type == SearchResultType.port).toList();
    }
    if (_activeCategoryFilter == 'Commands') {
      return _results.where((r) => r.type == SearchResultType.command).toList();
    }
    if (_activeCategoryFilter == 'Troubleshooting') {
      return _results.where((r) => r.type == SearchResultType.checklist).toList();
    }
    return _results;
  }

  IconData _iconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.tool:
        return Icons.construction;
      case SearchResultType.port:
        return Icons.lan_outlined;
      case SearchResultType.command:
        return Icons.terminal;
      case SearchResultType.checklist:
        return Icons.checklist_rtl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayed = _filteredResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Search tools, ports (e.g. 443), commands (e.g. ipconfig)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _onQueryChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _filters.map((filter) {
                final selected = _activeCategoryFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        _activeCategoryFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.text.trim().isEmpty
                    ? const EmptyState(
                        icon: Icons.search,
                        title: 'Type to Search',
                        message:
                            'Search across tools, ports, command references, and troubleshooting workflows entirely offline.',
                      )
                    : displayed.isEmpty
                        ? EmptyState(
                            icon: Icons.search_off,
                            title: 'No Results Found',
                            message: 'No matches found for "${_controller.text}". Check your spelling or try broader terms.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayed.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = displayed[index];
                              return AppCard(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                onTap: () => widget.onNavigate(item.route),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _iconForType(item.type),
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.surface,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: theme.dividerColor),
                                                ),
                                                child: Text(
                                                  item.category,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.subtitle,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_ios, size: 14, color: theme.iconTheme.color?.withOpacity(0.4)),
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
