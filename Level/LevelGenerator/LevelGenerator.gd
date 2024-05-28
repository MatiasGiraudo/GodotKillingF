extends Node3D

@export var ground_scene: PackedScene

@export var map_width = 11
@export var map_depth = 11




# Called when the node enters the scene tree for the first time.
func _ready():
	generateMap()
	
func generateMap():
	print("Generando mapa")
	var ground: StaticBody3D = ground_scene.instantiate()
	ground.size = Vector3(map_width*2, 1 ,map_depth*2) 
	add_child(ground)
