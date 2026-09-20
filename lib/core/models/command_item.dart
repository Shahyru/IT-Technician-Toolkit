class CommandItem {
  final String name;
  final String category;
  final String description;
  final String syntax;
  final List<String> examples;
  final String? warning;
  final List<String> tags;
  final String platform; // 'windows', 'linux', 'powershell'

  const CommandItem({
    required this.name,
    required this.category,
    required this.description,
    required this.syntax,
    required this.examples,
    this.warning,
    required this.tags,
    required this.platform,
  });

  String get id => '$platform-$name';

  factory CommandItem.fromJson(Map<String, dynamic> json, {required String platform}) {
    return CommandItem(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      syntax: json['syntax'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      warning: json['warning'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      platform: platform,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'syntax': syntax,
      'examples': examples,
      'warning': warning,
      'tags': tags,
      'platform': platform,
    };
  }
}
