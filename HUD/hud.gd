extends Control

@onready var wave = $VBoxContainer/GridContainer/WaveValue
@onready var health = $VBoxContainer/GridContainer2/HealthValue
@onready var ammo = $VBoxContainer/GridContainer2/AmmoValue

func _on_spawner_wave_update(current_wave):
	wave.text = str(current_wave + 1)


func _on_stats_update_health(current_HP):
	health.text = str(current_HP)


func _on_gun_controller_ammo_update(ammo_value, mag_capacity):
	ammo.text = str(ammo_value) + " / " + str(mag_capacity)
