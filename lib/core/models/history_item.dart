class HistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final String type; // 'tool', 'command', 'checklist', 'port'
  final DateTime timestamp;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.type,
    required this.timestamp,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      route: json['route'] as String? ?? '',
      type: json['type'] as String? ?? 'tool',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'route': route,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
