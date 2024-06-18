@tool
extends Node2D

## vars ################################################

@export var grid: BloxGrid
@export var cell_size = Vector2.ONE * 32

const BUCKET_CELL_GROUP="bucket_cells"
const PIECE_CELL_GROUP="piece_cells"

var piece_queue: Array[BloxPiece] = []
var current_piece

func to_pretty():
	return {grid=grid}

## ready ################################################

func _ready():
	Log.pr("I'm ready!", self)

	# shuffle next-pieces
	queue_pieces(7)
	render()
	start_next_piece()

	if Engine.is_editor_hint():
		request_ready()

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
	current_piece = piece_queue.pop_front()
	if current_piece == null:
		Log.warn("No piece found! aborting start_next_piece")
		return

	current_piece.set_initial_coord(grid.entry_coord())
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
	for i in range(count):
		var p = BloxPiece.random()
		piece_queue.append(p)

## tick ################################################

var tick_every = 0.4
# TODO flags for game logic
# - compose from current jokers/fathers/characters
func tick():
	await get_tree().create_timer(tick_every).timeout

	var did_step = grid.apply_step_tetris()

	# puyo split - if any splits, need to apply_step_tetris after splitting so other cells fall
	var did_split = false
	if not did_step:
		did_split = grid.apply_split_puyo()

	if did_step or did_split:
		render()
		tick()
		return # wait to clear until we're all settled

	var did_clear = false

	# puyo clear
	var groups = grid.clear_groups()
	if not groups.is_empty():
		did_clear = true
		# TODO group-clear animation/sound

	# tetris clear
	var ct = grid.clear_rows()
	if ct > 0:
		did_clear = true
		# TODO row-clear animation/sound

	if did_clear:
		render()
		tick()
		return # wait to queue/next-piece until we're all settled

	render()

	if len(piece_queue) < 4:
		queue_pieces()
	start_next_piece()

## render ################################################

func render():
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
		cr.color = Color.DIM_GRAY if i % 2 == 0 else Color.DARK_GRAY
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
		for coord in piece.grid_coords():
			var cr = ColorRect.new()
			cr.color = piece.color
			var cell_size_adj = cell_size * (1 - size_factor)
			cr.position = Vector2(coord) * cell_size + (cell_size_adj/2.0)
			cr.size = cell_size - cell_size_adj
			cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
			cr.add_to_group(PIECE_CELL_GROUP)
			add_child(cr)
