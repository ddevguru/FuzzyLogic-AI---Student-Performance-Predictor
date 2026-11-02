import 'dart:math';

enum CellType { empty, obstacle, start, goal }

class GridPoint {
  final int x; // col
  final int y; // row

  const GridPoint(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPoint && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  double distanceTo(GridPoint other) {
    final dx = (x - other.x).toDouble();
    final dy = (y - other.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }

  int manhattanDistance(GridPoint other) {
    return (x - other.x).abs() + (y - other.y).abs();
  }

  @override
  String toString() => '($x, $y)';
}

class GridEnvironment {
  final int width;
  final int height;
  late List<List<CellType>> grid;
  GridPoint start;
  GridPoint goal;

  GridEnvironment({
    this.width = 15,
    this.height = 15,
    GridPoint? startPoint,
    GridPoint? goalPoint,
  })  : start = startPoint ?? const GridPoint(1, 1),
        goal = goalPoint ?? GridPoint(width - 2, height - 2) {
    resetGrid();
    setupDefaultObstacles();
  }

  void resetGrid() {
    grid = List.generate(
      height,
      (y) => List.generate(width, (x) => CellType.empty),
    );
    grid[start.y][start.x] = CellType.start;
    grid[goal.y][goal.x] = CellType.goal;
  }

  void setupDefaultObstacles() {
    // Add realistic maze-like barriers that force ants to navigate
    for (int y = 3; y <= 11; y++) {
      setObstacle(5, y, true);
    }
    for (int y = 3; y <= 11; y++) {
      setObstacle(10, y, true);
    }
    // Leave opening slots
    setObstacle(5, 7, false);
    setObstacle(10, 8, false);
  }

  void setObstacle(int x, int y, bool isObstacle) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    if (GridPoint(x, y) == start || GridPoint(x, y) == goal) return;
    grid[y][x] = isObstacle ? CellType.obstacle : CellType.empty;
  }

  void toggleObstacle(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return;
    if (GridPoint(x, y) == start || GridPoint(x, y) == goal) return;
    grid[y][x] = (grid[y][x] == CellType.obstacle) ? CellType.empty : CellType.obstacle;
  }

  bool isPassable(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;
    return grid[y][x] != CellType.obstacle;
  }

  List<GridPoint> getNeighbors(GridPoint p) {
    final List<GridPoint> neighbors = [];
    const dirs = [
      GridPoint(1, 0),
      GridPoint(-1, 0),
      GridPoint(0, 1),
      GridPoint(0, -1),
    ];
    for (final d in dirs) {
      final nx = p.x + d.x;
      final ny = p.y + d.y;
      if (isPassable(nx, ny)) {
        neighbors.add(GridPoint(nx, ny));
      }
    }
    return neighbors;
  }
}
