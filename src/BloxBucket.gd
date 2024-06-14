@tool
extends Node2D

## vars ################################################

@export var grid: BloxGrid

func to_pretty():
	return {grid=grid}


## ready ################################################

func _ready():
	Log.pr("I'm ready!", self)
