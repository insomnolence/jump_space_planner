import 'reactor.dart';
import 'component.dart';
import 'generator.dart';
import 'power_cell.dart';

/// Which grid section a component is placed in
enum GridSection {
  mainReactor, // 8x4 main reactor grid
  auxGeneratorA, // 8x2 auxiliary generator A
  auxGeneratorB, // 8x2 auxiliary generator B
}

/// Represents a placed component on the grid
class PlacedComponent {
  final Component component;
  final GridPosition position;
  final int rotation; // 0, 90, 180, 270 degrees

  const PlacedComponent({
    required this.component,
    required this.position,
    this.rotation = 0,
  });

  /// Get all grid positions occupied by this component
  List<GridPosition> get occupiedPositions {
    return component.shape.positions.map((pos) {
      return GridPosition(
        x: position.x + pos.x,
        y: position.y + pos.y,
      );
    }).toList();
  }

  PlacedComponent copyWith({
    Component? component,
    GridPosition? position,
    int? rotation,
  }) {
    return PlacedComponent(
      component: component ?? this.component,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlacedComponent &&
        other.component == component &&
        other.position == position &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => Object.hash(component, position, rotation);
}

/// Manages the state of the power grid and placed components
class GridState {
  final Reactor reactor;
  final Generator? auxGeneratorA;
  final Generator? auxGeneratorB;
  final List<PlacedComponent> placedComponents;

  // Grid dimensions
  static const int gridWidth = 8;
  static const int mainReactorHeight = 4;
  static const int auxGeneratorHeight = 2;
  static const int totalHeight =
      mainReactorHeight + (2 * auxGeneratorHeight); // 8 rows total

  const GridState({
    required this.reactor,
    this.auxGeneratorA,
    this.auxGeneratorB,
    this.placedComponents = const [],
  });

  /// Get the height of a specific grid section
  int getSectionHeight(GridSection section) {
    switch (section) {
      case GridSection.mainReactor:
        return mainReactorHeight;
      case GridSection.auxGeneratorA:
      case GridSection.auxGeneratorB:
        return auxGeneratorHeight;
    }
  }

  /// Get the Y offset for a specific grid section
  int getSectionYOffset(GridSection section) {
    switch (section) {
      case GridSection.mainReactor:
        return 0;
      case GridSection.auxGeneratorA:
        return mainReactorHeight;
      case GridSection.auxGeneratorB:
        return mainReactorHeight + auxGeneratorHeight;
    }
  }

  /// Determine which section a global Y coordinate belongs to
  GridSection? getSectionForRow(int y) {
    if (y < 0 || y >= totalHeight) {
      return null;
    }
    if (y < mainReactorHeight) {
      return GridSection.mainReactor;
    }
    if (y < mainReactorHeight + auxGeneratorHeight) {
      return GridSection.auxGeneratorA;
    }
    return GridSection.auxGeneratorB;
  }

  /// Translate a global Y coordinate into the local Y within its section
  int _localYForSection(int globalY, GridSection section) {
    return globalY - getSectionYOffset(section);
  }

  /// Get the power state at a global grid position
  PowerState getPowerStateAt(int x, int y) {
    if (x < 0 || x >= gridWidth || y < 0 || y >= totalHeight) {
      return PowerState.none;
    }

    final section = getSectionForRow(y);
    if (section == null) {
      return PowerState.none;
    }

    final localY = _localYForSection(y, section);
    switch (section) {
      case GridSection.mainReactor:
        // Reactor grid is centered within 12x12: offset x by 2, y by 4
        return reactor.getPowerState(x + 2, localY + 4);
      case GridSection.auxGeneratorA:
        return auxGeneratorA?.getPowerState(x, localY) ?? PowerState.none;
      case GridSection.auxGeneratorB:
        return auxGeneratorB?.getPowerState(x, localY) ?? PowerState.none;
    }
  }

  /// Check if a global grid position is powered (green or blue)
  bool isPoweredAt(int x, int y) {
    final state = getPowerStateAt(x, y);
    return state == PowerState.powered || state == PowerState.protected;
  }

  /// Check if a component can be placed at a given global position
  bool canPlaceComponent(Component component, GridPosition position) {
    for (final shapePos in component.shape.positions) {
      final gridX = position.x + shapePos.x;
      final gridY = position.y + shapePos.y;

      if (gridX < 0 || gridX >= gridWidth || gridY < 0 || gridY >= totalHeight) {
        return false;
      }

      if (!isPoweredAt(gridX, gridY)) {
        return false;
      }

      if (isPositionOccupied(GridPosition(x: gridX, y: gridY))) {
        return false;
      }
    }

    return true;
  }

  /// Check if a grid position is occupied by any placed component
  bool isPositionOccupied(GridPosition position) {
    return getComponentAt(position) != null;
  }

  /// Place a component on the grid
  GridState placeComponent(Component component, GridPosition position) {
    if (!canPlaceComponent(component, position)) {
      throw Exception('Cannot place component at position $position');
    }

    return GridState(
      reactor: reactor,
      auxGeneratorA: auxGeneratorA,
      auxGeneratorB: auxGeneratorB,
      placedComponents: [
        ...placedComponents,
        PlacedComponent(
          component: component,
          position: position,
        ),
      ],
    );
  }

  /// Remove a component from the grid
  GridState removeComponent(PlacedComponent component) {
    return GridState(
      reactor: reactor,
      auxGeneratorA: auxGeneratorA,
      auxGeneratorB: auxGeneratorB,
      placedComponents: placedComponents
          .where((c) => c != component)
          .toList(),
    );
  }

  /// Clear all placed components
  GridState clearComponents() {
    return GridState(
      reactor: reactor,
      auxGeneratorA: auxGeneratorA,
      auxGeneratorB: auxGeneratorB,
      placedComponents: [],
    );
  }

  /// Returns the placed component occupying the given position, if any
  PlacedComponent? getComponentAt(GridPosition position) {
    for (final placed in placedComponents) {
      if (placed.occupiedPositions.contains(position)) {
        return placed;
      }
    }
    return null;
  }

  GridState copyWith({
    Reactor? reactor,
    Generator? auxGeneratorA,
    Generator? auxGeneratorB,
    List<PlacedComponent>? placedComponents,
    bool clearAuxA = false,
    bool clearAuxB = false,
  }) {
    return GridState(
      reactor: reactor ?? this.reactor,
      auxGeneratorA: clearAuxA ? null : (auxGeneratorA ?? this.auxGeneratorA),
      auxGeneratorB: clearAuxB ? null : (auxGeneratorB ?? this.auxGeneratorB),
      placedComponents: placedComponents ?? this.placedComponents,
    );
  }
}
