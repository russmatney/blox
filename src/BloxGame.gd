extends Node

## vars #############################################

@onready var bucket: BloxBucket = $BloxBucket
@onready var camera: Camera2D = $Camera2D

@onready var bucket_margin_container: MarginContainer = $%BucketMarginContainer
var bucket_margin = 64

var grid: BloxGrid

## ready #############################################

func _ready():
	grid = bucket.grid

	bucket_margin_container.set_custom_minimum_size(
		Vector2.RIGHT * bucket.bucket_rect().size.x +
		Vector2.RIGHT * bucket_margin)

	camera.offset = bucket.bucket_center()
