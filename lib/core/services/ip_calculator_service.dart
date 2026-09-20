import '../utils/validators.dart';

class IpCalculationResult {
  final String ipAddress;
  final String subnetMask;
  final int cidr;
  final String networkAddress;
  final String broadcastAddress;
  final String firstUsableHost;
  final String lastUsableHost;
  final int totalAddresses;
  final int usableHosts;
  final String binaryIp;
  final String binarySubnetMask;
  final String ipClass;
  final String scope; // Private, Public, Loopback, APIPA, Multicast, Reserved
  final String wildcardMask;

  const IpCalculationResult({
    required this.ipAddress,
    required this.subnetMask,
    required this.cidr,
    required this.networkAddress,
    required this.broadcastAddress,
    required this.firstUsableHost,
    required this.lastUsableHost,
    required this.totalAddresses,
    required this.usableHosts,
    required this.binaryIp,
    required this.binarySubnetMask,
    required this.ipClass,
    required this.scope,
    required this.wildcardMask,
  });
}

class IpCalculatorService {
  /// Converts 32-bit unsigned int to dotted IPv4 string
  static String intToIpv4(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ].join('.');
  }

  /// Converts dotted IPv4 string to 32-bit unsigned int
  static int ipv4ToInt(String ip) {
    final octets = ip.split('.').map(int.parse).toList();
    return ((octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3]) & 0xFFFFFFFF;
  }

  /// Converts CIDR prefix (0-32) to 32-bit integer mask
  static int cidrToMaskInt(int cidr) {
    if (cidr == 0) return 0;
    return (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
  }

  /// Converts subnet mask integer to dotted string
  static String cidrToSubnetMask(int cidr) {
    return intToIpv4(cidrToMaskInt(cidr));
  }

  /// Converts subnet mask string to CIDR prefix
  static int subnetMaskToCidr(String mask) {
    final maskInt = ipv4ToInt(mask);
    int count = 0;
    for (int i = 31; i >= 0; i--) {
      if ((maskInt & (1 << i)) != 0) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Converts 32-bit integer to 4-octet binary string with spaces
  static String intToBinaryString(int value) {
    return [
      ((value >> 24) & 0xFF).toRadixString(2).padLeft(8, '0'),
      ((value >> 16) & 0xFF).toRadixString(2).padLeft(8, '0'),
      ((value >> 8) & 0xFF).toRadixString(2).padLeft(8, '0'),
      (value & 0xFF).toRadixString(2).padLeft(8, '0'),
    ].join(' . ');
  }

  /// Classifies IPv4 class (A, B, C, D, E)
  static String classifyClass(int firstOctet) {
    if (firstOctet >= 1 && firstOctet <= 126) return 'Class A';
    if (firstOctet == 127) return 'Class A (Loopback)';
    if (firstOctet >= 128 && firstOctet <= 191) return 'Class B';
    if (firstOctet >= 192 && firstOctet <= 223) return 'Class C';
    if (firstOctet >= 224 && firstOctet <= 239) return 'Class D (Multicast)';
    if (firstOctet >= 240 && firstOctet <= 255) return 'Class E (Experimental)';
    return 'Unknown';
  }

  /// Determines address scope (RFC 1918 Private, Public, Loopback, APIPA, etc.)
  static String classifyScope(int ipInt) {
    final o1 = (ipInt >> 24) & 0xFF;
    final o2 = (ipInt >> 16) & 0xFF;

    // Loopback 127.0.0.0/8
    if (o1 == 127) return 'Loopback';

    // APIPA 169.254.0.0/16
    if (o1 == 169 && o2 == 254) return 'Link-Local / APIPA';

    // RFC 1918 Private addresses:
    // 10.0.0.0 - 10.255.255.255 (10.0.0.0/8)
    if (o1 == 10) return 'Private (RFC 1918)';

    // 172.16.0.0 - 172.31.255.255 (172.16.0.0/12)
    if (o1 == 172 && o2 >= 16 && o2 <= 31) return 'Private (RFC 1918)';

    // 192.168.0.0 - 192.168.255.255 (192.168.0.0/16)
    if (o1 == 192 && o2 == 168) return 'Private (RFC 1918)';

    // Carrier-grade NAT 100.64.0.0/10 (100.64.0.0 to 100.127.255.255)
    if (o1 == 100 && o2 >= 64 && o2 <= 127) return 'Carrier-Grade NAT (RFC 6598)';

    // Multicast 224.0.0.0 - 239.255.255.255
    if (o1 >= 224 && o1 <= 239) return 'Multicast';

    // Broadcast
    if (ipInt == 0xFFFFFFFF) return 'Limited Broadcast';

    // 0.0.0.0/8 Current network
    if (o1 == 0) return 'Current Network ("This" Host)';

    return 'Public';
  }

  /// Calculates full IPv4 subnet details
  static IpCalculationResult calculate(String ipInput, {String? maskInput, int? cidrInput}) {
    String cleanIp = ipInput.trim();
    int? cidr = cidrInput;

    // Support CIDR embedded in IP string e.g. "192.168.1.100/24"
    if (cleanIp.contains('/')) {
      final parts = cleanIp.split('/');
      cleanIp = parts[0];
      final parsedCidr = int.tryParse(parts[1]);
      if (parsedCidr != null) {
        cidr = parsedCidr;
      }
    }

    // Validate IP
    final ipErr = Validators.validateIPv4(cleanIp);
    if (ipErr != null) {
      throw FormatException(ipErr);
    }

    // Resolve CIDR if mask string provided
    if (cidr == null && maskInput != null && maskInput.trim().isNotEmpty) {
      final maskErr = Validators.validateSubnetMask(maskInput);
      if (maskErr != null) {
        throw FormatException(maskErr);
      }
      cidr = subnetMaskToCidr(maskInput.trim());
    }

    // Default to /24 if still null
    cidr ??= 24;

    if (cidr < 0 || cidr > 32) {
      throw const FormatException('CIDR prefix must be between /0 and /32');
    }

    final ipInt = ipv4ToInt(cleanIp);
    final maskInt = cidrToMaskInt(cidr);
    final wildcardInt = (~maskInt) & 0xFFFFFFFF;
    final networkInt = (ipInt & maskInt) & 0xFFFFFFFF;
    final broadcastInt = (networkInt | wildcardInt) & 0xFFFFFFFF;

    final int totalAddresses = (cidr == 32) ? 1 : (1 << (32 - cidr));

    int usableHosts;
    String firstHost;
    String lastHost;

    if (cidr == 31) {
      // RFC 3021 point-to-point links (both usable)
      usableHosts = 2;
      firstHost = intToIpv4(networkInt);
      lastHost = intToIpv4(broadcastInt);
    } else if (cidr == 32) {
      usableHosts = 1;
      firstHost = intToIpv4(networkInt);
      lastHost = intToIpv4(networkInt);
    } else {
      usableHosts = totalAddresses - 2;
      firstHost = intToIpv4(networkInt + 1);
      lastHost = intToIpv4(broadcastInt - 1);
    }

    final firstOctet = (ipInt >> 24) & 0xFF;

    return IpCalculationResult(
      ipAddress: cleanIp,
      subnetMask: intToIpv4(maskInt),
      cidr: cidr,
      networkAddress: intToIpv4(networkInt),
      broadcastAddress: intToIpv4(broadcastInt),
      firstUsableHost: firstHost,
      lastUsableHost: lastHost,
      totalAddresses: totalAddresses,
      usableHosts: usableHosts,
      binaryIp: intToBinaryString(ipInt),
      binarySubnetMask: intToBinaryString(maskInt),
      ipClass: classifyClass(firstOctet),
      scope: classifyScope(ipInt),
      wildcardMask: intToIpv4(wildcardInt),
    );
  }
}
