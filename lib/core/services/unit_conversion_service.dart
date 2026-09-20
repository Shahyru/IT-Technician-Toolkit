enum ConversionCategory {
  data,
  network,
  length,
  weight,
  temperature,
}

extension ConversionCategoryExtension on ConversionCategory {
  String get displayName {
    switch (this) {
      case ConversionCategory.data:
        return 'Data Storage';
      case ConversionCategory.network:
        return 'Network Throughput';
      case ConversionCategory.length:
        return 'Length';
      case ConversionCategory.weight:
        return 'Weight';
      case ConversionCategory.temperature:
        return 'Temperature';
    }
  }
}

class UnitConversionService {
  // Base unit for Data is Bytes
  static final Map<String, double> dataUnits = {
    'bit': 0.125,
    'Byte': 1.0,
    'KB (decimal)': 1e3,
    'MB (decimal)': 1e6,
    'GB (decimal)': 1e9,
    'TB (decimal)': 1e12,
    'KiB (binary)': 1024.0,
    'MiB (binary)': 1048576.0,
    'GiB (binary)': 1073741824.0,
    'TiB (binary)': 1099511627776.0,
  };

  // Base unit for Network is bits per second (bps)
  static final Map<String, double> networkUnits = {
    'bps': 1.0,
    'Kbps': 1e3,
    'Mbps': 1e6,
    'Gbps': 1e9,
    'B/s': 8.0,
    'KB/s': 8e3,
    'MB/s': 8e6,
    'GB/s': 8e9,
  };

  // Base unit for Length is meters (m)
  static final Map<String, double> lengthUnits = {
    'mm': 0.001,
    'cm': 0.01,
    'm': 1.0,
    'km': 1000.0,
    'inch': 0.0254,
    'ft': 0.3048,
    'yard': 0.9144,
    'mile': 1609.344,
  };

  // Base unit for Weight is grams (g)
  static final Map<String, double> weightUnits = {
    'mg': 0.001,
    'g': 1.0,
    'kg': 1000.0,
    'oz': 28.349523125,
    'lb': 453.59237,
  };

  static List<String> getUnitsForCategory(ConversionCategory category) {
    switch (category) {
      case ConversionCategory.data:
        return dataUnits.keys.toList();
      case ConversionCategory.network:
        return networkUnits.keys.toList();
      case ConversionCategory.length:
        return lengthUnits.keys.toList();
      case ConversionCategory.weight:
        return weightUnits.keys.toList();
      case ConversionCategory.temperature:
        return ['Celsius', 'Fahrenheit', 'Kelvin'];
    }
  }

  /// Converts [value] from [fromUnit] to [toUnit] in specified [category]
  static double convert({
    required ConversionCategory category,
    required double value,
    required String fromUnit,
    required String toUnit,
  }) {
    if (fromUnit == toUnit) return value;

    if (category == ConversionCategory.temperature) {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    Map<String, double> map;
    switch (category) {
      case ConversionCategory.data:
        map = dataUnits;
        break;
      case ConversionCategory.network:
        map = networkUnits;
        break;
      case ConversionCategory.length:
        map = lengthUnits;
        break;
      case ConversionCategory.weight:
        map = weightUnits;
        break;
      default:
        return value;
    }

    final fromFactor = map[fromUnit];
    final toFactor = map[toUnit];

    if (fromFactor == null || toFactor == null || toFactor == 0) {
      throw ArgumentError('Invalid units: $fromUnit or $toUnit');
    }

    // Convert to base, then to target
    final baseValue = value * fromFactor;
    return baseValue / toFactor;
  }

  static double _convertTemperature(double value, String from, String to) {
    // Convert from source to Celsius
    double celsius;
    if (from == 'Celsius') {
      celsius = value;
    } else if (from == 'Fahrenheit') {
      celsius = (value - 32.0) * (5.0 / 9.0);
    } else if (from == 'Kelvin') {
      celsius = value - 273.15;
    } else {
      celsius = value;
    }

    // Convert Celsius to destination
    if (to == 'Celsius') {
      return celsius;
    } else if (to == 'Fahrenheit') {
      return (celsius * (9.0 / 5.0)) + 32.0;
    } else if (to == 'Kelvin') {
      return celsius + 273.15;
    }
    return celsius;
  }
}
