extends Resource
class_name GridRules

## vars ##########################################

@export var puyo_split: bool = false
@export var puyo_group_clear: bool = false
@export var puyo_group_size: int = 4
@export var tetris_row_clear: bool = false
@export var step_direction: Vector2i = Vector2i.DOWN

# maybe colors/shapes?

func to_pretty():
	return {
		step_direction=step_direction,
		puyo_split=puyo_split,
		puyo_group_clear=puyo_group_clear,
		puyo_group_size=puyo_group_size,
		tetris_row_clear=tetris_row_clear,
		}

## validate ##########################################

func validate_opts(opts: Dictionary):
	var fields = [
		"step_direction",
		"puyo_split",
		"puyo_group_clear", "puyo_group_size",
		"tetris_row_clear",
		]
	var other_opts = opts.keys().filter(func(k): return not k in fields)
	if not other_opts.is_empty():
		Log.warn("Unexpected opts passed to GridRules", other_opts)

## init ##########################################

func _init(opts={}):
	if not opts:
		opts = {}
	validate_opts(opts)
	step_direction = opts.get("step_direction", step_direction)
	puyo_split = opts.get("puyo_split", puyo_split)
	puyo_group_clear = opts.get("puyo_group_clear", puyo_group_clear)
	puyo_group_size = opts.get("puyo_group_size", puyo_group_size)
	tetris_row_clear = opts.get("tetris_row_clear", tetris_row_clear)

# maybe a merge helper to support this as a monoid
