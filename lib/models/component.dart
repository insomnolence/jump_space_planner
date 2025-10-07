/// Types of ship components
enum ComponentType {
  sensor,
  engine,
  pilotCannon,
  multiTurret,
  specialWeapon,
  auxiliaryGenerator,
}

/// Represents a component's shape using relative coordinates
class ComponentShape {
  final List<GridPosition> positions;

  const ComponentShape(this.positions);

  /// Get the bounding box of the shape
  (int width, int height) get bounds {
    if (positions.isEmpty) return (0, 0);

    int minX = positions.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    int maxX = positions.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    int minY = positions.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    int maxY = positions.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    return (maxX - minX + 1, maxY - minY + 1);
  }

  /// Rotate the shape 90 degrees clockwise
  ComponentShape rotate90() {
    final rotated = positions.map((pos) {
      return GridPosition(x: -pos.y, y: pos.x);
    }).toList();
    return ComponentShape(rotated);
  }

  /// Normalize the shape so the top-left position is at (0,0)
  ComponentShape normalize() {
    if (positions.isEmpty) return this;

    int minX = positions.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    int minY = positions.map((p) => p.y).reduce((a, b) => a < b ? a : b);

    final normalized = positions.map((pos) {
      return GridPosition(x: pos.x - minX, y: pos.y - minY);
    }).toList();

    return ComponentShape(normalized);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ComponentShape) return false;
    if (positions.length != other.positions.length) return false;

    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != other.positions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(positions);
}

/// Represents a position in the grid
class GridPosition {
  final int x;
  final int y;

  const GridPosition({required this.x, required this.y});

  GridPosition operator +(GridPosition other) {
    return GridPosition(x: x + other.x, y: y + other.y);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridPosition && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// Represents a ship component that can be placed on the grid
class Component {
  final String id;
  final String name;
  final ComponentType type;
  final ComponentShape shape;
  final int markLevel;

  const Component({
    required this.id,
    required this.name,
    required this.type,
    required this.shape,
    this.markLevel = 1,
  });

  /// Create a rotated version of this component
  Component rotate() {
    return Component(
      id: id,
      name: name,
      type: type,
      shape: shape.rotate90().normalize(),
      markLevel: markLevel,
    );
  }

  String get displayName {
    // If name already contains MK designation (e.g., "Engine (MK1-3)"), use it as-is
    if (name.contains('(MK')) {
      return name;
    }
    // Otherwise append the markLevel
    return '$name (MK$markLevel)';
  }

  /// Short code for compact identification on the grid (e.g., "DPE")
  String get shortLabel {
    // Remove MK suffixes and parentheses content for base acronym
    final baseName = name.split('(').first.trim();
    final words = baseName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    final buffer = StringBuffer();
    for (final word in words) {
      final sanitized = word.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      if (sanitized.isEmpty) {
        continue;
      }
      buffer.write(sanitized[0].toUpperCase());
      if (buffer.length >= 3) {
        break;
      }
    }

    var code = buffer.isEmpty
        ? (baseName.isNotEmpty
            ? baseName[0].toUpperCase()
            : (id.isNotEmpty ? id[0].toUpperCase() : '?'))
        : buffer.toString();

    // Only append mark level for components that have different shapes per mark
    // (Disruptor Laser and Mining Lasers are the only ones with shape changes)
    final hasMarkVariants = name.contains('Disruptor Laser') ||
                           name.contains('Mining Lasers');

    if (hasMarkVariants && markLevel == 3) {
      code = '$code$markLevel';
    }

    if (code.length > 4) {
      code = code.substring(0, 4);
    }
    return code;
  }

  @override
  String toString() => displayName;
}
