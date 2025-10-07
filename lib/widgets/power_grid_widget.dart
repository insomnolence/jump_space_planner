import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/component.dart';
import '../models/grid_state.dart';
import '../models/power_cell.dart';

/// Displays the combined power grid for the main reactor and auxiliary generators.
/// Labels sit to the left so the three sections can be shown as one contiguous grid.
class PowerGridWidget extends StatefulWidget {
  final GridState gridState;
  final double cellSize;
  final void Function(GridPosition)? onCellTap;
  final void Function(GridPosition?)? onHoverPositionChanged;
  final GridPosition? highlightedPosition;
  final Component? previewComponent;
  final bool compactLabels;
  final GlobalKey? gridKey;

  const PowerGridWidget({
    super.key,
    required this.gridState,
    this.cellSize = 40.0,
    this.onCellTap,
    this.onHoverPositionChanged,
    this.highlightedPosition,
    this.previewComponent,
    this.compactLabels = false,
    this.gridKey,
  });

  @override
  State<PowerGridWidget> createState() => _PowerGridWidgetState();
}

class _PowerGridWidgetState extends State<PowerGridWidget> {
  static const _sectionOrder = [
    GridSection.mainReactor,
    GridSection.auxGeneratorA,
    GridSection.auxGeneratorB,
  ];

  static const Map<GridSection, String> _sectionLabels = {
    GridSection.mainReactor: 'Main Reactor',
    GridSection.auxGeneratorA: 'Aux Generator A',
    GridSection.auxGeneratorB: 'Aux Generator B',
  };

  static const Map<GridSection, String> _compactSectionLabels = {
    GridSection.mainReactor: 'Main',
    GridSection.auxGeneratorA: 'Aux A',
    GridSection.auxGeneratorB: 'Aux B',
  };

  late final GlobalKey _gridKey;
  GridPosition? _hoverPosition;

  @override
  void initState() {
    super.initState();
    _gridKey = widget.gridKey ?? GlobalKey();
  }

  @override
  void didUpdateWidget(covariant PowerGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.previewComponent == null && _hoverPosition != null) {
      setState(() {
        _hoverPosition = null;
      });
      if (widget.onHoverPositionChanged != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onHoverPositionChanged!(null);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabels(),
        const SizedBox(width: 12),
        _buildGrid(),
      ],
    );
  }

  Widget _buildSectionLabels() {
    final labels = widget.compactLabels ? _compactSectionLabels : _sectionLabels;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _sectionOrder.map((section) {
        final height = widget.gridState.getSectionHeight(section) * widget.cellSize;
        return Container(
          height: height,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 8),
          child: widget.compactLabels
              ? RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    labels[section]!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                )
              : Text(
                  labels[section]!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid() {
    final gridWidthPx = GridState.gridWidth * widget.cellSize;
    final gridHeightPx = GridState.totalHeight * widget.cellSize;

    return MouseRegion(
      onHover: widget.previewComponent != null ? _handleHover : null,
      onExit: (_) => _clearHover(),
      child: SizedBox(
        width: gridWidthPx,
        height: gridHeightPx,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: _gridKey,
              color: Colors.black87,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(GridState.totalHeight, (y) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(GridState.gridWidth, (x) {
                      return _buildCell(x, y);
                    }),
                  );
                }),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: _ComponentOutlinePainter(
                    components: widget.gridState.placedComponents,
                    cellSize: widget.cellSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleHover(PointerHoverEvent event) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }

    final localPos = box.globalToLocal(event.position);
    final cellX = (localPos.dx / widget.cellSize).floor();
    final cellY = (localPos.dy / widget.cellSize).floor();

    if (cellX >= 0 &&
        cellX < GridState.gridWidth &&
        cellY >= 0 &&
        cellY < GridState.totalHeight) {
      final position = GridPosition(x: cellX, y: cellY);
      if (position != _hoverPosition) {
        setState(() {
          _hoverPosition = position;
        });
      }
      widget.onHoverPositionChanged?.call(position);
    } else {
      _clearHover();
    }
  }

  void _clearHover() {
    if (_hoverPosition != null) {
      setState(() {
        _hoverPosition = null;
      });
    }
    widget.onHoverPositionChanged?.call(null);
  }

  Widget _buildCell(int x, int y) {
    final position = GridPosition(x: x, y: y);
    final powerState = widget.gridState.getPowerStateAt(x, y);
    final isPowered = powerState != PowerState.none;
    final placedComponent = widget.gridState.getComponentAt(position);
    final isOccupied = placedComponent != null;
    final isHighlighted = widget.highlightedPosition == position;
    final isPreview = _isInPreview(position);

    Color cellColor = isPowered ? _getPowerColor(powerState) : Colors.black;

    if (isOccupied) {
      cellColor = const Color(0xFF7A36A7); // richer purple for placed components
    }

    if (isPreview && widget.previewComponent != null && _hoverPosition != null) {
      final canPlace = widget.gridState.canPlaceComponent(
        widget.previewComponent!,
        _hoverPosition!,
      );
      cellColor = canPlace
          ? Colors.blue.withValues(alpha: 0.6)
          : Colors.red.withValues(alpha: 0.6);
    }

    final stackChildren = <Widget>[
      Container(
        width: widget.cellSize,
        height: widget.cellSize,
        decoration: BoxDecoration(
          color: cellColor,
          border: _buildCellBorder(x, y),
        ),
      ),
    ];

    if (placedComponent != null) {
      final label = _buildComponentLabel(placedComponent, position);
      if (label != null) {
        stackChildren.add(label);
      }
    }

    if (isHighlighted) {
      stackChildren.add(
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }

    Widget cell = Stack(children: stackChildren);

    if (placedComponent != null) {
      cell = Tooltip(
        message: placedComponent.component.displayName,
        waitDuration: const Duration(milliseconds: 250),
        child: cell,
      );
    }

    return GestureDetector(
      onTap: widget.onCellTap != null ? () => widget.onCellTap!(position) : null,
      child: cell,
    );
  }

  Border _buildCellBorder(int x, int y) {
    final thickColor = Colors.orange.shade700;
    final thinColor = Colors.grey.shade700;

    final isFirstColumn = x == 0;
    final isLastColumn = x == GridState.gridWidth - 1;
    final isFirstRow = y == 0;
    final isLastRow = y == GridState.totalHeight - 1;
    final isSectionStart =
        y == GridState.mainReactorHeight ||
        y == GridState.mainReactorHeight + GridState.auxGeneratorHeight;
    final isSectionEnd =
        y == GridState.mainReactorHeight - 1 ||
        y == GridState.mainReactorHeight + GridState.auxGeneratorHeight - 1 ||
        isLastRow;

    return Border(
      left: BorderSide(
        color: isFirstColumn ? thickColor : thinColor,
        width: isFirstColumn ? 2 : 0.5,
      ),
      right: BorderSide(
        color: isLastColumn ? thickColor : thinColor,
        width: isLastColumn ? 2 : 0.5,
      ),
      top: BorderSide(
        color: isFirstRow
            ? thickColor
            : (isSectionStart ? thickColor : thinColor),
        width: isFirstRow
            ? 2
            : (isSectionStart ? 0 : 0.5),
      ),
      bottom: BorderSide(
        color: isSectionEnd ? thickColor : thinColor,
        width: isSectionEnd ? 2 : 0.5,
      ),
    );
  }

  Widget? _buildComponentLabel(PlacedComponent placed, GridPosition position) {
    // Find the best cell to display the label (top-left-most cell that exists)
    final labelPosition = _findLabelPosition(placed);

    if (labelPosition != position) {
      return null;
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 0.7,
            ),
          ),
          child: Text(
            placed.component.shortLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  GridPosition _findLabelPosition(PlacedComponent placed) {
    // Find the top-left-most actual cell in the shape
    // Sort by y first (top), then by x (left)
    final sortedPositions = placed.component.shape.positions.toList()
      ..sort((a, b) {
        if (a.y != b.y) return a.y.compareTo(b.y);
        return a.x.compareTo(b.x);
      });

    // Use the first (top-left-most) cell as the label position
    if (sortedPositions.isEmpty) {
      return placed.position;
    }

    final labelOffset = sortedPositions.first;
    return GridPosition(
      x: placed.position.x + labelOffset.x,
      y: placed.position.y + labelOffset.y,
    );
  }

  bool _isInPreview(GridPosition cellPosition) {
    if (widget.previewComponent == null || _hoverPosition == null) {
      return false;
    }

    for (final shapePos in widget.previewComponent!.shape.positions) {
      final previewPosition = GridPosition(
        x: _hoverPosition!.x + shapePos.x,
        y: _hoverPosition!.y + shapePos.y,
      );
      if (previewPosition == cellPosition) {
        return true;
      }
    }
    return false;
  }

  Color _getPowerColor(PowerState state) {
    switch (state) {
      case PowerState.none:
        return Colors.black;
      case PowerState.powered:
        return Colors.green.shade700;
      case PowerState.protected:
        return Colors.blue.shade700;
    }
  }
}

/// A legend widget showing what each color means
class PowerGridLegend extends StatelessWidget {
  const PowerGridLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Grid Legend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem(Colors.black, 'No Power'),
            _buildLegendItem(Colors.green.shade700, 'Powered (Vulnerable)'),
            _buildLegendItem(Colors.blue.shade700, 'Protected Power'),
            _buildLegendItem(Colors.purple.shade700, 'Component Placed'),
            _buildLegendItem(Colors.blue.withValues(alpha: 0.6), 'Valid Placement'),
            _buildLegendItem(Colors.red.withValues(alpha: 0.6), 'Invalid Placement'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _ComponentOutlinePainter extends CustomPainter {
  final List<PlacedComponent> components;
  final double cellSize;

  _ComponentOutlinePainter({
    required this.components,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    for (final placed in components) {
      final path = _buildComponentPath(placed);
      if (path != null) {
        canvas.drawPath(path, paint);
      }
    }
  }

  Path? _buildComponentPath(PlacedComponent placed) {
    final edges = <_GridSegment>{};

    void toggleEdge(_GridPoint a, _GridPoint b) {
      final segment = _GridSegment(a, b);
      if (!edges.remove(segment)) {
        edges.add(segment);
      }
    }

    for (final relative in placed.component.shape.positions) {
      final cellX = placed.position.x + relative.x;
      final cellY = placed.position.y + relative.y;

      final topLeft = _GridPoint(cellX, cellY);
      final topRight = _GridPoint(cellX + 1, cellY);
      final bottomRight = _GridPoint(cellX + 1, cellY + 1);
      final bottomLeft = _GridPoint(cellX, cellY + 1);

      toggleEdge(topLeft, topRight);
      toggleEdge(topRight, bottomRight);
      toggleEdge(bottomRight, bottomLeft);
      toggleEdge(bottomLeft, topLeft);
    }

    if (edges.isEmpty) {
      return null;
    }

    final adjacency = <_GridPoint, Set<_GridPoint>>{};
    for (final segment in edges) {
      adjacency.putIfAbsent(segment.start, () => <_GridPoint>{}).add(segment.end);
      adjacency.putIfAbsent(segment.end, () => <_GridPoint>{}).add(segment.start);
    }

    final path = Path();

    void removeConnection(_GridPoint a, _GridPoint b) {
      final neighborsA = adjacency[a];
      if (neighborsA != null) {
        neighborsA.remove(b);
        if (neighborsA.isEmpty) {
          adjacency.remove(a);
        }
      }
      final neighborsB = adjacency[b];
      if (neighborsB != null) {
        neighborsB.remove(a);
        if (neighborsB.isEmpty) {
          adjacency.remove(b);
        }
      }
    }

    while (adjacency.isNotEmpty) {
      final start = adjacency.keys.first;
      final startNeighbors = adjacency[start];
      if (startNeighbors == null || startNeighbors.isEmpty) {
        adjacency.remove(start);
        continue;
      }

      final initialNext = startNeighbors.first;
      final componentPath = Path()
        ..moveTo(start.x * cellSize, start.y * cellSize);

      var current = start;
      var next = initialNext;

      while (true) {
        componentPath.lineTo(next.x * cellSize, next.y * cellSize);
        removeConnection(current, next);

        if (next == start) {
          break;
        }

        final neighbors = adjacency[next];
        if (neighbors == null || neighbors.isEmpty) {
          break;
        }

        _GridPoint candidate;
        if (neighbors.length == 1) {
          candidate = neighbors.first;
        } else {
          candidate = neighbors.firstWhere((point) => point != current, orElse: () => neighbors.first);
        }

        current = next;
        next = candidate;
      }

      componentPath.close();
      path.addPath(componentPath, Offset.zero);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _ComponentOutlinePainter oldDelegate) {
    if (identical(oldDelegate, this)) {
      return false;
    }
    if (oldDelegate.cellSize != cellSize) {
      return true;
    }
    if (oldDelegate.components.length != components.length) {
      return true;
    }
    for (int i = 0; i < components.length; i++) {
      if (oldDelegate.components[i] != components[i]) {
        return true;
      }
    }
    return false;
  }
}

class _GridPoint {
  final int x;
  final int y;

  const _GridPoint(this.x, this.y);

  int compareTo(_GridPoint other) {
    if (y != other.y) {
      return y - other.y;
    }
    return x - other.x;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _GridPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

class _GridSegment {
  final _GridPoint start;
  final _GridPoint end;

  _GridSegment(_GridPoint a, _GridPoint b)
      : assert(a != b),
        start = a.compareTo(b) <= 0 ? a : b,
        end = a.compareTo(b) <= 0 ? b : a;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _GridSegment && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
