extends CharacterBody3D

class_name Enemy

@onready var player = $"../Player1" as CharacterBody3D
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var attack_timer = $AttackTimer
@onready var attack_audio = $AudioAttack
@onready var death_audio = $AudioDeath

var speed = 2
var accel = 10
var attack_speed_multiplier = 5
var attacking = false
var current_state = state.SEEKING

var attack_target: Vector3
var return_target: Vector3

var default_material = load("res://Enemy/enemyDefaultColor.tres")
var attack_material = load("res://Enemy/enemyAttackMaterial.tres")
var resting_material = load("res://Enemy/enemyRestingMaterial.tres")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING
}

func _ready():
	$MeshInstance3D.set_surface_override_material(0, default_material)

func _physics_process(delta):
	var direction = Vector3()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if is_instance_valid(player):
		match current_state:
			state.SEEKING:
				nav.target_position = player.global_position
				
				direction = nav.get_next_path_position() - global_position
				direction = direction.normalized()
				
				velocity = velocity.lerp(direction * speed, accel * delta)
				move_and_slide()
				
				if $AttackRadio.overlaps_body(player):
					init_attack()					
				
			state.ATTACKING:
				move_and_attack()
			state.RETURNING:
				move_and_attack()
			state.RESTING:
				pass

func move_and_attack():
	#var direction: Vector3 = player.global_position - global_position
	var attack_vector: Vector3 = attack_target - global_transform.origin
	var direction: Vector3 = attack_vector.normalized()
	
	velocity = direction * speed * attack_speed_multiplier
	move_and_slide()
	attack_audio.play()
	
	
	var distance = attack_vector.length()
	
	if distance <= 1.1:
		match current_state:
			state.ATTACKING:
				var stats_player : Stats = player.get_node("Stats")
				stats_player.take_hit(1)
				
				current_state = state.RETURNING
				attack_target = return_target
			state.RETURNING:
				current_state = state.RESTING
				$MeshInstance3D.set_surface_override_material(0, resting_material)
				collide_with_other_enemies(true)
				direction = Vector3.ZERO
				move_and_slide()
				attack_timer.start()

func collide_with_other_enemies(should_be_collide):
	set_collision_mask_value(3, should_be_collide)
	set_collision_layer_value(3, should_be_collide)

func _on_stats_dead_signal():
	death_audio.play()
	queue_free()

func init_attack():
	return_target = global_transform.origin
	attack_target = player.global_transform.origin
	current_state = state.ATTACKING
	$MeshInstance3D.set_surface_override_material(0, attack_material)
	collide_with_other_enemies(false)


func _on_attack_timer_timeout():
	current_state = state.SEEKING
	$MeshInstance3D.set_surface_override_material(0, default_material)
