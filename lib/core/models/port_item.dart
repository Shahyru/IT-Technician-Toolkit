class PortItem {
  final int port;
  final String protocol;
  final String service;
  final String description;
  final String category;

  const PortItem({
    required this.port,
    required this.protocol,
    required this.service,
    required this.description,
    required this.category,
  });

  String get id => 'port-$port';

  factory PortItem.fromJson(Map<String, dynamic> json) {
    return PortItem(
      port: json['port'] as int? ?? 0,
      protocol: json['protocol'] as String? ?? 'TCP',
      service: json['service'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'port': port,
      'protocol': protocol,
      'service': service,
      'description': description,
      'category': category,
    };
  }
}
