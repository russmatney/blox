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

# TODO probably configurable/set by some theme
static func random_cell_color():
	return [Color.PERU, Color.AQUAMARINE, Color.CRIMSON,
		# Color.CORAL, Color.TEAL, Color.TOMATO,
		].pick_random()

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
static func ensure_top_left(cells: Array[Vector2i]) -> Array[Vector2i]:
	var minx = cells.map(func(c): return c.x).min()
	var miny = cells.map(func(c): return c.y).min()

	var ret: Array[Vector2i] = []
	for c in cells:
		ret.append(c - Vector2i(minx, miny))
	return ret

static func ensure_top_left_cells(cells: Array[BloxCell]) -> Array[BloxCell]:
	var minx = cells.map(func(c): return c.coord.x).min()
	var miny = cells.map(func(c): return c.coord.y).min()

	var ret: Array[BloxCell] = []
	for c in cells:
		ret.append(BloxCell.new({
			coord=c.coord - Vector2i(minx, miny),
			color=c.color,
			}))
	return ret

## vars ################################################

@export var local_cells: Array[BloxCell] = []
@export var root_coord = Vector2i()

var color: Color

func to_pretty():
	return {local_cells=local_cells, root_coord=root_coord}

## init ################################################

func _init(opts={}):
	if opts.get("cells"):
		var cells = []
		for c in opts.get("cells"):
			cells.append(BloxCell.new({
				coord=c,
				# make similar color choices to 'tetris-shuffle'
				color=opts.get("color", BloxPiece.random_cell_color()),
				}))
		local_cells.assign(cells)

	# drop one of these inputs
	if opts.get("coord", opts.get("root_coord")):
		root_coord = opts.get("coord", opts.get("root_coord"))

	# no need for piece-color when we have cell-color?
	if opts.get("color"):
		color = opts.get("color")
	else:
		color = BloxPiece.random_cell_color()

func set_initial_coord(coord: Vector2i):
	root_coord = coord

func cell_count() -> int:
	return len(local_cells)

func is_empty():
	return local_cells.is_empty()

## coords ####################################

func relative_coords(coord: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for lc in local_cells:
		ret.append(lc.coord + coord)
	return ret

func grid_coords() -> Array[Vector2i]:
	return relative_coords(root_coord)

func local_coords() -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for lc in local_cells:
		ret.append(lc.coord)
	return ret

# returns a list of new cells, adjusted based on root_coord
func grid_cells() -> Array[BloxCell]:
	var ret: Array[BloxCell] = []
	for lc in local_cells:
		ret.append(BloxCell.new({
			color=lc.color,
			coord=lc.coord + root_coord,
			}))
	return ret


## move ####################################

func move_once(dir=Vector2.DOWN):
	root_coord += dir
	# no need to update local_cells here!

## rotate ####################################

# maybe drop this and just change them in-place
# feels bad to dupe the rotation logic
func rotated_local_cells(dir=Vector2i.RIGHT) -> Array[BloxCell]:
	var new_cells: Array[BloxCell] = []
	for c in local_cells:
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

	return BloxPiece.ensure_top_left_cells(new_cells)

func rotated_local_coords(dir=Vector2i.RIGHT) -> Array[Vector2i]:
	var new_cells: Array[Vector2i] = []
	for c in rotated_local_cells(dir):
		new_cells.append(c.coord)
	return new_cells

func rotated_grid_coords(dir=Vector2i.RIGHT) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for c in rotated_local_coords(dir):
		ret.append(c + root_coord)
	return ret

func rotate_once(dir=Vector2i.RIGHT, bump=Vector2i.ZERO):
	root_coord += bump
	local_cells = rotated_local_cells(dir)

## remove grid coord ####################################

func remove_grid_coord(grid_coord: Vector2i):
	var local_coord = grid_coord - root_coord
	if not local_coord in local_coords():
		Log.warn("Tried to remove non-existent local_cell!")
	local_cells.assign(local_cells.filter(func(cell):
		return not cell.coord == local_coord))

## cell color ####################################

# returns the color for the cell at the passed GRID coordinate
func get_coord_color(grid_coord: Vector2i):
	var local_coord = grid_coord - root_coord

	for c in local_cells:
		if c.coord == local_coord:
			return c.color
	Log.warn("Tried to get color for non-existent local_cell!")
