extends Node

class_name Stats

@export var max_HP = 2
@onready var current_HP = max_HP

var dead = false

signal dead_signal
signal update_health

func take_hit(damage):
	current_HP -= damage
	emit_signal("update_health", current_HP)
	
	if current_HP <= 0 and not dead:
		die()
		
func die():
	dead = true
	emit_signal("dead_signal")
	

