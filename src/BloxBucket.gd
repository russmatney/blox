@tool
extends Node2D

## vars ################################################

@export var grid: BloxGrid
@export var cell_size = Vector2.ONE * 32

const BUCKET_CELL_GROUP="bucket_cells"
const PIECE_CELL_GROUP="piece_cells"

func to_pretty():
	return {grid=grid}

## ready ################################################

func _ready():
	Log.pr("I'm ready!", self)

	render()

## input ################################################

func _input(event):
	# TODO move to some signal that listens on clicks
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == 1:
			Log.pr("mouse click!")
			grid.apply_step_tetris()
			render()


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
		var color = random_piece_color()
		for coord in piece.grid_coords():
			var cr = ColorRect.new()
			cr.color = color
			cr.position = Vector2(coord) * cell_size + (size_diff/2.0)
			cr.size = cell_size - size_diff
			cr.name = "PieceCell-%s-%s" % [coord.x, coord.y]
			cr.add_to_group(PIECE_CELL_GROUP)
			add_child(cr)

func random_piece_color():
	return [Color.PERU, Color.AQUAMARINE, Color.CRIMSON,
		Color.CORAL, Color.TEAL, Color.TOMATO,
		].pick_random()
