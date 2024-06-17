@tool
extends Resource
class_name BloxCell

@export var coord: Vector2i
@export var color: Color

func to_pretty():
	return {coord=coord, color=color}

func _init(opts={}):
	coord = opts.get("coord")
	color = opts.get("color")
