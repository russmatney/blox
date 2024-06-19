@tool
extends Resource
class_name BloxCell

## static ############################

# TODO probably configurable/set by some theme
static func random_cell_color():
	return [Color.PERU, Color.AQUAMARINE, Color.CRIMSON,
		# Color.CORAL, Color.TEAL, Color.TOMATO,
		].pick_random()

## vars ############################

@export var coord: Vector2i
@export var color: Color

func to_pretty():
	return {coord=coord, color=color}

## init ############################

func _init(opts={}):
	coord = opts.get("coord", Vector2i())

	if opts.get("color"):
		color = opts.get("color")
	else:
		color = BloxCell.random_cell_color()
