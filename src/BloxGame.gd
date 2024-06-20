extends Node2D

## vars #############################################

@onready var bucket: BloxBucket = $BloxBucket
@onready var camera: Camera2D = $Camera2D

var grid: BloxGrid

## ready #############################################

func _ready():
	grid = bucket.grid

	camera.offset = bucket.bucket_center()
