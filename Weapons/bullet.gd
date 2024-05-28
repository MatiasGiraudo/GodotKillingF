extends Node3D
@export var speed = 70
@export var damage = 1

const Kill_Time = 2
var timer = 0

@onready var audio_impacts = $AudioImpact

func _physics_process(delta):
	var forward_direction = global_transform.basis.z.normalized()
	global_translate(forward_direction * speed * delta)
	
	timer += delta
	if timer >= Kill_Time:
		queue_free()


func _on_area_3d_body_entered(body: Node):
	queue_free()
	
	audio_impacts.play()
	if body.has_node("Stats"):
		var stats_node = body.find_child("Stats") as Stats
		stats_node.take_hit(damage)
