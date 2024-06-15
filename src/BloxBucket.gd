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
			# TODO sound effect for move/hitwall/rotate
			pass

	# TODO move to some signal that listens on clicks
	# if event is InputEventMouseButton:
	# 	if not event.pressed and event.button_index == 1:
	# 		Log.pr("mouse click!")
	# 		grid.apply_step_tetris()
	# 		render()


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
	for i in range(count):
		var p = BloxPiece.random()
		piece_queue.append(p)

## tick ################################################

var tick_every = 0.4
func tick():
	await get_tree().create_timer(tick_every).timeout

	var did_change = grid.apply_step_tetris()
	render()

	if did_change:
		tick()
	else:
		# TODO puyo rules: groups to clear? pieces to split/fall?

		var ct = grid.clear_rows()
		if ct > 0:
			# TODO row-clear animation/sound
			pass

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

	var size_diff = Vector2.ONE * 4
	for coord in grid.all_coords():
		var cr = ColorRect.new()
		cr.color = Color.GRAY
		cr.position = Vector2(coord) * cell_size + size_diff/2.0
		cr.size = cell_size - size_diff
		cr.name = "BucketCell-%s-%s" % [coord.x, coord.y]
		cr.add_to_group(BUCKET_CELL_GROUP)
		add_child(cr)

func render_pieces():
	for ch in get_children():
		if ch.is_in_group(PIECE_CELL_GROUP):
			ch.free()

	var size_diff = Vector2.ONE * 2
	for piece in grid.pieces:
		for coord in piece.grid_coords():
			var cr = ColorRect.new()
			cr.color = piece.color
			cr.position = Vector2(coord) * cell_size + (size_diff/2.0)
			cr.size = cell_size - size_diff
			cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
			cr.add_to_group(PIECE_CELL_GROUP)
			add_child(cr)
