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
			Vector2i(0, 1),
			Vector2i(), Vector2i(1, 0),
						Vector2i(1, -1),
			], [
						Vector2i(1, 1),
			Vector2i(), Vector2i(1, 0),
			Vector2i(0, -1),
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

# returns the passed coords offset such that the top-left coord is `to`
static func reset_relative(coords: Array[Vector2i], to=Vector2i()) -> Array[Vector2i]:
	var top_left = top_left_coord(coords)
	var ret: Array[Vector2i] = []
	for c in coords:
		ret.append(c - top_left + to)
	return ret

static func adjust_cells_relative(cells: Array[BloxCell], to=Vector2i()) -> Array[BloxCell]:
	var top_left = top_left_coord(cells.map(func(c): return c.coord))
	var ret: Array[BloxCell] = []
	for c in cells:
		ret.append(BloxCell.new({
			coord=c.coord - top_left + to,
			color=c.color,
			}))
	return ret

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

# adjusts the cells relative to the passed coord
func set_root_coord(coord: Vector2i):
	grid_cells = BloxPiece.adjust_cells_relative(grid_cells, coord)

func cell_count() -> int:
	return len(grid_cells)

func is_empty():
	return grid_cells.is_empty()

func get_grid_cells() -> Array[BloxCell]:
	return grid_cells

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

# TODO calc a center (vs corner) to rotate-around here?
func rotated_cells(dir=Vector2i.RIGHT) -> Array[BloxCell]:
	var og_top_left = BloxPiece.top_left_coord(grid_cells.map(func(c): return c.coord))
	var new_cells: Array[BloxCell] = []
	for c in grid_cells:
		match(dir):
			Vector2i.RIGHT:
				new_cells.append(BloxCell.new({
					coord=Vector2i(-c.coord.y, c.coord.x),
					color=c.color,
					}))
			Vector2i.LEFT:
				new_cells.append(BloxCell.new({
					coord=Vector2i(c.coord.y, -c.coord.x),
					color=c.color,
					}))

	return BloxPiece.adjust_cells_relative(new_cells, og_top_left)

func rotated_coords(dir=Vector2i.RIGHT) -> Array[Vector2i]:
	var new_cells: Array[Vector2i] = []
	for c in rotated_cells(dir):
		new_cells.append(c.coord)
	return new_cells

func rotate_once(dir=Vector2i.RIGHT, bump=Vector2i.ZERO):
	if bump != Vector2i.ZERO:
		move_once(bump)
	grid_cells = rotated_cells(dir)

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
