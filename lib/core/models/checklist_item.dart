class ChecklistStep {
  final String id;
  final String title;
  final String description;
  final String? warning;

  const ChecklistStep({
    required this.id,
    required this.title,
    required this.description,
    this.warning,
  });

  factory ChecklistStep.fromJson(Map<String, dynamic> json) {
    return ChecklistStep(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      warning: json['warning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'warning': warning,
    };
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<ChecklistStep> steps;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.steps,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => ChecklistStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }
}
