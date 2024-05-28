extends Node

class_name Wave

@export var num_enemies = 3
@export var seconds_between_spawns: float = 2
@export var DropItem: PackedScene
@export var drop_chance = 1.0
@export var drop_when = 0.5 #en que punto de la ola dropea un arma

var drop_completed = false
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func should_drop(enemies_killed_this_wave):
	if DropItem:
		var fraction_killed = float(enemies_killed_this_wave) / num_enemies
		if fraction_killed >= drop_when and not drop_completed:
			if rng.randf() <= drop_chance:
				drop_completed = true
				return true
		
	return false
