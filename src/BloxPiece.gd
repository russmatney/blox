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
	return BloxPiece.new({
		cells=shapes().pick_random()
		})

# maybe an odd calculation
# should we ignore if a coord is both min and max in a direction?
static func calc_coord_edges_in_cells(
	coord: Vector2i, cells: Array[Vector2i]) -> Array[Vector2i]:
	var minx = cells.map(func(c): return c.x).min()
	var maxx = cells.map(func(c): return c.x).max()
	var miny = cells.map(func(c): return c.y).min()
	var maxy = cells.map(func(c): return c.y).max()

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

# returns the passed cells offset such that the top-left coord is 0,0
func ensure_top_left(cells: Array[Vector2i]) -> Array[Vector2i]:
	var minx = cells.map(func(c): return c.x).min()
	var miny = cells.map(func(c): return c.y).min()

	var ret: Array[Vector2i] = []
	for c in cells:
		ret.append(c - Vector2i(minx, miny))
	return ret

## vars ################################################

@export var local_cells: Array[Vector2i] = []

@export var root_coord = Vector2i()

var color: Color

func to_pretty():
	return {local_cells=local_cells}

func random_piece_color():
	return [Color.PERU, Color.AQUAMARINE, Color.CRIMSON,
		Color.CORAL, Color.TEAL, Color.TOMATO,
		].pick_random()

## init ################################################

func _init(opts={}):
	if opts.get("cells", opts.get("local_cells")):
		local_cells.assign(opts.get("cells", opts.get("local_cells")))

	if opts.get("coord", opts.get("root_coord")):
		root_coord = opts.get("coord", opts.get("root_coord"))

	if opts.get("color"):
		color = opts.get("color")
	else:
		color = random_piece_color()

func set_initial_coord(coord: Vector2i):
	root_coord = coord

func cell_count() -> int:
	return len(local_cells)

## relative_coords ####################################

func relative_coords(coord: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for lc in local_cells:
		ret.append(lc + coord)
	return ret

func grid_coords() -> Array[Vector2i]:
	return relative_coords(root_coord)

## move ####################################

func move_once(dir=Vector2.DOWN):
	root_coord += dir
	for lc in local_cells:
		lc += dir

## rotate ####################################

func rotated_local_coords(dir=Vector2i.RIGHT) -> Array[Vector2i]:
	var new_cells: Array[Vector2i] = []
	for c in local_cells:
		match(dir):
			Vector2i.RIGHT:
				new_cells.append(Vector2i(-c.y, c.x))
			Vector2i.LEFT:
				new_cells.append(Vector2i(c.y, -c.x))

	return ensure_top_left(new_cells)

func rotated_grid_coords(dir=Vector2i.RIGHT) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for c in rotated_local_coords(dir):
		ret.append(c + root_coord)
	return ret

func rotate_once(dir=Vector2i.RIGHT, bump=Vector2i.ZERO):
	root_coord += bump
	local_cells = rotated_local_coords(dir)

## remove grid coord ####################################

func remove_grid_coord(coord: Vector2i):
	var local_coord = coord - root_coord
	if not local_coord in local_cells:
		Log.warn("Tried to remove non-existent local_cell!")
	local_cells.erase(local_coord)

func is_empty():
	return local_cells.is_empty()
