@tool
extends Resource
class_name BloxGrid

## vars ################################################

@export var width: int = 8
@export var height: int = 12

var pieces: Array[BloxPiece] = []

func to_pretty():
	return {width=width, height=height, pieces=pieces}

## init ################################################

func _init(opts={}):
	width = opts.get("width", width)
	height = opts.get("height", height)

func entry_coord() -> Vector2i:
	return Vector2i(floor(width/2.0) - 1, 0)

func clear():
	pieces = []

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
	for y in range(height):
		for x in range(width):
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

func can_piece_move(piece: BloxPiece, dir=Vector2i.DOWN, other_moving_cells=[]):
	var new_cells = piece.relative_coords(dir)
	var moving_cells = piece.grid_coords()
	moving_cells.append_array(other_moving_cells)
	var conflicts = calc_conflicts(new_cells, moving_cells, "movement")
	return conflicts.is_empty()

# returns true if the new_cell coords point to an existing piece
# the moving_cells are ignored - they may belong to the moving/rotating piece, or another already moving piece
# PERF could pass an optional early return flag
func calc_conflicts(new_cells: Array[Vector2i], moving_cells: Array[Vector2i], log_label="") -> Array[Vector2i]:
	var all_coords_dict = all_coords_as_dict()
	var conflicts: Array[Vector2i] = []

	for c in new_cells:
		if not c in all_coords_dict:
			# don't log this when we're just hitting the floor
			if not (c.y >= height and log_label == "movement"):
				Log.info("%s conflict with level boundary" % log_label, c)
			conflicts.append(c) # beyond coords of level
			# return true

	for c in new_cells:
		if c in moving_cells:
			continue # ignore existing cells (b/c they'll move out of the way)
		if all_coords_dict.get(c):
			# Log.info("%s conflict with existing cell" % log_label, c)
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
	var new_cells = piece.rotated_coords(dir)
	var existing_cells = piece.grid_coords()

	# bump/push away from edges/pieces to make the rotation fit
	var conflicts = calc_conflicts(new_cells, existing_cells, "rotation")

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

	conflicts = calc_conflicts(bumped_cells, existing_cells, "bump_rotation")

	if conflicts.is_empty():
		return [true, bump_direction]

	return [false, Vector2i()]


## remove ################################################

# removes a cell from a piece at the passed grid_coord.
# if the result is an empty piece, it is removed from the state pieces.
func remove_at_coord(coord: Vector2i) -> BloxCell:
	var crd_to_piece = coords_to_piece_dict()
	var piece = crd_to_piece.get(coord)
	if not piece:
		Log.error("cannot remove at coord, no piece here!")
		return
	var cell = piece.remove_coord(coord)

	if piece.is_empty():
		pieces.erase(piece)
	return cell

## tetris fall ################################################

func bottom_up_pieces(_dir: Vector2i) -> Array[BloxPiece]:
	# TODO use `dir` to go 'bottom-up' from any direction
	var ps: Array[BloxPiece] = []
	ps.assign(pieces)
	ps.sort_custom(func(pa, pb):
		return pa.get_max_y() > pb.get_max_y())
	return ps

func apply_step_tetris(dir=Vector2i.DOWN) -> bool:
	var falling_cells = []
	var to_fall = []
	for piece in bottom_up_pieces(dir):
		if can_piece_move(piece, dir, falling_cells):
			to_fall.append(piece)
			falling_cells.append_array(piece.grid_coords())

	for piece in to_fall:
		move_piece(piece, dir, true)

	var did_move = not to_fall.is_empty()
	return did_move

## tetris clear ################################################

# returns the number of rows that were cleared
func clear_rows() -> Array:
	var piece_dict = piece_coords_as_dict()
	var rows_cleared = []
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
			var cells = []
			# remove from each piece's cells
			for crd in row_crds:
				var cell = remove_at_coord(crd)
				if cell:
					cells.append(cell)
			rows_cleared.append(cells)

	return rows_cleared

## puyo split ################################################

func split_piece_coord(piece: BloxPiece, grid_coord: Vector2i) -> void:
	var cell = piece.remove_coord(grid_coord)
	# maintain the same cell object!
	var new_p = BloxPiece.new({grid_cells=[cell]})
	add_piece(new_p)

func coords_to_edge(coord: Vector2i, dir: Vector2i) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	match dir:
		Vector2i.DOWN:
			for y in range(coord.y, height):
				coords.append(Vector2i(coord.x, y))
		Vector2i.UP:
			for y in range(coord.y, 0):
				coords.append(Vector2i(coord.x, y))
		Vector2i.LEFT:
			for x in range(coord.x, 0):
				coords.append(Vector2i(x, coord.y))
		Vector2i.RIGHT:
			for x in range(coord.x, width):
				coords.append(Vector2i(x, coord.y))
	return coords


# splits pieces apart based on room-to-fall beneath cells
func apply_split_puyo(dir=Vector2i.DOWN) -> bool:
	var crd_to_piece = coords_to_piece_dict()

	var to_split = []

	for y in range(height):
		for x in range(width):
			var crd = Vector2i(x, y)
			var crds_to_split = []
			var should_split = false
			for crd_below in coords_to_edge(crd, dir):
				var p_below = crd_to_piece.get(crd_below)
				if p_below and p_below.cell_count() > 1: # only split if more than one cell
					if not crd in crds_to_split:
						crds_to_split.append(crd)
				elif not p_below:
					# no cell, mark split and stop collecting
					should_split = true
					break

			if should_split:
				to_split.append_array(crds_to_split)

	for crd in to_split:
		var p = crd_to_piece.get(crd)
		if not p:
			Log.error("Missing expected piece in apply_split_puyo", crd)
			continue
		split_piece_coord(p, crd)

	var did_split = not to_split.is_empty()
	return did_split

## puyo clear ################################################

# clear all same-color-4-touching coords
# return a list of the cleared groups, including how many blocks were cleared
func clear_groups(rules=null) -> Array:
	if not rules:
		rules = GridRules.new()
	var groups_cleared = []
	var crd_to_piece = coords_to_piece_dict()
	for crd in crd_to_piece.keys():
		var piece = crd_to_piece.get(crd)
		if not piece in pieces:
			continue # piece already removed (likely by remove_at_coord), skip it
		var color = piece.get_coord_color(crd)
		var group_coords = get_common_neighbors(crd, crd_to_piece,
			func(nbr_coord, nbr_piece): return nbr_piece.get_coord_color(nbr_coord) == color)
		if len(group_coords) >= rules.puyo_group_size:
			var group_cells = []
			for c in group_coords:
				crd_to_piece.erase(c)
				var cell = remove_at_coord(c)
				if cell:
					group_cells.append(cell)
			if not group_cells.is_empty():
				groups_cleared.append(group_cells)

	return groups_cleared

func get_common_neighbors(
		coord: Vector2i,
		crd_to_piece: Dictionary,
		# is_match: Callable[Vector2i, BloxPiece, bool],
		is_match: Callable,
		collected=null,
	):
	if not collected:
		collected = []
	if not coord in collected:
		collected.append(coord)

	var new_nbrs = []

	var nbrs = neighbor_coords(coord).filter(
		# don't check any neighbors we've already visited
		func(crd): return not crd in collected)
	for nbr in nbrs:
		var nbr_p = crd_to_piece.get(nbr)
		if nbr_p:
			if is_match.call(nbr, nbr_p):
				new_nbrs.append(nbr)

	# NOTE changing collected IN-PLACE!
	collected.append_array(new_nbrs)

	for nbr in new_nbrs:
		# NOTE changes 'collected' IN-PLACE!
		get_common_neighbors(nbr, crd_to_piece, is_match, collected)

	return collected

func neighbor_coords(coord: Vector2i):
	return [
		coord + Vector2i.UP,
		coord + Vector2i.DOWN,
		coord + Vector2i.LEFT,
		coord + Vector2i.RIGHT,
		]

## step/tick ################################################

const STATE_SETTLING="state_settled"
const STATE_FALLING="state_falling"
const STATE_SPLITTING="state_splitting"
const STATE_CLEARING="state_clearing"

signal on_update(state)
signal on_pieces_split()
signal on_groups_cleared(groups)
signal on_rows_cleared(rows)

# Steps the grid through the game logic
# returns true if anything changed
# (in which case this should likely be called again soon)
func step(opts={}) -> bool:
	# TODO refactor: separate _what_ to do from _doing_ it

	var rules: GridRules
	if opts is Dictionary:
		rules = GridRules.new(opts)
	elif opts is GridRules:
		rules = opts
	else:
		Log.warn("Unexpected step()/GridRules input!", opts)

	# move everything that can one step, if possible
	if apply_step_tetris(rules.step_direction):
		on_update.emit(STATE_FALLING)
		return true

	# puyo piece split
	if rules.puyo_split and apply_split_puyo(rules.step_direction):
		# TODO include pieces
		on_pieces_split.emit()
		on_update.emit(STATE_SPLITTING)
		return true

	# clear groups AND rows together
	var did_clear = false

	# puyo same-color group clear
	if rules.puyo_group_clear:
		var groups = clear_groups(rules)
		if not groups.is_empty():
			Log.info("cells cleared", groups.map(func(xs): return len(xs)))
			did_clear = true
			on_groups_cleared.emit(groups)

	# tetris row clear
	if rules.tetris_row_clear:
		var rows = clear_rows()
		if not rows.is_empty():
			Log.info("rows cleared", len(rows))
			did_clear = true
			on_rows_cleared.emit(rows)

	if did_clear:
		on_update.emit(STATE_CLEARING)
		return true

	# all settled, ready for next piece
	on_update.emit(STATE_SETTLING)
	return false
