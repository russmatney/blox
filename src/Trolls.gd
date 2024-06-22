@tool
extends Node
class_name Trolls

## public #################################################################

static func is_event(event, event_name):
	return event.is_action_pressed(event_name)

static func is_pressed(event, event_name):
	return is_event(event, event_name)

static func is_held(event, event_name):
	return is_event(event, event_name)

static func is_released(event, event_name):
	return event.is_action_released(event_name)

# returns a normalized Vector2 based on the controller's movement
static func move_vector():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

# useful for discrete joystick inputs
static func grid_move_vector(thresh=0.6):
	var move = move_vector()
	if move.x > thresh:
		return Vector2.RIGHT
	elif move.x < -1*thresh:
		return Vector2.LEFT
	elif move.y < -1*thresh:
		return Vector2.UP
	elif move.y > thresh:
		return Vector2.DOWN
	return Vector2.ZERO

static func is_move(event):
	return is_event(event, "ui_left") or is_event(event, "ui_right") or \
		is_event(event, "ui_up") or is_event(event, "ui_down")

static func is_move_released(event):
	return is_released(event, "ui_left") or is_released(event, "ui_right") or \
		is_released(event, "ui_up") or is_released(event, "ui_down")

static func is_move_up(event):
	return is_event(event, "ui_up")

static func is_move_down(event):
	return is_event(event, "ui_down")

static func is_move_left(event):
	return is_event(event, "ui_left")

static func is_move_right(event):
	return is_event(event, "ui_right")


static func is_accept(event):
	return is_event(event, "ui_accept")

static func is_undo(event):
	return is_event(event, "ui_undo")

static func is_pause(event):
	return is_event(event, "pause")

static func is_close(event):
	return is_event(event, "close")

static func is_close_released(event):
	return is_released(event, "close")
