@tool
extends Resource
class_name BloxPiece

## static ################################################

static func shapes():
	return [
		[
			Vector2i(), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)
			], [
			Vector2i(0, 1), Vector2i(1, 1),
			Vector2i(), Vector2i(1, 0),
			], [
			Vector2i(), Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(0, 2)
			], [
							Vector2i(1, 0),
			Vector2i(0, 1), Vector2i(1, 1),
			Vector2i(0, 2),
			], [
			Vector2i(),
			Vector2i(0, 1), Vector2i(1, 1),
							Vector2i(1, 2),
			], [
						Vector2i(1, 1),
			Vector2i(), Vector2i(1, 0), Vector2i(2, 0),
			]
		]

static func random():
	return BloxPiece.new({cells=shapes().pick_random()})

# maybe an odd calculation
# should we ignore if a coord is both min and max in a direction?
static func calc_coord_edges_in_cells(
	coord: Vector2i, coords: Array[Vector2i]) -> Array[Vector2i]:
	var minx = coords.map(func(c): return c.x).min()
	var maxx = coords.map(func(c): return c.x).max()
	var miny = coords.map(func(c): return c.y).min()
	var maxy = coords.map(func(c): return c.y).max()

	var edges: Array[Vector2i] = []
	if coord.x == minx:
		edges.append(Vector2i.LEFT)
	if coord.x == maxx:
		edges.append(Vector2i.RIGHT)
	if coord.y == miny:
		edges.append(Vector2i.UP)
	if coord.y == maxy:
		edges.append(Vector2i.DOWN)
	return edges

static func top_left_coord(coords) -> Vector2i:
	var minx = coords.map(func(c): return c.x).min()
	var miny = coords.map(func(c): return c.y).min()
	return Vector2i(minx, miny)

# returns adjusted coords, offset such that the top-left coord is `to`
static func reset_relative(coords: Array[Vector2i], to=Vector2i()) -> Array[Vector2i]:
	var top_left = top_left_coord(coords)
	var ret: Array[Vector2i] = []
	for c in coords:
		ret.append(c - top_left + to)
	return ret

# edits the cell coords in-place, maintaining the passed cell objects
static func adjust_cells_relative(cells: Array[BloxCell], to=Vector2i()):
	var top_left = top_left_coord(cells.map(func(c): return c.coord))
	for c in cells:
		c.coord += to - top_left

## vars ################################################

@export var grid_cells: Array[BloxCell] = []

func to_pretty():
	return {grid_cells=grid_cells}

## init ################################################

func _init(opts={}):
	var coord = opts.get("coord", Vector2i())

	if opts.get("cells"):
		var xs = []
		for c in opts.get("cells"):
			xs.append(BloxCell.new({
				# adjust relative based on coord
				coord=c + coord,
				# TODO pull from passed array of colors
				color=opts.get("color"),
				}))
		grid_cells.assign(xs)

	if opts.get("grid_cells"):
		grid_cells.append_array(opts.get("grid_cells"))

# adjusts the cells relative to the passed coord
func set_root_coord(coord: Vector2i):
	BloxPiece.adjust_cells_relative(grid_cells, coord)

func cell_count() -> int:
	return len(grid_cells)

func is_empty():
	return grid_cells.is_empty()

func get_grid_cells() -> Array[BloxCell]:
	return grid_cells

func get_max_y():
	if grid_cells.is_empty():
		Log.warn("Piece with no grid_cells?", self)
		return 0
	return grid_cells.map(func(c): return c.coord.y).max()

## coords ####################################

func grid_coords() -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for c in grid_cells:
		ret.append(c.coord)
	return ret

# used to check movement in a direction
func relative_coords(dir: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for lc in grid_cells:
		ret.append(lc.coord + dir)
	return ret

## move ####################################

func move_once(dir=Vector2.DOWN):
	for c in grid_cells:
		c.coord += dir

## rotate ####################################

# TODO calc/include a center (vs corner) to rotate around here?
func rotate_coord(coord: Vector2i, dir=Vector2i.RIGHT) -> Vector2i:
	match(dir):
		Vector2i.RIGHT:
			return Vector2i(-coord.y, coord.x)
		Vector2i.LEFT:
			return Vector2i(coord.y, -coord.x)
		_:
			Log.warn("Unhandled rotate direction", dir)
			return coord

# Return a new set of potential coords to test if rotation is possible
func rotated_coords(dir=Vector2i.RIGHT) -> Array[Vector2i]:
	var og_top_left = BloxPiece.top_left_coord(grid_cells.map(func(c): return c.coord))
	var coords: Array[Vector2i] = []
	for c in grid_cells:
		coords.append(rotate_coord(c.coord, dir))
	return BloxPiece.reset_relative(coords, og_top_left)

# rotate in place to maintain object ids
# (could use a different key, like piece-id and cell index...)
func rotate_once(dir=Vector2i.RIGHT, bump=Vector2i.ZERO):
	if bump != Vector2i.ZERO:
		move_once(bump)

	var og_top_left = BloxPiece.top_left_coord(grid_cells.map(func(c): return c.coord))
	for c in grid_cells:
		c.coord = rotate_coord(c.coord, dir)
	BloxPiece.adjust_cells_relative(grid_cells, og_top_left)

## remove grid coord ####################################

func remove_coord(coord: Vector2i) -> BloxCell:
	var cell
	for c in grid_cells:
		if c.coord == coord:
			cell = c
	if not cell:
		Log.error("Tried to remove non-existent cell!", coord)
		# TODO this happens when a group AND row remove the same cell
		return
	grid_cells.erase(cell)
	return cell

## cell color ####################################

# returns the color for the cell at the passed GRID coordinate
func get_coord_color(coord: Vector2i):
	for c in grid_cells:
		if c.coord == coord:
			return c.color
	Log.warn("Tried to get color for non-existent cell!", coord)
