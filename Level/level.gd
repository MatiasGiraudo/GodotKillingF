extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Spawner.start_next_wave()
	$Player1.get_node("Stats").take_hit(0)
	$Dropper.drop()
	
	#$AudioBackground.play()
