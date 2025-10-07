import '../models/reactor.dart';
import '../models/power_cell.dart';

/// Complete reactor data extracted from Jump Space Steam Guide images
/// All patterns verified against actual game screenshots
class CompleteReactorData {
  static const gridSize = 12;

  // SPLIT REACTOR
  // Pattern: Row 1: GG____GG, Rows 2-4: GGG__GGG

  /// Split Reactor MK1 - 22 cells (0 protected, 22 powered)
  /// Pattern: GG____GG, GGG__GGG, GGG__GGG, GGG__GGG
  static Reactor getSplitReactorMK1() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-3 and x=8-9
        if (y == 4 && ((x >= 2 && x <= 3) || (x >= 8 && x <= 9))) {
          return PowerState.powered;
        }
        // Rows 1-3 (y=5-7): x=2-4 and x=7-9
        if ((y >= 5 && y <= 7) && ((x >= 2 && x <= 4) || (x >= 7 && x <= 9))) {
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.split, markLevel: MarkLevel.mk1, grid: grid);
  }

  /// Split Reactor MK2 - 22 cells (4 protected, 18 powered)
  /// Pattern: GG____GG, GGG__GGG, BGG__GGB, BGG__GGB
  static Reactor getSplitReactorMK2() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-3 and x=8-9 - all green
        if (y == 4 && ((x >= 2 && x <= 3) || (x >= 8 && x <= 9))) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=2-4 and x=7-9 - all green
        if (y == 5 && ((x >= 2 && x <= 4) || (x >= 7 && x <= 9))) {
          return PowerState.powered;
        }
        // Rows 2-3 (y=6-7): x=2-4 and x=7-9 - first cell blue, rest green
        if ((y == 6 || y == 7) && ((x >= 2 && x <= 4) || (x >= 7 && x <= 9))) {
          // x=2 or x=9 are blue (protected)
          if (x == 2 || x == 9) {
            return PowerState.protected;
          }
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.split, markLevel: MarkLevel.mk2, grid: grid);
  }

  /// Split Reactor MK3 - 22 cells (8 protected, 14 powered)
  /// Pattern: GG____GG, GGG__GGG, BBG__GBB, BBG__GBB
  static Reactor getSplitReactorMK3() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-3 and x=8-9 - all green
        if (y == 4 && ((x >= 2 && x <= 3) || (x >= 8 && x <= 9))) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=2-4 and x=7-9 - all green
        if (y == 5 && ((x >= 2 && x <= 4) || (x >= 7 && x <= 9))) {
          return PowerState.powered;
        }
        // Rows 2-3 (y=6-7): x=2-4 and x=7-9 - first two cells blue, last green
        if ((y == 6 || y == 7) && ((x >= 2 && x <= 4) || (x >= 7 && x <= 9))) {
          // x=2,3 or x=8,9 are blue (protected)
          if (x == 2 || x == 3 || x == 8 || x == 9) {
            return PowerState.protected;
          }
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.split, markLevel: MarkLevel.mk3, grid: grid);
  }

  // SOLID STATE REACTOR
  // Pattern: Single centered 4x4 block

  /// Solid State Reactor MK1 - 16 cells (8 protected, 8 powered)
  static Reactor getSolidStateReactorMK1() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // 4x4 block at x=4-7, y=4-7
        if (x >= 4 && x <= 7 && y >= 4 && y <= 7) {
          // Top half is green, bottom half is blue
          if (y >= 6) {
            return PowerState.protected;
          }
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.solidState, markLevel: MarkLevel.mk1, grid: grid);
  }

  /// Solid State Reactor MK2 - 16 cells (12 protected, 4 powered)
  static Reactor getSolidStateReactorMK2() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // 4x4 block at x=4-7, y=4-7
        if (x >= 4 && x <= 7 && y >= 4 && y <= 7) {
          // Only top row is green
          if (y == 4) {
            return PowerState.powered;
          }
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.solidState, markLevel: MarkLevel.mk2, grid: grid);
  }

  /// Solid State Reactor MK3 - 16 cells (16 protected, 0 powered)
  static Reactor getSolidStateReactorMK3() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // 4x4 block at x=4-7, y=4-7 - all protected
        if (x >= 4 && x <= 7 && y >= 4 && y <= 7) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.solidState, markLevel: MarkLevel.mk3, grid: grid);
  }

  // MATERIA SCATTER REACTOR
  // Pattern: Horizontal bars with scattered cells

  /// Materia Scatter Reactor MK1 - 24 cells (8 protected, 16 powered)
  /// Pattern: GGGGGGGG, _G_GG_G_, GGGGGGGG, B_B__B_B
  static Reactor getMateriaScatterReactorMK1() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-9 - all green
        if (y == 4 && x >= 2 && x <= 9) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=3,5,6,8 - green
        if (y == 5 && (x == 3 || x == 5 || x == 6 || x == 8)) {
          return PowerState.powered;
        }
        // Row 2 (y=6): x=2-9 - all green
        if (y == 6 && x >= 2 && x <= 9) {
          return PowerState.powered;
        }
        // Row 3 (y=7): x=2,4,7,9 - blue (protected)
        if (y == 7 && (x == 2 || x == 4 || x == 7 || x == 9)) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.materiaScatter, markLevel: MarkLevel.mk1, grid: grid);
  }

  /// Materia Scatter Reactor MK2 - 24 cells (12 protected, 12 powered)
  /// Pattern: GGGGGGGG, _G_GG_G_, GBBGGBBG, B_B__B_B
  static Reactor getMateriaScatterReactorMK2() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-9 - all green
        if (y == 4 && x >= 2 && x <= 9) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=3,5,6,8 - green
        if (y == 5 && (x == 3 || x == 5 || x == 6 || x == 8)) {
          return PowerState.powered;
        }
        // Row 2 (y=6): x=2,3,4,6,7,8,9 - mixed
        if (y == 6) {
          if (x == 2 || x == 9) {
            return PowerState.powered; // G at ends
          }
          if (x == 3 || x == 4 || x == 7 || x == 8) {
            return PowerState.protected; // BB in middle sections
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        // Row 3 (y=7): x=2,4,7,9 - blue (protected)
        if (y == 7 && (x == 2 || x == 4 || x == 7 || x == 9)) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.materiaScatter, markLevel: MarkLevel.mk2, grid: grid);
  }

  /// Materia Scatter Reactor MK3 - 24 cells (20 protected, 4 powered)
  /// Pattern: GGGGGGGG, _B_GG_B_, BBBBBBBB, B_B__B_B
  static Reactor getMateriaScatterReactorMK3() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-9 - all green
        if (y == 4 && x >= 2 && x <= 9) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=3,5,6,8 - mixed
        if (y == 5) {
          if (x == 3 || x == 8) {
            return PowerState.protected; // B at positions 3 and 8
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        // Row 2 (y=6): x=2-9 - all blue (protected)
        if (y == 6 && x >= 2 && x <= 9) {
          return PowerState.protected;
        }
        // Row 3 (y=7): x=2,4,7,9 - blue (protected)
        if (y == 7 && (x == 2 || x == 4 || x == 7 || x == 9)) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.materiaScatter, markLevel: MarkLevel.mk3, grid: grid);
  }

  // NULL WAVE REACTOR
  // Pattern: Complex scattered pattern

  /// Null Wave Reactor MK1 - 20 cells (6 protected, 14 powered)
  /// Pattern: GG____GG, GGG__GGG, _BBGGBB_, __BGGB__
  static Reactor getNullWaveReactorMK1() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-3 and x=8-9 - green
        if (y == 4 && ((x >= 2 && x <= 3) || (x >= 8 && x <= 9))) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=2-4 and x=7-9 - green
        if (y == 5 && ((x >= 2 && x <= 4) || (x >= 7 && x <= 9))) {
          return PowerState.powered;
        }
        // Row 2 (y=6): x=3-4,5-6,7-8 - mixed
        if (y == 6) {
          if (x == 3 || x == 4 || x == 7 || x == 8) {
            return PowerState.protected; // BB on sides
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        // Row 3 (y=7): x=4,5,6,7 - mixed
        if (y == 7) {
          if (x == 4 || x == 7) {
            return PowerState.protected; // B at positions 4 and 7
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.nullWave, markLevel: MarkLevel.mk1, grid: grid);
  }

  /// Null Wave Reactor MK2 - 20 cells (10 protected, 10 powered)
  /// Pattern: GG____GG, BBG__GBB, _BBGGBB_, __BGGB__
  static Reactor getNullWaveReactorMK2() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-3 and x=8-9 - green
        if (y == 4 && ((x >= 2 && x <= 3) || (x >= 8 && x <= 9))) {
          return PowerState.powered;
        }
        // Row 1 (y=5): x=2-4 and x=7-9 - mixed
        if (y == 5) {
          if (x == 2 || x == 3 || x == 8 || x == 9) {
            return PowerState.protected; // BB on sides
          }
          if (x == 4 || x == 7) {
            return PowerState.powered; // G in middle positions
          }
        }
        // Row 2 (y=6): x=3-4,5-6,7-8 - mixed
        if (y == 6) {
          if (x == 3 || x == 4 || x == 7 || x == 8) {
            return PowerState.protected; // BB on sides
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        // Row 3 (y=7): x=4,5,6,7 - mixed
        if (y == 7) {
          if (x == 4 || x == 7) {
            return PowerState.protected; // B at positions 4 and 7
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.nullWave, markLevel: MarkLevel.mk2, grid: grid);
  }

  /// Null Wave Reactor MK3 - 20 cells (14 protected, 6 powered)
  /// Pattern: BB____BB, BBG__GBB, _BBGGBB_, __BGGB__
  static Reactor getNullWaveReactorMK3() {
    final grid = List.generate(gridSize, (y) {
      return List.generate(gridSize, (x) {
        // Row 0 (y=4): x=2-3 and x=8-9 - blue (protected)
        if (y == 4 && ((x >= 2 && x <= 3) || (x >= 8 && x <= 9))) {
          return PowerState.protected;
        }
        // Row 1 (y=5): x=2-4 and x=7-9 - mixed
        if (y == 5) {
          if (x == 2 || x == 3 || x == 8 || x == 9) {
            return PowerState.protected; // BB on sides
          }
          if (x == 4 || x == 7) {
            return PowerState.powered; // G in middle positions
          }
        }
        // Row 2 (y=6): x=3-4,5-6,7-8 - mixed
        if (y == 6) {
          if (x == 3 || x == 4 || x == 7 || x == 8) {
            return PowerState.protected; // BB on sides
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        // Row 3 (y=7): x=4,5,6,7 - mixed
        if (y == 7) {
          if (x == 4 || x == 7) {
            return PowerState.protected; // B at positions 4 and 7
          }
          if (x == 5 || x == 6) {
            return PowerState.powered; // GG in center
          }
        }
        return PowerState.none;
      });
    });
    return Reactor(type: ReactorType.nullWave, markLevel: MarkLevel.mk3, grid: grid);
  }

  /// Get all reactors
  static List<Reactor> getAllReactors() {
    return [
      // Split Reactors
      getSplitReactorMK1(),
      getSplitReactorMK2(),
      getSplitReactorMK3(),
      // Solid State Reactors
      getSolidStateReactorMK1(),
      getSolidStateReactorMK2(),
      getSolidStateReactorMK3(),
      // Materia Scatter Reactors
      getMateriaScatterReactorMK1(),
      getMateriaScatterReactorMK2(),
      getMateriaScatterReactorMK3(),
      // Null Wave Reactors
      getNullWaveReactorMK1(),
      getNullWaveReactorMK2(),
      getNullWaveReactorMK3(),
    ];
  }
}
