import 'power_cell.dart';

/// Types of auxiliary generators available in the game
enum GeneratorType {
  bioFission('Bio Fission Generator'),
  materiaShift('Materia Shift Generator'),
  nullTension('Null Tension Generator');

  const GeneratorType(this.displayName);
  final String displayName;
}

/// Mark levels for generators
enum GeneratorMarkLevel {
  mk1(1, 'MK1'),
  mk2(2, 'MK2'),
  mk3(3, 'MK3');

  const GeneratorMarkLevel(this.level, this.displayName);
  final int level;
  final String displayName;
}

/// Represents an auxiliary generator with its power grid (8x2)
class Generator {
  final GeneratorType type;
  final GeneratorMarkLevel markLevel;
  final List<List<PowerState>> grid;

  const Generator({
    required this.type,
    required this.markLevel,
    required this.grid,
  });

  /// Gets the grid width (should be 8)
  int get gridWidth => grid[0].length;

  /// Gets the grid height (should be 2)
  int get gridHeight => grid.length;

  /// Gets the power state at a specific position
  PowerState getPowerState(int x, int y) {
    if (x < 0 || x >= gridWidth || y < 0 || y >= gridHeight) {
      return PowerState.none;
    }
    return grid[y][x];
  }

  /// Checks if a position is powered (green or blue)
  bool isPowered(int x, int y) {
    final state = getPowerState(x, y);
    return state == PowerState.powered || state == PowerState.protected;
  }

  /// Gets all powered cells in the grid
  List<PowerCell> getPoweredCells() {
    final cells = <PowerCell>[];
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final state = grid[y][x];
        if (state != PowerState.none) {
          cells.add(PowerCell(x: x, y: y, powerState: state));
        }
      }
    }
    return cells;
  }

  String get displayName => '${type.displayName} ${markLevel.displayName}';

  @override
  String toString() => displayName;
}
