import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reactor.dart';
import '../models/generator.dart';
import '../models/component.dart';
import '../models/grid_state.dart';
import '../models/power_cell.dart';
import '../services/complete_reactor_data.dart';
import '../services/complete_generator_data.dart';
import '../services/complete_component_data.dart';
import '../widgets/power_grid_widget.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late GridState _gridState;
  Component? _selectedComponent;
  GridPosition? _hoveredPosition;
  PlacedComponent? _editingComponent;
  final FocusNode _focusNode = FocusNode();
  Offset? _cursorPosition;

  bool get _isEditing => _editingComponent != null;

  @override
  void initState() {
    super.initState();
    // Initialize with Split Reactor MK1 and no generators
    _gridState = GridState(
      reactor: CompleteReactorData.getSplitReactorMK1(),
    );
    // Show help dialog on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHelpDialogIfFirstTime();
    });
  }

  Future<void> _showHelpDialogIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHelp = prefs.getBool('has_seen_help') ?? false;

    if (!hasSeenHelp && mounted) {
      _showHelpDialogContent();
      await prefs.setBool('has_seen_help', true);
    }
  }

  void _showHelpDialogContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('How to Use'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Jump Space Power Grid Planner!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                '1. Select a Component',
                'Click any component from the left panel to select it.',
                Icons.touch_app,
              ),
              _buildHelpSection(
                '2. Place on Grid',
                'Move your mouse over the grid and click to place the component.',
                Icons.grid_on,
              ),
              _buildHelpSection(
                '3. Rotate',
                'Press R key or click the ROTATE button to rotate before placing.',
                Icons.rotate_right,
              ),
              _buildHelpSection(
                '4. Edit Placed Components',
                'Click any placed component to pick it up and move it.',
                Icons.open_with,
              ),
              _buildHelpSection(
                '5. Delete',
                'Press Delete/Backspace while editing to remove a component.',
                Icons.delete_outline,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Quick Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Press Esc to cancel selection or editing'),
              const Text('• Components must be placed on powered cells'),
              const Text('• Blue cells are protected, green are vulnerable'),
              const Text('• Use the refresh button to clear all components'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Handle keyboard input (R key for rotation, Escape to cancel)
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (_isEditing &&
          (event.logicalKey == LogicalKeyboardKey.delete ||
              event.logicalKey == LogicalKeyboardKey.backspace)) {
        _deleteEditingComponent();
        return;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyR && _selectedComponent != null) {
        _rotateSelectedComponent();
      } else if (event.logicalKey == LogicalKeyboardKey.escape &&
          (_selectedComponent != null || _isEditing)) {
        _deselectComponent();
      }
    }
  }

  // Handle component tap - just select it
  void _handleComponentTap(Component component) {
    _selectComponent(component);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _beginEditingComponent(PlacedComponent component) {
    if (_isEditing) {
      _cancelEditing();
    }

    final removedState = _gridState.removeComponent(component);

    setState(() {
      _gridState = removedState;
      _editingComponent = component;
      _selectedComponent = component.component;
      _hoveredPosition = null;
    });
    _focusNode.requestFocus();
  }

  void _cancelEditing({bool restore = true}) {
    if (!_isEditing) return;

    final original = _editingComponent;
    bool restoreFailed = false;

    setState(() {
      if (restore && original != null) {
        try {
          _gridState =
              _gridState.placeComponent(original.component, original.position);
        } catch (_) {
          restoreFailed = true;
        }
      }
      _editingComponent = null;
      _selectedComponent = null;
      _hoveredPosition = null;
    });

    if (restore && restoreFailed && original != null) {
      _showError('Could not restore ${original.component.displayName}');
    }
  }

  void _deleteEditingComponent() {
    if (!_isEditing) return;
    _cancelEditing(restore: false);
  }

  void _onCellTap(GridPosition position) {
    if (_selectedComponent == null) {
      final existing = _gridState.getComponentAt(position);
      if (existing != null) {
        _beginEditingComponent(existing);
      }
      return;
    }

    String? errorMessage;
    setState(() {
      try {
        _gridState = _gridState.placeComponent(_selectedComponent!, position);
        if (_isEditing) {
          _editingComponent = null;
        }
        _selectedComponent = null;
        _hoveredPosition = null;
        _cursorPosition = null;
      } catch (e) {
        errorMessage = e.toString();
      }
    });

    if (errorMessage != null) {
      _showError('Cannot place: $errorMessage');
    }
  }

  void _selectComponent(Component component) {
    if (_isEditing) {
      _cancelEditing();
    }
    setState(() {
      _selectedComponent = component;
    });
    _focusNode.requestFocus();
  }

  void _deselectComponent() {
    if (_isEditing) {
      _cancelEditing();
    } else {
      setState(() {
        _selectedComponent = null;
        _hoveredPosition = null;
        _cursorPosition = null;
      });
    }
  }

  void _rotateSelectedComponent() {
    if (_selectedComponent != null) {
      setState(() {
        _selectedComponent = _selectedComponent!.rotate();
      });
    }
  }

  void _clearGrid() {
    setState(() {
      _gridState = _gridState.clearComponents();
      _selectedComponent = null;
      _hoveredPosition = null;
      _editingComponent = null;
    });
  }

  void _changeReactor(Reactor reactor) {
    if (_isEditing) {
      _cancelEditing();
    }
    setState(() {
      _gridState = _gridState.copyWith(reactor: reactor);
    });
  }

  void _changeAuxGeneratorA(Generator? generator) {
    if (_isEditing) {
      _cancelEditing();
    }
    setState(() {
      _gridState = _gridState.copyWith(
        auxGeneratorA: generator,
        clearAuxA: generator == null,
      );
    });
  }

  void _changeAuxGeneratorB(Generator? generator) {
    if (_isEditing) {
      _cancelEditing();
    }
    setState(() {
      _gridState = _gridState.copyWith(
        auxGeneratorB: generator,
        clearAuxB: generator == null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: MouseRegion(
        onHover: (event) {
          if (_selectedComponent != null) {
            setState(() {
              _cursorPosition = event.position;
            });
          }
        },
        child: Stack(
          children: [
            Scaffold(
        appBar: AppBar(
          title: const Text('Jump Space Power Grid Planner'),
          actions: [
            if (_selectedComponent != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      avatar: Icon(Icons.widgets, size: 16, color: Colors.white),
                      label: Text(
                        _isEditing
                            ? 'Editing: ${_selectedComponent!.displayName}'
                            : _selectedComponent!.displayName,
                      ),
                      labelStyle: TextStyle(
                        color: _isEditing ? Colors.white : null,
                        fontWeight: _isEditing ? FontWeight.bold : null,
                      ),
                      backgroundColor:
                          _isEditing ? Colors.orange.shade700 : null,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      deleteIconColor: _isEditing ? Colors.white : null,
                      onDeleted: _deselectComponent,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange.shade700, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _buildComponentShapePreview(_selectedComponent!),
                    ),
                  ],
                ),
              ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: _showHelpDialogContent,
              tooltip: 'Show help',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearGrid,
              tooltip: 'Clear all placed components',
            ),
          ],
        ),
        body: Row(
          children: [
            // Left panel - Controls
            Expanded(flex: 1, child: _buildControlPanel()),
            // Center - Grid
            Expanded(flex: 2, child: _buildGridPanel()),
            // Right panel - Legend
            Expanded(flex: 1, child: _buildInfoPanel()),
          ],
        ),
      ),
            if (_selectedComponent != null && _cursorPosition != null)
              _buildCursorFollower(),
          ],
        ),
      ),
    );
  }

  Widget _buildCursorFollower() {
    if (_selectedComponent == null || _cursorPosition == null || _hoveredPosition != null) {
      return const SizedBox.shrink();
    }

    final cellSize = 35.0; // Same as grid cell size
    final bounds = _selectedComponent!.shape.bounds;
    final width = bounds.$1 * cellSize;
    final height = bounds.$2 * cellSize;

    return Positioned(
      left: _cursorPosition!.dx,
      top: _cursorPosition!.dy,
      child: IgnorePointer(
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _CursorFollowerPainter(_selectedComponent!, cellSize),
          ),
        ),
      ),
    );
  }


  Widget _buildGridPanel() {
    final instructionText = _isEditing
        ? 'Editing component: move to new cell • Press R to rotate • Click to place • Esc to cancel • Delete to remove'
        : (_selectedComponent != null
            ? 'Move mouse over grid • Press R to rotate • Click to place • Esc to cancel'
            : 'Click component to select • Click placed component to pick it up • Use Delete to remove');

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PowerGridWidget(
              gridState: _gridState,
              cellSize: 35,
              onCellTap: _onCellTap,
              onHoverPositionChanged: (pos) {
                setState(() {
                  _hoveredPosition = pos;
                });
              },
              highlightedPosition: _hoveredPosition,
              previewComponent: _selectedComponent,
            ),
            const SizedBox(height: 20),
            _buildPlacementToolbar(),
            const SizedBox(height: 10),
            Text(
              instructionText,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacementToolbar() {
    final hasSelection = _selectedComponent != null;

    return AnimatedOpacity(
      opacity: hasSelection ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !hasSelection,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _rotateSelectedComponent,
                  icon: const Icon(Icons.rotate_right, size: 24),
                  label: const Text('ROTATE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 10),
                if (_isEditing)
                  ElevatedButton.icon(
                    onPressed: _deleteEditingComponent,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                if (_isEditing) const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _deselectComponent,
                  icon: Icon(_isEditing ? Icons.close : Icons.clear),
                  label: Text(_isEditing ? 'Cancel' : 'Deselect'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isEditing
                  ? 'Use Rotate to adjust before placing • Delete removes the component'
                  : 'Press R key or click ROTATE button',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade300),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const PowerGridLegend(),
            const SizedBox(height: 20),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReactorSelector(),
            const SizedBox(height: 12),
            _buildGeneratorSelector('Aux Generator A', _gridState.auxGeneratorA, _changeAuxGeneratorA),
            const SizedBox(height: 12),
            _buildGeneratorSelector('Aux Generator B', _gridState.auxGeneratorB, _changeAuxGeneratorB),
            const SizedBox(height: 20),
            _buildComponentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReactorSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Main Reactor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _gridState.reactor.displayName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: _gridState.reactor.displayName,
              items: CompleteReactorData.getAllReactors().map((reactor) {
                return DropdownMenuItem(
                  value: reactor.displayName,
                  child: Text(reactor.displayName, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (reactorName) {
                if (reactorName != null) {
                  final reactor = CompleteReactorData.getAllReactors()
                      .firstWhere((r) => r.displayName == reactorName);
                  _changeReactor(reactor);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratorSelector(String label, Generator? currentGenerator, Function(Generator?) onChange) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentGenerator?.displayName ?? 'None',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            DropdownButton<String?>(
              isExpanded: true,
              value: currentGenerator?.displayName,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None', style: TextStyle(fontSize: 13)),
                ),
                for (final generator in CompleteGeneratorData.getAllGenerators())
                  DropdownMenuItem(
                    value: generator.displayName,
                    child: Text(generator.displayName, style: const TextStyle(fontSize: 13)),
                  ),
              ],
              onChanged: (generatorName) {
                if (generatorName == null) {
                  onChange(null);
                } else {
                  final generator = CompleteGeneratorData.getAllGenerators()
                      .firstWhere((g) => g.displayName == generatorName);
                  onChange(generator);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentList() {
    // Filter out auxiliary generators - they are managed via the selector cards
    final availableComponents = CompleteComponentData
        .getAllComponents()
        .where((component) => component.type != ComponentType.auxiliaryGenerator)
        .toList();

    // Group components by type
    final componentsByType = <ComponentType, List<Component>>{};
    for (final component in availableComponents) {
      componentsByType.putIfAbsent(component.type, () => []).add(component);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Components',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${availableComponents.length} total',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            for (final entry in componentsByType.entries)
              ExpansionTile(
                title: Text(_getComponentTypeLabel(entry.key)),
                subtitle: Text('${entry.value.length} items', style: const TextStyle(fontSize: 11)),
                initiallyExpanded: entry.key == ComponentType.engine,
                children: [
                  for (final component in entry.value)
                    Card(
                      color: _selectedComponent?.id == component.id
                          ? Colors.blue.withValues(alpha: 0.3)
                          : null,
                      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.touch_app, size: 16),
                        title: Text(component.displayName, style: const TextStyle(fontSize: 13)),
                        trailing: _buildComponentShapePreview(component),
                        onTap: () => _handleComponentTap(component),
                        selected: _selectedComponent?.id == component.id,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildComponentShapePreview(Component component) {
    final bounds = component.shape.bounds;
    final scale = 4.0;

    return SizedBox(
      width: bounds.$1 * scale + 2,
      height: bounds.$2 * scale + 2,
      child: CustomPaint(
        painter: _ComponentShapePainter(component, scale),
      ),
    );
  }

  String _getComponentTypeLabel(ComponentType type) {
    switch (type) {
      case ComponentType.sensor:
        return 'Sensors';
      case ComponentType.engine:
        return 'Engines';
      case ComponentType.pilotCannon:
        return 'Pilot Cannons';
      case ComponentType.multiTurret:
        return 'Multi Turrets';
      case ComponentType.specialWeapon:
        return 'Special Weapons';
      case ComponentType.auxiliaryGenerator:
        return 'Aux Generators';
    }
  }

  Widget _buildStatsCard() {
    final poweredCells = _gridState.reactor.getPoweredCells();
    final protectedCount = poweredCells.where((c) => c.powerState == PowerState.protected).length;
    final vulnerableCount = poweredCells.where((c) => c.powerState == PowerState.powered).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Main Reactor:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade300)),
            Text('  ${_gridState.reactor.displayName}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('Power Grid:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade300)),
            Text('  Total: ${poweredCells.length} cells', style: const TextStyle(fontSize: 13)),
            Text('  Protected: $protectedCount', style: TextStyle(fontSize: 13, color: Colors.blue.shade400)),
            Text('  Vulnerable: $vulnerableCount', style: TextStyle(fontSize: 13, color: Colors.green.shade400)),
            const Divider(height: 20),
            if (_gridState.auxGeneratorA != null)
              Text('Aux Gen A: ${_gridState.auxGeneratorA!.displayName}', style: const TextStyle(fontSize: 13)),
            if (_gridState.auxGeneratorB != null)
              Text('Aux Gen B: ${_gridState.auxGeneratorB!.displayName}', style: const TextStyle(fontSize: 13)),
            const Divider(height: 20),
            Text('Components: ${_gridState.placedComponents.length}', style: const TextStyle(fontSize: 13)),
            Text('Grid: ${GridState.gridWidth}x${GridState.totalHeight} (8x8)', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ComponentShapePainter extends CustomPainter {
  final Component component;
  final double scale;

  _ComponentShapePainter(this.component, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.shade700
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final pos in component.shape.positions) {
      final rect = Rect.fromLTWH(
        pos.x * scale,
        pos.y * scale,
        scale,
        scale,
      );
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_ComponentShapePainter oldDelegate) => false;
}

class _CursorFollowerPainter extends CustomPainter {
  final Component component;
  final double cellSize;

  _CursorFollowerPainter(this.component, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0xFF7A36A7) // Same purple as placed components
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final pos in component.shape.positions) {
      final rect = Rect.fromLTWH(
        pos.x * cellSize,
        pos.y * cellSize,
        cellSize,
        cellSize,
      );
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    }

    // Draw outline like on the grid
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = _buildOutlinePath();
    if (path != null) {
      canvas.drawPath(path, outlinePaint);
    }
  }

  Path? _buildOutlinePath() {
    final edges = <_GridSegment>{};

    void toggleEdge(_GridPoint a, _GridPoint b) {
      final segment = _GridSegment(a, b);
      if (!edges.remove(segment)) {
        edges.add(segment);
      }
    }

    for (final relative in component.shape.positions) {
      final cellX = relative.x;
      final cellY = relative.y;

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
  bool shouldRepaint(_CursorFollowerPainter oldDelegate) =>
      oldDelegate.component != component;
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
