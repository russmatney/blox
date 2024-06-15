@tool
extends Resource
class_name BloxPiece

## static ################################################

static func shapes():
	return [
		[
			Vector2i(), Vector2i(1, 0),
			Vector2i(0, 1)
			], [
			Vector2i(), Vector2i(1, 0), Vector2i(2, 0)
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

## relative_coords ####################################333

func relative_coords(coord: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for lc in local_cells:
		ret.append(lc + coord)
	return ret

func grid_coords() -> Array[Vector2i]:
	return relative_coords(root_coord)

## move_once ####################################333

func move_once(dir=Vector2.DOWN):
	root_coord += dir
	for lc in local_cells:
		lc += dir
