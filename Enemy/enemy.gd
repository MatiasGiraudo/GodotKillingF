extends CharacterBody3D

class_name Enemy

@export var SPEED = 4.0
var ATTACK_RANGE = 2.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var state_machine

@onready var player = $"../Player1" as CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_audio = $AudioAttack
@onready var anim_tree = $AnimationTree

func _ready():
	state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	anim_tree.set("parameters/conditions/attack", target_in_range())
	anim_tree.set("parameters/conditions/run", !target_in_range())
	
	move_and_slide()
	

func target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func hit_finished():
	var stats_player : Stats = player.get_node("Stats")
	stats_player.take_hit(1)
	attack_audio.play()

func _on_stats_dead_signal():
	anim_tree.set("parameters/conditions/dead", true)
	await get_tree().create_timer(4).timeout 
	queue_free()
