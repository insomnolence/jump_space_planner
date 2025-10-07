/// Represents the power state of a single grid cell
enum PowerState {
  none(0),      // No power (black)
  powered(1),   // Powered but vulnerable (green)
  protected(2); // Protected power (blue)

  const PowerState(this.value);
  final int value;

  static PowerState fromValue(int value) {
    return PowerState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => PowerState.none,
    );
  }
}

/// Represents a single cell in the power grid
class PowerCell {
  final int x;
  final int y;
  final PowerState powerState;

  const PowerCell({
    required this.x,
    required this.y,
    required this.powerState,
  });

  PowerCell copyWith({
    int? x,
    int? y,
    PowerState? powerState,
  }) {
    return PowerCell(
      x: x ?? this.x,
      y: y ?? this.y,
      powerState: powerState ?? this.powerState,
    );
  }

  bool get isPowered =>
      powerState == PowerState.powered || powerState == PowerState.protected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PowerCell &&
        other.x == x &&
        other.y == y &&
        other.powerState == powerState;
  }

  @override
  int get hashCode => Object.hash(x, y, powerState);
}
