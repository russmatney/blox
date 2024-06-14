@tool
extends Resource
class_name BloxGrid

## vars ################################################

@export var width: int = 6
@export var height: int = 10

var pieces: Array[BloxPiece] = []

func to_pretty():
	return {width=width, height=height}

## init ################################################

func _init(opts={}):
	width = opts.get("width", width)
	height = opts.get("height", height)

## add_piece ################################################

func can_add_piece(p: BloxPiece) -> bool:
	var dict = piece_coords_as_dict()
	for crd in p.relative_coords():
		if dict.get(crd):
			return false
	return true

func add_piece(p: BloxPiece, skip_check=false) -> bool:
	if skip_check or can_add_piece(p):
		pieces.append(p)
		return true
	return false

## coords ################################################

## returns a list of Vector2i for the grid's width and height

func all_coords() -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			ret.append(Vector2i(x, y))
	return ret

# returns a dict of coords with true/false for presence of a piece/an empty cell

func all_coords_as_dict() -> Dictionary:
	var crds = all_coords()
	var piece_crds = piece_coords()
	var ret = {}
	for crd in crds:
		ret[crd] = crd in piece_crds
	return ret

## piece_coords ################################################

## returns a list of Vector2i for all piece-cells in the grid

func piece_coords() -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for p in pieces:
		ret.append_array(p.relative_coords())
	return ret

## returns a dict of Vector2i: bool

func piece_coords_as_dict() -> Dictionary:
	var ret = {}
	for coord in piece_coords():
		ret[coord] = true
	return ret
