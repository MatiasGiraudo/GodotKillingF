extends Node3D

@export var enemy: PackedScene
@onready var timer = $Timer

# Lista de waves totales
var waves 
# Wave actual
var current_wave: Wave 
var enemies_remaining_to_spawn
var enemies_killed_this_wave
var current_wave_number = -1

signal wave_update
signal drop_item

func _ready():
	waves = $Waves.get_children()
	
func start_next_wave():
	enemies_killed_this_wave = 0
	current_wave_number += 1
	if current_wave_number < waves.size():
		emit_signal("wave_update", current_wave_number)
		current_wave = waves[current_wave_number]
		enemies_remaining_to_spawn = current_wave.num_enemies
		timer.wait_time = current_wave.seconds_between_spawns
		timer.start()
		
	if current_wave.should_drop(enemies_killed_this_wave):
		emit_signal("drop_item", current_wave.DropItem)

func connect_to_enemy_signals(enemy_received: Enemy):
	var stats: Stats = enemy_received.get_node("Stats")
	stats.dead_signal.connect(_on_enemy_stats_dead_signal)
	#stats.connect("dead_signal",self,"_on_stats_dead_signal")
	#stats.you_died_signal.connect(_on_enemy_stats_you_died_signal)
	
func _on_enemy_stats_dead_signal():
	enemies_killed_this_wave += 1
	print("Enemigos asesinados ", enemies_killed_this_wave)
	
	#Validamos si deberiamos dropear el arma
	if current_wave.should_drop(enemies_killed_this_wave):
		emit_signal("drop_item", current_wave.DropItem)
	

func _on_timer_timeout():
	if enemies_remaining_to_spawn:
		var new_enemy = enemy.instantiate()
		connect_to_enemy_signals(new_enemy)
		
		var scene_root = get_parent()
		scene_root.add_child(new_enemy)
		enemies_remaining_to_spawn -= 1
	else:
		if enemies_killed_this_wave == current_wave.num_enemies:
			start_next_wave()
		
