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

var cell_id_to_rect = {}

signal board_settled

func to_pretty():
	return {grid=grid}

## ready ################################################

func _ready():
	render_grid_cell_bg()

	if Engine.is_editor_hint():
		return

	grid.on_update.connect(on_grid_update)
	grid.on_groups_cleared.connect(on_groups_cleared)
	grid.on_rows_cleared.connect(on_rows_cleared)
	board_settled.connect(start_next_piece, CONNECT_DEFERRED)

	render()
	start_next_piece()

## reset ################################################

func restart():
	clear_pieces()
	piece_queue = []
	reset_color_rect_map()
	grid.clear()
	render()
	start_next_piece()

## dimensions ################################################

func bucket_rect() -> Rect2:
	var r = Rect2()
	r.position = position
	r.size = Vector2(grid.width, grid.height) * cell_size
	return r

func bucket_center() -> Vector2:
	var r = bucket_rect()
	return r.get_center()

## cell to rects ################################################

func reset_color_rect_map():
	cell_id_to_rect = {}

func clear_color_rects(cells):
	for c in cells:
		# when do the cells get freed?
		cell_id_to_rect.erase(c.get_instance_id())

func get_color_rects(cells) -> Array[ColorRect]:
	var rects: Array[ColorRect] = []
	for c in cells:
		var rect = cell_id_to_rect.get(c.get_instance_id())
		if not rect:
			Log.pr("no rect found for cell", c)
		else:
			rects.append(rect)
	return rects

## on cells cleared ################################################

func on_groups_cleared(groups: Array):
	Log.pr("group cleared", groups)
	var t = 1.5
	for cells in groups:
		anim_cell_group_clear(cells, t)

func anim_cell_group_clear(cells, t=0.5):
	var tween = create_tween()
	var rects = []
	for color_rect in get_color_rects(cells):
		Log.pr("tweening color rect", color_rect)
		tween.parallel().tween_property(color_rect, "color", Color.WHITE, t)
		rects.append(color_rect)

	clear_color_rects(cells)

	for color_rect in rects:
		tween.tween_callback(func():
			color_rect.queue_free()
			resume_ticking()
			)

## on rows cleared ################################################

func on_rows_cleared(rows: Array):
	Log.pr("rows cleared", rows)
	var tween = create_tween()
	var t = 0.5
	var rects = []
	for cells in rows:
		for color_rect in get_color_rects(cells):
			rects.append(color_rect)
			tween.parallel().tween_property(color_rect, "color", Color.WHITE, t)
		clear_color_rects(cells)

	for color_rect in rects:
		tween.tween_callback(func():
			color_rect.queue_free()
			resume_ticking()
			)


## on grid update ################################################

var grid_state

func on_grid_update(state):
	# clear current_piece when it lands on something
	# this will prevent 'controlling' the parts after splits
	Log.pr("grid update", state)
	grid_state = state
	match (state):
		BloxGrid.STATE_SETTLED:
			current_piece = null # when settled, no current piece
			render()
			resume_ticking()
		BloxGrid.STATE_SPLITTING:
			current_piece = null # on first split, prevent more movement control
			render()
			pause_ticking()
			tick()
		BloxGrid.STATE_CLEARING:
			current_piece = null # if clearing, no current piece
			render()
			pause_ticking()
		BloxGrid.STATE_FALLING:
			resume_ticking()
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

## process ################################################

# grid_state in [
# 	BloxGrid.STATE_FALLING,
# 	BloxGrid.STATE_SPLITTING,
# 	BloxGrid.STATE_CLEARING,
# 	]

var next_tick_in = 0
var ticking = true

func pause_ticking():
	ticking = false
	next_tick_in = 0

func resume_ticking():
	ticking = true

func _process(delta):
	next_tick_in -= delta

	# consider checking board state
	if (ticking and next_tick_in <= 0):
		tick()
		next_tick_in = tick_every

## tick ################################################

func tick():
	var any_change = grid.step({
		step_direction=Vector2i.DOWN,
		puyo_split=true,
		tetris_row_clear=true,
		puyo_group_clear=true,
		})

	if not any_change:
		# i.e. ready for next piece
		board_settled.emit()

## render ################################################

# should call this whenever grid size changes
func render_grid_cell_bg():
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

func render():
	if not is_inside_tree():
		return

	render_pieces()

func clear_pieces():
	for ch in get_children():
		if ch.is_in_group(PIECE_CELL_GROUP):
			ch.free()

func render_pieces():
	var size_factor = 0.8
	for piece in grid.pieces:
		for cell in piece.get_grid_cells():

			var coord = cell.coord
			var cr = cell_id_to_rect.get(cell.get_instance_id())
			if not cr:
				cr = ColorRect.new()
				cr.add_to_group(PIECE_CELL_GROUP, true)
				cell_id_to_rect[cell.get_instance_id()] = cr

				if cell.color:
					cr.color = cell.color
				else:
					cr.color = piece.color

				add_child.call_deferred(cr)

			var cell_size_adj = cell_size * (1 - size_factor)
			var new_pos = Vector2(coord) * cell_size + (cell_size_adj/2.0)
			var new_size = cell_size - cell_size_adj

			# tween movement
			if cr.position == Vector2():
				cr.position = new_pos + Vector2.UP * cell_size * 3
			var tween = create_tween()
			tween.tween_property(cr, "position", new_pos, tick_every)
			tween.parallel().tween_property(cr, "size", new_size, tick_every)

			cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
