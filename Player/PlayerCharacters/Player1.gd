extends CharacterBody3D

#Velocidad en metros por segundo
@export var SPEED = 7.0

var raycast_length = 500 
var acceleration = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const JUMP_VELOCITY = 4.5

@onready var gun_controller = $GunController
@onready var player_hand = $soldier/Armature/Skeleton3D/RightHand

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Forma 1 movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration))
	else:
		velocity.x = move_toward(velocity.x, 0 , SPEED)
		velocity.z = move_toward(velocity.z, 0 , SPEED)
		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration))
	
	move_and_slide()
	
	# Seteamos look_at que afectara a la rotacion del arma segun donde esta el mouse
	var mouse_position_result = ScreenpointToRay()
	#var look_at_me = Vector3(mouse_position_result.x, 0, mouse_position_result.z)
	##player_hand.look_at(look_at_me, Vector3.UP)
	look_at(mouse_position_result, Vector3.UP)
	
	#Hago que la camara obtenga la posicion del Player
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.1) 
	
	#Shoot Actions
	if Input.is_action_pressed("primary_action"):
		gun_controller.hold_trigger()
		$Camera_Controller/Camera_target/Camera3D.shake_camera()
		#$AnimationTree.set("parameters/transition_shoot_reload/transition_request", "shoot")
		#$AnimationTree.set("parameters/anim_shoot_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE )
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
	var camera = $Camera_Controller/Camera_target/Camera3D 
	
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = camera.project_ray_origin(mouse_position)
	ray_params.to = ray_params.from + camera.project_ray_normal(mouse_position) * raycast_length
	ray_params.exclude = []
	ray_params.collision_mask = 8
	
	var ray_result = space_state.intersect_ray(ray_params)
	
	if !ray_result.is_empty():
		return ray_result.position
		
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
