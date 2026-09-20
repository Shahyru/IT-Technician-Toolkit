import 'ip_calculator_service.dart';
import '../utils/validators.dart';

class SubnetEntry {
  final int index;
  final String subnetName;
  final int cidr;
  final String subnetMask;
  final String networkAddress;
  final String broadcastAddress;
  final String firstHost;
  final String lastHost;
  final int usableHosts;
  final int totalAddresses;

  const SubnetEntry({
    required this.index,
    required this.subnetName,
    required this.cidr,
    required this.subnetMask,
    required this.networkAddress,
    required this.broadcastAddress,
    required this.firstHost,
    required this.lastHost,
    required this.usableHosts,
    required this.totalAddresses,
  });
}

class SubnetCalculatorService {
  /// Splits a base network into subnets based on target new CIDR prefix
  static List<SubnetEntry> calculateSubnets({
    required String baseNetwork,
    required int baseCidr,
    required int targetCidr,
    int maxSubnets = 256,
  }) {
    final ipErr = Validators.validateIPv4(baseNetwork);
    if (ipErr != null) throw FormatException(ipErr);

    if (baseCidr < 0 || baseCidr > 32) {
      throw const FormatException('Base CIDR must be between /0 and /32');
    }
    if (targetCidr < baseCidr || targetCidr > 32) {
      throw const FormatException('Target CIDR must be between base CIDR and /32');
    }

    final baseIpInt = IpCalculatorService.ipv4ToInt(baseNetwork);
    final baseMaskInt = IpCalculatorService.cidrToMaskInt(baseCidr);
    final alignedNetworkInt = (baseIpInt & baseMaskInt) & 0xFFFFFFFF;

    final int bitsBorrowed = targetCidr - baseCidr;
    final int totalSubnets = 1 << bitsBorrowed;
    final int step = (targetCidr == 32) ? 1 : (1 << (32 - targetCidr));
    final targetMask = IpCalculatorService.cidrToSubnetMask(targetCidr);

    final countToGenerate = totalSubnets > maxSubnets ? maxSubnets : totalSubnets;
    final results = <SubnetEntry>[];

    for (int i = 0; i < countToGenerate; i++) {
      final currentNetInt = (alignedNetworkInt + (i * step)) & 0xFFFFFFFF;
      final currentBcastInt = (currentNetInt + step - 1) & 0xFFFFFFFF;

      int usable;
      String first;
      String last;

      if (targetCidr == 32) {
        usable = 1;
        first = IpCalculatorService.intToIpv4(currentNetInt);
        last = IpCalculatorService.intToIpv4(currentNetInt);
      } else if (targetCidr == 31) {
        usable = 2;
        first = IpCalculatorService.intToIpv4(currentNetInt);
        last = IpCalculatorService.intToIpv4(currentBcastInt);
      } else {
        usable = step - 2;
        first = IpCalculatorService.intToIpv4(currentNetInt + 1);
        last = IpCalculatorService.intToIpv4(currentBcastInt - 1);
      }

      results.add(SubnetEntry(
        index: i + 1,
        subnetName: 'Subnet #${i + 1}',
        cidr: targetCidr,
        subnetMask: targetMask,
        networkAddress: IpCalculatorService.intToIpv4(currentNetInt),
        broadcastAddress: IpCalculatorService.intToIpv4(currentBcastInt),
        firstHost: first,
        lastHost: last,
        usableHosts: usable,
        totalAddresses: step,
      ));
    }

    return results;
  }

  /// Calculates smallest CIDR prefix that can accommodate [requiredHosts] usable hosts
  static int cidrForHosts(int requiredHosts) {
    if (requiredHosts <= 0) return 32;
    if (requiredHosts == 1) return 32;
    if (requiredHosts == 2) return 31;
    // For standard networks: 2^(32 - cidr) - 2 >= requiredHosts
    for (int cidr = 30; cidr >= 0; cidr--) {
      final capacity = (1 << (32 - cidr)) - 2;
      if (capacity >= requiredHosts) {
        return cidr;
      }
    }
    return 0;
  }

  /// Calculates target CIDR to accommodate [requiredSubnets] from base CIDR
  static int cidrForSubnets(int baseCidr, int requiredSubnets) {
    if (requiredSubnets <= 1) return baseCidr;
    int bitsNeeded = 0;
    while ((1 << bitsNeeded) < requiredSubnets) {
      bitsNeeded++;
    }
    final target = baseCidr + bitsNeeded;
    return target > 32 ? 32 : target;
  }
}
