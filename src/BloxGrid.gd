@tool
extends Resource
class_name BloxGrid

## vars ################################################

@export var width: int = 6
@export var height: int = 10

@export var pieces: Array[BloxPiece] = []

func to_pretty():
	return {width=width, height=height}

## init ################################################

func _init(opts={}):
	width = opts.get("width", width)
	height = opts.get("height", height)

func entry_coord() -> Vector2i:
	return Vector2i(floor(width/2.0) - 1, 0)

## add_piece ################################################

func can_add_piece(p: BloxPiece) -> bool:
	var dict = piece_coords_as_dict()
	for crd in p.grid_coords():
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
		ret.append_array(p.grid_coords())
	return ret

## returns a dict of Vector2i: bool

func piece_coords_as_dict() -> Dictionary:
	var ret = {}
	for coord in piece_coords():
		ret[coord] = true
	return ret

func coords_to_piece_dict() -> Dictionary:
	var ret = {}
	for p in pieces:
		for crd in p.grid_coords():
			if crd in ret:
				Log.warn("Um, wut!? grid piece coord collision, should be impossible!")
			ret[crd] = p
	return ret

## tetris ################################################

func move_piece(piece: BloxPiece, dir=Vector2i.DOWN, skip_check=false) -> bool:
	if skip_check or can_piece_move(piece, dir):
		piece.move_once(dir)
		return true
	return false

func remove_at_coord(coord: Vector2i):
	var crd_to_piece = coords_to_piece_dict()
	var piece = crd_to_piece.get(coord)
	piece.remove_grid_coord(coord)

	if piece.is_empty():
		pieces.erase(piece)

func can_piece_move(piece: BloxPiece, dir=Vector2i.DOWN):
	var all_coords_dict = all_coords_as_dict()
	var new_cells = piece.relative_coords(piece.root_coord + dir)
	var existing_cells = piece.grid_coords()
	var to_delete = []

	for c in new_cells:
		if not c in all_coords_dict:
			return false # beyond coords of level
		if c in existing_cells:
			to_delete.append(c) # append same-piece cells

	for c in to_delete:
		new_cells.erase(c) # drop same-piece cells

	for c in new_cells:
		if all_coords_dict.get(c):
			return false # there's an occupied cell in the way
	return true

func apply_step_tetris(dir=Vector2i.DOWN) -> bool:
	# hmm i think we should do this bottom up and apply the fall right away
	# also there's probably interest in animating the change
	var to_fall = []
	for piece in pieces:
		var should_move = can_piece_move(piece, dir)
		if should_move:
			to_fall.append(piece)

	# drop them all at once
	# (this doesn't seem right, multi-piece chunks won't fall together)
	for piece in to_fall:
		move_piece(piece, dir, true)

	var did_move = not to_fall.is_empty()
	return did_move

# returns the number of rows that were cleared
func clear_rows() -> int:
	var piece_dict = piece_coords_as_dict()
	# collect coords to clear
	var crds_to_clear = []
	var rows_cleared = 0
	for y in range(height):
		var full_row = true
		var row_crds = []
		for x in range(width):
			var crd = Vector2i(x, y)
			row_crds.append(crd)
			var crd_full = piece_dict.get(crd, false)
			if not crd_full:
				full_row = false

		if full_row:
			rows_cleared += 1
			crds_to_clear.append_array(row_crds)

	# remove from each pieces' local_cells
	for crd in crds_to_clear:
		remove_at_coord(crd)

	return rows_cleared

## puyo ################################################
