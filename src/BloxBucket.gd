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

# TODO use GridRules
var rule_inputs = {
	step_direction=Vector2i.DOWN,
	puyo_split=true,
	tetris_row_clear=true,
	puyo_group_clear=true,
	}

var next_tick_in = 0
var auto_ticking = true
var stuck = false
var action_queue = []

signal user_move_complete
signal fall_complete
signal clear_complete
signal split_complete

var grid_state

signal piece_added

func to_pretty():
	return {grid=grid}

## ready ################################################

func _ready():
	render_grid_cell_bg()

	if Engine.is_editor_hint():
		return

	grid.on_update.connect(on_grid_update)

	grid.on_pieces_split.connect(func():
		action_queue.append(on_pieces_split))
	grid.on_groups_cleared.connect(func(groups):
		action_queue.append(on_groups_cleared.bind(groups)))
	grid.on_rows_cleared.connect(func(rows):
		action_queue.append(on_rows_cleared.bind(rows)))

	user_move_complete.connect(do_next_action)
	fall_complete.connect(do_next_action)
	clear_complete.connect(do_next_action)
	split_complete.connect(do_next_action)

	(func():
		start_next_piece()
		resume_auto_ticking()).call_deferred()

## input ################################################

func _input(event):
	# TODO holding to apply multiple times doesn't work rn!!
	if current_piece:

		var did_move
		if Trolls.is_move_right(event):
			did_move = grid.move_piece(current_piece, Vector2i.RIGHT)
		if Trolls.is_move_left(event):
			did_move = grid.move_piece(current_piece, Vector2i.LEFT)
		if Trolls.is_move_down(event):
			did_move = grid.move_piece(current_piece, Vector2i.DOWN)
		if Trolls.is_move_up(event):
			# move up twice as a simple tick-down counter
			did_move = grid.move_piece(current_piece, Vector2i.UP)
			grid.move_piece(current_piece, Vector2i.UP)
		if did_move:
			user_moved_piece({time=0.2})
			return

		var did_rotate
		if Trolls.is_accept(event):
			did_rotate = grid.rotate_piece(current_piece, Vector2i.RIGHT)
		elif Trolls.is_undo(event):
			did_rotate = grid.rotate_piece(current_piece, Vector2i.LEFT)
		if did_rotate:
			user_moved_piece({time=0.2})


		else:
			pass
			# TODO sound effect for move/hitwall/rotate

## process ################################################

func _process(delta):
	if stuck:
		return
	next_tick_in -= delta

	# never auto-tick unless there's a current_piece
	# i.e. we control 'time' when the user has no control
	if (current_piece and auto_ticking and next_tick_in <= 0):
		tick()
		next_tick_in = tick_every

## tick ################################################

func maybe_tick():
	if current_piece:
		# tick at next tick_every
		resume_auto_ticking()
	else:
		# tick immediately
		tick()

func tick():
	if add_piece_on_tick:
		add_piece_on_tick = false
		start_next_piece()
		resume_auto_ticking()
		return

	# step the grid forward
	var any_change = grid.step(rule_inputs)

	if any_change:
		# this eventually fires 'do_next_action' (after any animation)
		update_piece_positions()
	else:
		# no change! attempt action, start new piece, or tick again until we're ready
		do_next_action()

func pause_auto_ticking():
	auto_ticking = false

func resume_auto_ticking():
	auto_ticking = true

var add_piece_on_tick = false
func add_piece_next_tick():
	add_piece_on_tick = true

## on grid update ################################################

func do_next_action():
	if action_queue.is_empty():
		if grid_state == BloxGrid.STATE_SETTLING:
			if not current_piece:
				add_piece_next_tick()
		maybe_tick()
		return

	var ax = action_queue.pop_front()
	ax.call()

func on_grid_update(state):
	grid_state = state

	# pause ticking completely (other signals will eventually resume it)
	pause_auto_ticking()

	match (state):
		BloxGrid.STATE_SPLITTING, BloxGrid.STATE_CLEARING, BloxGrid.STATE_SETTLING:
			# clear to prevent any user action
			current_piece = null
		_: pass

## reset ################################################

func restart():
	clear_pieces()
	reset_color_rect_map()
	grid.clear()

	piece_queue = []
	stuck = false

	start_next_piece()
	resume_auto_ticking()

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

func on_pieces_split():
	var tween = create_tween()
	tween.tween_callback(func(): split_complete.emit()).set_delay(0.3)

## on cells cleared ################################################

func on_groups_cleared(groups: Array):
	Log.pr("group cleared", groups)
	var t = 0.3
	var tween = create_tween()
	var rects = []
	for cells in groups:
		for color_rect in get_color_rects(cells):
			Log.pr("tweening color rect", color_rect)
			tween.parallel().tween_property(color_rect, "color", Color.WHITE, t)
			rects.append(color_rect)
		clear_color_rects(cells)

	tween.tween_callback(func():
		for color_rect in rects:
			color_rect.queue_free()
		clear_complete.emit())

## on rows cleared ################################################

func on_rows_cleared(rows: Array):
	Log.pr("rows cleared", rows)
	var tween = create_tween()
	var t = 0.3
	var rects = []
	for cells in rows:
		for color_rect in get_color_rects(cells):
			rects.append(color_rect)
			tween.parallel().tween_property(color_rect, "color", Color.WHITE, t)
		clear_color_rects(cells)

	tween.tween_callback(func():
		clear_complete.emit()
		for color_rect in rects:
			color_rect.queue_free())

## start_next_piece ################################################

func start_next_piece():
	if current_piece:
		Log.warn("already have a current_piece!?")

	if len(piece_queue) < 4:
		queue_pieces()

	current_piece = piece_queue.pop_front()
	if current_piece == null:
		Log.warn("No piece found! aborting start_next_piece")
		return

	Log.info("Starting next piece", current_piece)
	current_piece.set_root_coord(grid.entry_coord())
	var can_add = grid.can_add_piece(current_piece)
	if can_add:
		grid.add_piece(current_piece, true)
		piece_added.emit()
	else:
		stuck = true
		Log.info("Stuck! game over!!")

## queue_pieces ################################################

func queue_pieces(count=7):
	# TODO proper tetris shuffle
	# TODO cell color distribution
	# TODO pull pieces/colors from options/game-mode/unlocks/etc
	for i in range(count):
		var p = BloxPiece.random()
		piece_queue.append(p)

func get_piece_queue() -> Array[BloxPiece]:
	return piece_queue

func next_piece() -> BloxPiece:
	if piece_queue.is_empty():
		Log.warn("No next piece!")
		return BloxPiece.new()
	return piece_queue[0]

## render cell backgrounds ################################################

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

## render pieces/cells ################################################

func clear_pieces():
	for ch in get_children():
		if ch.is_in_group(PIECE_CELL_GROUP):
			ch.free()

var piece_cell_size_factor = 0.8

func coord_to_cell_position(coord: Vector2i) -> Vector2:
	var cell_size_adj = cell_size * (1 - piece_cell_size_factor)
	return Vector2(coord) * cell_size + (cell_size_adj/2.0)

func piece_cell_size() -> Vector2:
	var cell_size_adj = cell_size * (1 - piece_cell_size_factor)
	return cell_size - cell_size_adj

var piece_position_tween

func update_piece_positions():
	if piece_position_tween:
		piece_position_tween.kill()
	piece_position_tween = create_tween()

	var t
	if current_piece:
		t = 0.2
	else:
		t = 0.1

	# TODO only move pieces that have moved!?!?
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

				cr.size = piece_cell_size()

				add_child.call_deferred(cr)

			var new_pos = coord_to_cell_position(coord)

			# fall farther if we're just entering the scene
			if cr.position == Vector2():
				cr.position = new_pos + Vector2.UP * cell_size * 3
			piece_position_tween.parallel().tween_property(cr, "position", new_pos, t)

			cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
	piece_position_tween.tween_callback(func(): fall_complete.emit())

func user_moved_piece(opts={}):
	if not current_piece:
		return

	if piece_position_tween:
		piece_position_tween.kill()
	piece_position_tween = create_tween()
	var t = opts.get("time", 0.3)

	for cell in current_piece.get_grid_cells():
		var coord = cell.coord
		var cr = cell_id_to_rect.get(cell.get_instance_id())
		if not cr:
			Log.warn("User attempted to move piece without a rect!", cell)
			return

		var new_pos = coord_to_cell_position(coord)
		piece_position_tween.parallel().tween_property(cr, "position", new_pos, t)

		cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
	piece_position_tween.tween_callback(func(): user_move_complete.emit())
