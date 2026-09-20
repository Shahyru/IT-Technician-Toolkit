import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../models/tool_item.dart';
import '../../features/network/data/port_repository.dart';
import '../../features/references/data/reference_repository.dart';
import '../../features/troubleshooting/data/troubleshooting_repository.dart';

enum SearchResultType {
  tool,
  command,
  port,
  checklist,
}

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final SearchResultType type;
  final String route;
  final dynamic payload;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.type,
    required this.route,
    this.payload,
  });
}

class SearchService {
  static const List<ToolItem> allTools = [
    // Network
    ToolItem(
      id: 'tool-ip-calc',
      title: 'IP Calculator',
      description: 'IPv4 subnet calculations, binary representation, and address classification.',
      category: ToolCategory.network,
      route: AppRoutes.ipCalculator,
      icon: Icons.computer_outlined,
      tags: ['ip', 'ipv4', 'subnet', 'mask', 'cidr', 'binary', 'network'],
      isQuickTool: true,
    ),
    ToolItem(
      id: 'tool-subnet-calc',
      title: 'Subnet Calculator',
      description: 'Plan network divisions, host capacities, and subnet allocations.',
      category: ToolCategory.network,
      route: AppRoutes.subnetCalculator,
      icon: Icons.schema_outlined,
      tags: ['subnet', 'vlsm', 'cidr', 'network', 'hosts'],
      isQuickTool: true,
    ),
    ToolItem(
      id: 'tool-ping',
      title: 'Ping Reachability',
      description: 'Test IP/hostname connectivity, packet loss, and latency metrics.',
      category: ToolCategory.network,
      route: AppRoutes.ping,
      icon: Icons.network_ping_outlined,
      tags: ['ping', 'icmp', 'latency', 'reachability', 'dns', 'host'],
      isQuickTool: true,
    ),
    ToolItem(
      id: 'tool-port-ref',
      title: 'Port Reference',
      description: 'Offline database of standard and well-known TCP/UDP network ports.',
      category: ToolCategory.network,
      route: AppRoutes.ports,
      icon: Icons.lan_outlined,
      tags: ['port', 'ports', 'tcp', 'udp', 'services', 'protocol', 'networking'],
      isQuickTool: true,
    ),
    ToolItem(
      id: 'tool-mac-tools',
      title: 'MAC Address Tools',
      description: 'MAC address validation, format conversion, generation, and OUI lookup.',
      category: ToolCategory.network,
      route: AppRoutes.macTools,
      icon: Icons.fingerprint_outlined,
      tags: ['mac', 'ethernet', 'oui', 'vendor', 'hardware', 'address'],
    ),

    // Calculators
    ToolItem(
      id: 'tool-unit-converter',
      title: 'Unit Converter',
      description: 'Convert data units, network speeds, lengths, weights, and temperatures.',
      category: ToolCategory.calculators,
      route: AppRoutes.unitConverter,
      icon: Icons.sync_alt_outlined,
      tags: ['unit', 'converter', 'bytes', 'mbps', 'gib', 'temperature', 'conversion'],
    ),
    ToolItem(
      id: 'tool-storage-calc',
      title: 'Storage & RAID Calculator',
      description: 'Calculate raw vs usable capacity and fault tolerance for RAID levels.',
      category: ToolCategory.calculators,
      route: AppRoutes.storageCalculator,
      icon: Icons.storage_outlined,
      tags: ['storage', 'raid', 'disk', 'capacity', 'redundancy', 'parity'],
    ),
    ToolItem(
      id: 'tool-ram-calc',
      title: 'RAM Calculator',
      description: 'Dynamic memory module totaling and multi-unit conversions.',
      category: ToolCategory.calculators,
      route: AppRoutes.ramCalculator,
      icon: Icons.memory_outlined,
      tags: ['ram', 'memory', 'dimm', 'gb', 'modules'],
    ),
    ToolItem(
      id: 'tool-network-speed',
      title: 'Network Speed Calculator',
      description: 'Estimate file transfer duration based on bandwidth and efficiency.',
      category: ToolCategory.calculators,
      route: AppRoutes.networkSpeed,
      icon: Icons.speed_outlined,
      tags: ['transfer', 'speed', 'bandwidth', 'download', 'upload', 'time'],
    ),

    // Generators
    ToolItem(
      id: 'tool-password-gen',
      title: 'Password Generator',
      description: 'Cryptographically secure passwords with entropy and strength indicators.',
      category: ToolCategory.generators,
      route: AppRoutes.passwordGenerator,
      icon: Icons.password_outlined,
      tags: ['password', 'generator', 'security', 'crypto', 'entropy'],
      isQuickTool: true,
    ),
    ToolItem(
      id: 'tool-qr-gen',
      title: 'QR Code Generator',
      description: 'Generate Wi-Fi credentials, text, URLs, contacts, and emails offline.',
      category: ToolCategory.generators,
      route: AppRoutes.qrGenerator,
      icon: Icons.qr_code_2_outlined,
      tags: ['qr', 'qrcode', 'wifi', 'vcard', 'url', 'generator'],
      isQuickTool: true,
    ),

    // References
    ToolItem(
      id: 'tool-ref-windows',
      title: 'Windows Commands',
      description: 'Comprehensive Windows CMD command reference with syntax and examples.',
      category: ToolCategory.references,
      route: AppRoutes.windowsCommands,
      icon: Icons.window_outlined,
      tags: ['windows', 'cmd', 'command', 'cli', 'ipconfig', 'sfc', 'chkdsk'],
    ),
    ToolItem(
      id: 'tool-ref-linux',
      title: 'Linux Commands',
      description: 'Essential Linux CLI commands with destructive warnings and examples.',
      category: ToolCategory.references,
      route: AppRoutes.linuxCommands,
      icon: Icons.terminal_outlined,
      tags: ['linux', 'bash', 'terminal', 'cli', 'grep', 'systemctl', 'chmod'],
    ),
    ToolItem(
      id: 'tool-ref-powershell',
      title: 'PowerShell Reference',
      description: 'PowerShell cmdlets for Windows administration and diagnostics.',
      category: ToolCategory.references,
      route: AppRoutes.powershellCommands,
      icon: Icons.code_outlined,
      tags: ['powershell', 'ps', 'cmdlet', 'get-process', 'test-netconnection'],
    ),

    // Troubleshooting
    ToolItem(
      id: 'tool-troubleshooting',
      title: 'Troubleshooting Checklists',
      description: 'Step-by-step diagnostic workflows for hardware, networking, and OS issues.',
      category: ToolCategory.troubleshooting,
      route: AppRoutes.troubleshooting,
      icon: Icons.checklist_outlined,
      tags: ['troubleshooting', 'checklist', 'bsod', 'display', 'hardware', 'repair'],
    ),
  ];

  /// Performs global offline search across tools, commands, ports, and checklists
  static Future<List<SearchResult>> search(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final results = <SearchResult>[];

    // 1. Search Tools
    for (final tool in allTools) {
      if (tool.title.toLowerCase().contains(clean) ||
          tool.description.toLowerCase().contains(clean) ||
          tool.tags.any((t) => t.toLowerCase().contains(clean))) {
        results.add(SearchResult(
          id: tool.id,
          title: tool.title,
          subtitle: tool.description,
          category: tool.category.displayName,
          type: SearchResultType.tool,
          route: tool.route,
          payload: tool,
        ));
      }
    }

    // 2. Search Ports
    final ports = await PortRepository.getPorts();
    for (final port in ports) {
      final portStr = port.port.toString();
      if (portStr.contains(clean) ||
          port.service.toLowerCase().contains(clean) ||
          port.description.toLowerCase().contains(clean) ||
          port.protocol.toLowerCase().contains(clean) ||
          port.category.toLowerCase().contains(clean)) {
        results.add(SearchResult(
          id: port.id,
          title: 'Port ${port.port} (${port.protocol}) - ${port.service}',
          subtitle: port.description,
          category: 'Port Reference • ${port.category}',
          type: SearchResultType.port,
          route: AppRoutes.ports,
          payload: port,
        ));
      }
    }

    // 3. Search Commands (Windows, Linux, PowerShell)
    final commands = await ReferenceRepository.getAllCommands();
    for (final cmd in commands) {
      if (cmd.name.toLowerCase().contains(clean) ||
          cmd.description.toLowerCase().contains(clean) ||
          cmd.syntax.toLowerCase().contains(clean) ||
          cmd.tags.any((t) => t.toLowerCase().contains(clean)) ||
          cmd.examples.any((e) => e.toLowerCase().contains(clean))) {
        String route;
        if (cmd.platform == 'windows') {
          route = AppRoutes.windowsCommands;
        } else if (cmd.platform == 'linux') {
          route = AppRoutes.linuxCommands;
        } else {
          route = AppRoutes.powershellCommands;
        }

        results.add(SearchResult(
          id: cmd.id,
          title: cmd.name,
          subtitle: cmd.description,
          category: '${cmd.platform.toUpperCase()} Command • ${cmd.category}',
          type: SearchResultType.command,
          route: route,
          payload: cmd,
        ));
      }
    }

    // 4. Search Troubleshooting Checklists
    final checklists = await TroubleshootingRepository.getChecklists();
    for (final cl in checklists) {
      final matchesTitle = cl.title.toLowerCase().contains(clean);
      final matchesDesc = cl.description.toLowerCase().contains(clean);
      final matchesStep = cl.steps.any((s) =>
          s.title.toLowerCase().contains(clean) ||
          s.description.toLowerCase().contains(clean));

      if (matchesTitle || matchesDesc || matchesStep) {
        results.add(SearchResult(
          id: cl.id,
          title: cl.title,
          subtitle: cl.description,
          category: 'Troubleshooting • ${cl.category}',
          type: SearchResultType.checklist,
          route: AppRoutes.troubleshooting,
          payload: cl,
        ));
      }
    }

    return results;
  }
}
