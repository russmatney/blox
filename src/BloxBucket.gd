@tool
extends Node2D
class_name BloxBucket

## vars ################################################

@export var grid: BloxGrid
@export var cell_size = Vector2.ONE * 32

const BUCKET_CELL_GROUP="bucket_cells"
const PIECE_CELL_GROUP="piece_cells"

var piece_queue: Array[BloxPiece] = []
var current_piece
var tick_every = 0.4

signal board_settled

func to_pretty():
	return {grid=grid}

## ready ################################################

func _ready():
	grid.on_update.connect(on_grid_update)
	grid.on_cells_cleared.connect(on_cells_cleared)
	grid.on_rows_cleared.connect(on_rows_cleared)
	board_settled.connect(start_next_piece, CONNECT_DEFERRED)

	render()
	start_next_piece()

	if Engine.is_editor_hint():
		request_ready()

## on cells cleared ################################################

func on_cells_cleared(cell_groups: Array):
	Log.pr("cells cleared", cell_groups)
	# TODO sound
	# TODO animation
	# TODO score?

## on rows cleared ################################################

func on_rows_cleared(rows: Array):
	Log.pr("rows cleared", rows)
	# TODO animate the rows grouping and leaving

## on grid update ################################################

func on_grid_update(state):
	# TODO clear current_piece when it lands on something
	# this will prevent controling the parts after the split
	Log.pr("grid update", state)
	match (state):
		BloxGrid.STATE_SETTLED:
			current_piece = null # when settled, no current piece
			render()
		BloxGrid.STATE_SPLITTING:
			current_piece = null # on first split, prevent more movement control
			render()
		BloxGrid.STATE_CLEARING:
			current_piece = null # if clearing, no current piece
			render()
		BloxGrid.STATE_FALLING:
			if current_piece:
				render()

## input ################################################

func _input(event):
	# TODO holding to apply multiple times doesn't work rn!!
	if current_piece:
		var did_move
		var did_rotate
		if Trolls.is_move_right(event):
			did_move = grid.move_piece(current_piece, Vector2i.RIGHT)
		if Trolls.is_move_left(event):
			did_move = grid.move_piece(current_piece, Vector2i.LEFT)

		if Trolls.is_move_up(event):
			did_rotate = grid.rotate_piece(current_piece, Vector2i.RIGHT)

		if did_move or did_rotate:
			render()
			# TODO sound effect for move/hitwall/rotate

## start_next_piece ################################################

func start_next_piece():
	if len(piece_queue) < 4:
		queue_pieces()

	current_piece = piece_queue.pop_front()
	if current_piece == null:
		Log.warn("No piece found! aborting start_next_piece")
		return

	current_piece.set_root_coord(grid.entry_coord())
	var can_add = grid.can_add_piece(current_piece)
	if can_add:
		Log.info("Adding next piece!", current_piece)
		grid.add_piece(current_piece, true)
		tick()
	else:
		Log.info("Stuck! game over!!")

## queue_pieces ################################################

func queue_pieces(count=7):
	# TODO proper tetris shuffle
	# TODO cell color distribution
	# TODO pull pieces/colors from options/game-mode/unlocks/etc
	for i in range(count):
		var p = BloxPiece.random()
		piece_queue.append(p)

## tick ################################################

func tick():
	if current_piece and tick_every > 0.0:
		await get_tree().create_timer(tick_every).timeout

	if grid.step({
			direction=Vector2i.DOWN,
			puyo_split=true,
			tetris_row_clear=true,
			puyo_group_clear=true,
			}):
		tick()
		return

	# i.e. ready for next piece
	board_settled.emit()

## render ################################################

func render():
	if not is_inside_tree():
		return
	Log.info("rendering")

	render_bucket_cells()
	render_pieces()

func render_bucket_cells():
	for ch in get_children():
		if ch.is_in_group(BUCKET_CELL_GROUP):
			ch.free()

	var size_factor = 0.2
	var all_coords = grid.all_coords()
	for i in range(len(all_coords)):
		var coord = all_coords[i]
		var cr = ColorRect.new()
		match (i % 3):
			1: cr.color = Color.DARK_GRAY
			2: cr.color = Color.DIM_GRAY
			_: cr.color = Color.GRAY
		var cell_size_adj = cell_size * (1 - size_factor)
		cr.position = Vector2(coord) * cell_size + (cell_size_adj/2.0)
		cr.size = cell_size - cell_size_adj
		cr.name = "BucketCell-%s-%s" % [coord.x, coord.y]
		cr.add_to_group(BUCKET_CELL_GROUP)
		add_child(cr)

func render_pieces():
	for ch in get_children():
		if ch.is_in_group(PIECE_CELL_GROUP):
			ch.free()

	var size_factor = 0.8
	for piece in grid.pieces:
		for cell in piece.get_grid_cells():
			var coord = cell.coord
			var cr = ColorRect.new()
			if cell.color:
				cr.color = cell.color
			else:
				cr.color = piece.color
			var cell_size_adj = cell_size * (1 - size_factor)
			cr.position = Vector2(coord) * cell_size + (cell_size_adj/2.0)
			cr.size = cell_size - cell_size_adj
			cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
			cr.add_to_group(PIECE_CELL_GROUP)
			add_child(cr)
