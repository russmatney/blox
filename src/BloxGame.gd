extends Node

## vars #############################################

@onready var bucket: BloxBucket = $BloxBucket
@onready var camera: Camera2D = $Camera2D
var grid: BloxGrid

@onready var bucket_margin_container: MarginContainer = $%BucketMarginContainer
var bucket_margin = 64

@onready var restart_button: Button = $%RestartButton

@onready var score_label: RichTextLabel = $%ScoreLabel
var score = 0

@onready var next_piece_grid: GridContainer = $%PieceQueueGridContainer

@onready var crtv_effect = $%CRTVEffect

## ready #############################################

func _ready():
	grid = bucket.grid

	grid.on_groups_cleared.connect(func(groups):
		for cells in groups:
			add_to_score_label(len(cells))
		# TODO crtv_effect abberation tween
		)
	grid.on_rows_cleared.connect(func(rows):
		for cells in rows:
			add_to_score_label(len(cells)))

	bucket_margin_container.set_custom_minimum_size(
		Vector2.RIGHT * bucket.bucket_rect().size.x +
		Vector2.RIGHT * bucket_margin)

	bucket.piece_added.connect(on_piece_added, CONNECT_DEFERRED)

	camera.offset = bucket.bucket_center()

	restart_button.pressed.connect(func():
		Log.info("restart pressed!")
		reset_score_label()
		bucket.restart())

	start_game()

## start game #############################################

func start_game():
	reset_score_label()

## score #############################################

func reset_score_label():
	score = 0
	update_score_label()

func add_to_score_label(n: int):
	score += n
	update_score_label()

func update_score_label():
	var lbl = score
	if score < 10:
		lbl = "00%s" % score
	if score < 100:
		lbl = "0%s" % score
	score_label.set_text("[center]%s[/center]" % lbl)

## on_piece_added ####################################

func on_piece_added():
	update_next_piece_grid()

var piece_cell_size_factor = 0.8
func coord_to_cell_position(coord: Vector2i) -> Vector2:
	var cell_size_adj = bucket.cell_size * (1 - piece_cell_size_factor)
	return Vector2(coord) * bucket.cell_size + (cell_size_adj/2.0)

func piece_cell_size() -> Vector2:
	var cell_size_adj = bucket.cell_size * (1 - piece_cell_size_factor)
	return bucket.cell_size - cell_size_adj

func update_next_piece_grid():
	for ch in next_piece_grid.get_children():
		next_piece_grid.remove_child(ch)
		ch.queue_free()

	var piece_queue = bucket.get_piece_queue()

	for i in range(0, min(len(piece_queue), 1)):
		var piece = piece_queue[i]

		var piece_container = Node2D.new()

		for cell in piece.get_grid_cells():
			var coord = cell.coord
			var cr = ColorRect.new()

			cr.color = cell.color
			cr.size = bucket.piece_cell_size()
			cr.position = bucket.coord_to_cell_position(coord)

			piece_container.add_child(cr)
		next_piece_grid.add_child(piece_container)
