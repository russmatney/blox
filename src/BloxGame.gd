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

@onready var piece_queue: GridContainer = $%PieceQueueGridContainer

## ready #############################################

func _ready():
	grid = bucket.grid

	grid.on_groups_cleared.connect(func(groups):
		for cells in groups:
			add_to_score_label(len(cells)))
	grid.on_rows_cleared.connect(func(rows):
		for cells in rows:
			add_to_score_label(len(cells)))

	bucket_margin_container.set_custom_minimum_size(
		Vector2.RIGHT * bucket.bucket_rect().size.x +
		Vector2.RIGHT * bucket_margin)

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
	score_label.set_text("[center]Blocks: %s[/center]" % score)
