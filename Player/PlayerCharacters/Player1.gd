extends CharacterBody3D

#Velocidad en metros por segundo
@export var speed = 5

var target_velocity = Vector3.ZERO
var raycast_length = 1000 

var walking = false
var acceleration = 5

var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

@onready var gun_controller = $GunController
@onready var player_hand = $"Rig/Skeleton3D/1H_Crossbow"
@onready var animation_player = $AnimationPlayer
@onready var visual_rig = $Rig


func _physics_process(delta):
	#Forma 1 movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward","move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		#look_at(direction * position)
		visual_rig.look_at(position + 10 * velocity, Vector3.UP, true)
		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration))
	else:
		velocity.x = move_toward(velocity.x, 0 , speed)
		velocity.z = move_toward(velocity.z, 0 , speed)
		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration))
	
	# Seteamos look_at que afectara a la rotacion del arma segun donde esta el mouse
	var mouse_position_result = ScreenpointToRay()
	var look_at_me = Vector3(mouse_position_result.x, 0, mouse_position_result.z)
	player_hand.look_at(look_at_me, Vector3.UP)
	move_and_slide()
	
	#Shoot Actions
	if Input.is_action_pressed("primary_action"):
		gun_controller.hold_trigger()
		$AnimationTree.set("parameters/transition_shoot_reload/transition_request", "shoot")
		$AnimationTree.set("parameters/anim_shoot_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE )
		#animation_state.travel("1H_Ranged_Shoot")
	else:
		gun_controller.release_trigger()
		
	#Reload
	if Input.is_action_just_pressed("reload"):
		gun_controller.reload()
		$AnimationTree.set("parameters/transition_shoot_reload/transition_request", "reload")
		$AnimationTree.set("parameters/anim_shoot_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE )

	
func ScreenpointToRay():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var camera = get_tree().root.get_camera_3d()
	
	# Create PhysicsRayQueryParameters3D object
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = camera.project_ray_origin(mouse_position)
	ray_params.to = ray_params.from + camera.project_ray_normal(mouse_position) * raycast_length
	ray_params.exclude = []
	ray_params.collision_mask = 8
	var ray_array = space_state.intersect_ray(ray_params)
	
	if ray_array.has("position"):
		return ray_array["position"]  
		
	return Vector3()
	
func equip_item(item_scene: PackedScene):
	var item = item_scene.instantiate()
	if item is Gun:
		gun_controller.equip_weapon(item)


func _on_stats_dead_signal():
	var scene = load("res://Title&Menu/Retry.tscn")
	get_tree().change_scene_to_packed(scene)
	queue_free()


func _on_dropper_item_picked_up(item_scene: PackedScene):
	equip_item(item_scene)


func _on_selected_weapons_weapon_selected(weapon_selected: PackedScene):
	equip_item(weapon_selected)
