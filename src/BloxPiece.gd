@tool
extends Resource
class_name BloxPiece

## vars ################################################

@export var local_cells: Array[Vector2i] = []
# @export var grid_cells: Array[Vector2i] = []

var root_coord = Vector2i()

func to_pretty():
	return {
		local_cells=local_cells,
		# grid_cells=grid_cells,
		}

## init ################################################

func _init(opts={}):
	if opts.get("cells", opts.get("local_cells")):
		local_cells.assign(opts.get("cells", opts.get("local_cells")))

	if opts.get("coord", opts.get("root_coord")):
		root_coord = opts.get("coord", opts.get("root_coord"))

## relative_coords ####################################333

func relative_coords(coord: Vector2i = root_coord) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for lc in local_cells:
		ret.append(lc + coord)
	return ret

## move_once ####################################333

func move_once(dir=Vector2.DOWN):
	root_coord += dir
	for lc in local_cells:
		lc += dir
