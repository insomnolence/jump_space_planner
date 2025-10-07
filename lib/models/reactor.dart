import 'power_cell.dart';

/// Types of reactors available in the game
enum ReactorType {
  split('Split Reactor'),
  solidState('Solid State Reactor'),
  materiaScatter('Materia Scatter Reactor'),
  nullWave('Null Wave Reactor');

  const ReactorType(this.displayName);
  final String displayName;
}

/// Mark levels for reactors
enum MarkLevel {
  mk1(1, 'MK1'),
  mk2(2, 'MK2'),
  mk3(3, 'MK3');

  const MarkLevel(this.level, this.displayName);
  final int level;
  final String displayName;
}

/// Represents a reactor with its power grid
class Reactor {
  final ReactorType type;
  final MarkLevel markLevel;
  final List<List<PowerState>> grid;

  const Reactor({
    required this.type,
    required this.markLevel,
    required this.grid,
  });

  /// Gets the grid size (assuming square grid)
  int get gridSize => grid.length;

  /// Gets the power state at a specific position
  PowerState getPowerState(int x, int y) {
    if (x < 0 || x >= grid.length || y < 0 || y >= grid[x].length) {
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
    for (int y = 0; y < grid.length; y++) {
      for (int x = 0; x < grid[y].length; x++) {
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
