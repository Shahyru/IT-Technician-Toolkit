import 'package:flutter/material.dart';
import '../../../core/models/checklist_item.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/favorite_button.dart';

class ChecklistDetailScreen extends StatefulWidget {
  final ChecklistItem checklist;

  const ChecklistDetailScreen({super.key, required this.checklist});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final LocalStorageService _storage = LocalStorageService();
  final TextEditingController _noteController = TextEditingController();
  Set<String> _completedStepIds = {};
  bool _isNoteExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _loadState() {
    final saved = _storage.getChecklistState(widget.checklist.id);
    final note = _storage.getChecklistNote(widget.checklist.id);
    setState(() {
      _completedStepIds = saved;
      _noteController.text = note;
      _isNoteExpanded = note.isNotEmpty;
    });
  }

  Future<void> _toggleStep(String stepId) async {
    setState(() {
      if (_completedStepIds.contains(stepId)) {
        _completedStepIds.remove(stepId);
      } else {
        _completedStepIds.add(stepId);
      }
    });
    await _storage.saveChecklistState(widget.checklist.id, _completedStepIds);
  }

  Future<void> _resetChecklist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Checklist?'),
        content: const Text('This will uncheck all completed steps and clear notes for this diagnostic flow.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.resetChecklistState(widget.checklist.id);
      _loadState();
    }
  }

  Future<void> _saveNote() async {
    await _storage.saveChecklistNote(widget.checklist.id, _noteController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Troubleshooting notes saved locally'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.checklist.steps.length;
    final done = _completedStepIds.length;
    final progress = total > 0 ? (done / total) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.checklist.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset progress',
            onPressed: _resetChecklist,
          ),
          FavoriteButton(itemId: widget.checklist.id),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Header Card
            AppCard(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
              borderColor: theme.colorScheme.primary.withOpacity(0.25),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Diagnostic Progress: ${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text('$done of $total steps resolved', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation(
                        progress == 1.0 ? Colors.greenAccent : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.checklist.description,
                    style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Technician Notes Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Technician Field Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      IconButton(
                        icon: Icon(_isNoteExpanded ? Icons.expand_less : Icons.expand_more),
                        onPressed: () => setState(() => _isNoteExpanded = !_isNoteExpanded),
                      ),
                    ],
                  ),
                  if (_isNoteExpanded) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Record serial numbers, user comments, or hardware test findings...',
                      ),
                      onChanged: (_) => _saveNote(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Steps List
            const Text('Action Steps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            ...widget.checklist.steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isCompleted = _completedStepIds.contains(step.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => _toggleStep(step.id),
                  padding: const EdgeInsets.all(14),
                  borderColor: isCompleted ? Colors.greenAccent.withOpacity(0.4) : null,
                  backgroundColor: isCompleted ? Colors.greenAccent.withOpacity(0.04) : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isCompleted,
                        activeColor: Colors.greenAccent,
                        checkColor: Colors.black,
                        onChanged: (_) => _toggleStep(step.id),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${idx + 1}: ${step.title}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isCompleted ? Colors.grey : theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                                height: 1.35,
                              ),
                            ),
                            if (step.warning != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        step.warning!,
                                        style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
