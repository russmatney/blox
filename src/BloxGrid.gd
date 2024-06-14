@tool
extends Resource
class_name BloxGrid

## vars ################################################

@export var width: int = 6
@export var height: int = 10

func to_pretty():
	return {width=width, height=height}

## init ################################################

func _init(opts={}):
	width = opts.get("width", width)
	height = opts.get("height", height)

## coords ################################################

## returns a list of Vector2i

func coords() -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			ret.append(Vector2i(x, y))
	return ret

## returns a list of Vector2i

func as_dict() -> Dictionary:
	var ret = {}
	for coord in coords():
		ret[coord] = true
	return ret
