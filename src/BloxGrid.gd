@tool
extends Resource
class_name BloxGrid

## vars ################################################

@export var width: int = 6
@export var height: int = 10

@export var pieces: Array[BloxPiece] = []

func to_pretty():
	return {width=width, height=height, pieces=pieces}

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

## move piece ################################################

func move_piece(piece: BloxPiece, dir=Vector2i.DOWN, skip_check=false) -> bool:
	if skip_check or can_piece_move(piece, dir):
		piece.move_once(dir)
		return true
	return false

func can_piece_move(piece: BloxPiece, dir=Vector2i.DOWN):
	var new_cells = piece.relative_coords(piece.root_coord + dir)
	var existing_cells = piece.grid_coords()
	var conflicts = calc_conflicts(new_cells, existing_cells)
	return conflicts.is_empty()

# returns true if the new_cell coords point to an existing piece
# the existing_cells are ignored, and are assumed to belong to the moving/rotating piece
# PERF could pass an optional early return flag
func calc_conflicts(new_cells: Array[Vector2i], existing_cells: Array[Vector2i]) -> Array[Vector2i]:
	var all_coords_dict = all_coords_as_dict()
	var conflicts: Array[Vector2i] = []

	for c in new_cells:
		if not c in all_coords_dict:
			Log.info("Cannot move/rotate into level boundary", c)
			conflicts.append(c) # beyond coords of level
			# return true

	for c in new_cells:
		if c in existing_cells:
			continue # ignore existing cells (b/c they'll move out of the way)
		if all_coords_dict.get(c):
			Log.info("Cannot move/rotate into existing cell", c)
			conflicts.append(c) # there's an occupied cell in the way
	return conflicts

## rotate piece ################################################

func rotate_piece(piece: BloxPiece, dir=Vector2i.RIGHT) -> bool:
	var ret = can_piece_rotate(piece, dir)
	if ret[0]:
		piece.rotate_once(dir, ret[1])
		return true
	return false

func can_piece_rotate(piece: BloxPiece, dir=Vector2i.RIGHT) -> Array:
	var new_cells = piece.rotated_grid_coords(dir)
	var existing_cells = piece.grid_coords()

	# bump/push away from edges/pieces to make the rotation fit
	var conflicts = calc_conflicts(new_cells, existing_cells)

	if conflicts.is_empty():
		return [true, Vector2i()]

	# collecting conflicting edge directions of the new_cells
	var conflict_edges = []
	for conf_coord in conflicts:
		conflict_edges.append_array(BloxPiece.calc_coord_edges_in_cells(conf_coord, new_cells))

	var bump_direction
	if (Vector2i.LEFT in conflict_edges and
		Vector2i.RIGHT in conflict_edges):
		# probably a vertical conflict
		# consider bumping up if something below us
		pass
	elif (Vector2i.LEFT in conflict_edges):
		bump_direction = Vector2i.RIGHT
	elif (Vector2i.RIGHT in conflict_edges):
		bump_direction = Vector2i.LEFT

	if not bump_direction:
		return [false, Vector2i()]

	# consider bumping multiple times, e.g. for tall rotations at the edge
	var bumped_cells: Array[Vector2i] = []
	for c in new_cells:
		bumped_cells.append(c + bump_direction)

	conflicts = calc_conflicts(bumped_cells, existing_cells)

	if conflicts.is_empty():
		return [true, bump_direction]

	return [false, Vector2i()]


## remove ################################################

func remove_at_coord(coord: Vector2i):
	var crd_to_piece = coords_to_piece_dict()
	var piece = crd_to_piece.get(coord)
	piece.remove_grid_coord(coord)

	if piece.is_empty():
		pieces.erase(piece)

## tetris ################################################

func apply_step_tetris(dir=Vector2i.DOWN) -> bool:
	# hmm i think we should do this bottom up and apply the fall right away
	# also there's probably interest in animating the change
	var to_fall = []
	for piece in pieces:
		var should_move = can_piece_move(piece, dir)
		if should_move:
			to_fall.append(piece)

	# drop them all at once
	# (this doesn't seem right, multi-piece stacks won't fall together)
	# maybe it's fine/a graphic?
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

func split_piece_coord(piece: BloxPiece, coord: Vector2i) -> void:
	piece.remove_grid_coord(coord)
	var new_p = BloxPiece.new({coord=coord, cells=[Vector2()]})
	add_piece(new_p)

# splits pieces apart based on room-to-fall beneath cells
func apply_split_puyo(dir=Vector2i.DOWN) -> bool:
	var crd_to_piece = coords_to_piece_dict()

	var to_fall = []
	var bottom_up = range(height)
	bottom_up.reverse()
	for y in bottom_up:
		for x in range(width):
			var crd = Vector2i(x, y)
			var p = crd_to_piece.get(crd)
			if not p:
				continue
			var p_below = crd_to_piece.get(crd + dir)
			if not p_below:
				continue

			# maybe don't split unless some other piece can't fall? or just split everything in puyo mode?

			if p.cell_count() > 1: # only split if more than one cell
				to_fall.append(crd)

	for crd in to_fall:
		var p = crd_to_piece.get(crd)
		split_piece_coord(p, crd)

	var did_move = not to_fall.is_empty()
	return did_move

# clear all same-color-4-touching coords
# return a list of the cleared groups, including how many blocks were cleared
func clear_groups() -> Array:
	Log.warn("clear_groups() not impled!")
	return []
