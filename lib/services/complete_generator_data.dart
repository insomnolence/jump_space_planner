import '../models/generator.dart';
import '../models/power_cell.dart';

/// Service class providing all generator grid patterns
/// Generators are 8 columns x 2 rows
class CompleteGeneratorData {
  static const int gridWidth = 8;
  static const int gridHeight = 2;

  /// Get all available generators
  static List<Generator> getAllGenerators() {
    return [
      // Bio Fission Generators
      getBioFissionMK1(),
      getBioFissionMK2(),
      getBioFissionMK3(),
      // Materia Shift Generators
      getMateriaShiftMK1(),
      getMateriaShiftMK2(),
      getMateriaShiftMK3(),
      // Null Tension Generators
      getNullTensionMK1(),
      getNullTensionMK2(),
      getNullTensionMK3(),
    ];
  }

  /// Get generator by type and mark level
  static Generator? getGenerator(GeneratorType type, GeneratorMarkLevel markLevel) {
    final all = getAllGenerators();
    try {
      return all.firstWhere(
        (g) => g.type == type && g.markLevel == markLevel,
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // BIO FISSION GENERATORS
  // ============================================================================

  /// Bio Fission Generator MK1
  /// Pattern: __GGGG__, __G__G__
  static Generator getBioFissionMK1() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: __GGGG__ (x=2-5)
        if (y == 0 && x >= 2 && x <= 5) {
          return PowerState.powered;
        }
        // Row 1: __G__G__ (x=2 and x=5)
        if (y == 1 && (x == 2 || x == 5)) {
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.bioFission,
      markLevel: GeneratorMarkLevel.mk1,
      grid: grid,
    );
  }

  /// Bio Fission Generator MK2
  /// Pattern: _GGGGGG_, _B____B_
  static Generator getBioFissionMK2() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: _GGGGGG_ (x=1-6)
        if (y == 0 && x >= 1 && x <= 6) {
          return PowerState.powered;
        }
        // Row 1: _B____B_ (x=1 and x=6)
        if (y == 1 && (x == 1 || x == 6)) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.bioFission,
      markLevel: GeneratorMarkLevel.mk2,
      grid: grid,
    );
  }

  /// Bio Fission Generator MK3
  /// Pattern: BGGGGGGB, B______B
  static Generator getBioFissionMK3() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: BGGGGGGB
        if (y == 0) {
          if (x == 0 || x == 7) {
            return PowerState.protected; // B at edges
          }
          return PowerState.powered; // G in middle (x=1-6)
        }
        // Row 1: B______B (x=0 and x=7)
        if (y == 1 && (x == 0 || x == 7)) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.bioFission,
      markLevel: GeneratorMarkLevel.mk3,
      grid: grid,
    );
  }

  // ============================================================================
  // MATERIA SHIFT GENERATORS
  // ============================================================================

  /// Materia Shift Generator MK1
  /// Pattern: _GG__GG_, _GG__GG_
  static Generator getMateriaShiftMK1() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Both rows: _GG__GG_ (x=1-2 and x=5-6)
        if ((x >= 1 && x <= 2) || (x >= 5 && x <= 6)) {
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.materiaShift,
      markLevel: GeneratorMarkLevel.mk1,
      grid: grid,
    );
  }

  /// Materia Shift Generator MK2
  /// Pattern: _GB__BG_, _BG__GB_
  static Generator getMateriaShiftMK2() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: _GB__BG_
        if (y == 0) {
          if (x == 1 || x == 6) {
            return PowerState.powered; // G at x=1 and x=6
          }
          if (x == 2 || x == 5) {
            return PowerState.protected; // B at x=2 and x=5
          }
        }
        // Row 1: _BG__GB_
        if (y == 1) {
          if (x == 2 || x == 5) {
            return PowerState.powered; // G at x=2 and x=5
          }
          if (x == 1 || x == 6) {
            return PowerState.protected; // B at x=1 and x=6
          }
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.materiaShift,
      markLevel: GeneratorMarkLevel.mk2,
      grid: grid,
    );
  }

  /// Materia Shift Generator MK3
  /// Pattern: _GB__BG_, _BB__BB_
  static Generator getMateriaShiftMK3() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: _GB__BG_
        if (y == 0) {
          if (x == 1 || x == 6) {
            return PowerState.powered; // G at x=1 and x=6
          }
          if (x == 2 || x == 5) {
            return PowerState.protected; // B at x=2 and x=5
          }
        }
        // Row 1: _BB__BB_ (x=1-2 and x=5-6)
        if (y == 1 && ((x >= 1 && x <= 2) || (x >= 5 && x <= 6))) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.materiaShift,
      markLevel: GeneratorMarkLevel.mk3,
      grid: grid,
    );
  }

  // ============================================================================
  // NULL TENSION GENERATORS (verified patterns)
  // ============================================================================

  /// Null Tension Generator MK1
  /// Pattern: __GGGG__, __GGGG__
  static Generator getNullTensionMK1() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Both rows: __GGGG__ (x=2-5)
        if (x >= 2 && x <= 5) {
          return PowerState.powered;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.nullTension,
      markLevel: GeneratorMarkLevel.mk1,
      grid: grid,
    );
  }

  /// Null Tension Generator MK2
  /// Pattern: __GGGG__, __BGGB__
  static Generator getNullTensionMK2() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: __GGGG__ (x=2-5)
        if (y == 0 && x >= 2 && x <= 5) {
          return PowerState.powered;
        }
        // Row 1: __BGGB__ (x=2,5 blue, x=3-4 green)
        if (y == 1) {
          if (x == 2 || x == 5) {
            return PowerState.protected; // B at edges
          }
          if (x >= 3 && x <= 4) {
            return PowerState.powered; // GG in middle
          }
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.nullTension,
      markLevel: GeneratorMarkLevel.mk2,
      grid: grid,
    );
  }

  /// Null Tension Generator MK3
  /// Pattern: __GGGG__, __BBBB__
  static Generator getNullTensionMK3() {
    final grid = List.generate(gridHeight, (y) {
      return List.generate(gridWidth, (x) {
        // Row 0: __GGGG__ (x=2-5)
        if (y == 0 && x >= 2 && x <= 5) {
          return PowerState.powered;
        }
        // Row 1: __BBBB__ (x=2-5)
        if (y == 1 && x >= 2 && x <= 5) {
          return PowerState.protected;
        }
        return PowerState.none;
      });
    });
    return Generator(
      type: GeneratorType.nullTension,
      markLevel: GeneratorMarkLevel.mk3,
      grid: grid,
    );
  }
}
