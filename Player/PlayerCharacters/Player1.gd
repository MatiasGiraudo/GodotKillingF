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

func _ready():
	pass
	#animation_player.set_blend_time("Idle", "Running_B", 0.2)
	#animation_player.set_blend_time("Running_B", "Idle", 0.2)

func _physics_process(delta):
	if Input.is_action_pressed("aim"):
		$AnimationTree.set("parameters/aim_transition/current_index", 0)
		#print($AnimationTree.get("parameters/aim_transition/current_state"))
	else:
		$AnimationTree.set("parameters/aim_transition/current_index", 1)
		#print($AnimationTree.get("parameters/aim_transition/current_state"))
		
	print($AnimationTree.get("parameters/aim_transition/current_state"))
	
	
	#Forma 1 movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward","move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	
	strafe_dir = direction
	direction = (transform.basis * direction).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		#look_at(direction * position)
		visual_rig.look_at(position + 10 * velocity, Vector3.UP, true)
		
		if !walking:
			walking = true
			#animation_player.play("Running_B")
			
		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration))
		#print(lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration))
	else:
		velocity.x = move_toward(velocity.x, 0 , speed)
		velocity.z = move_toward(velocity.z, 0 , speed)
		
		if walking:
			walking = false
		
		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration))
		#print(lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration))
			
			#animation_player.play("Idle")
		
	
	
	
	# Creamos una variable para almacenar la direccion de entrada
	#var direction = Vector3.ZERO
#
	## Chequea el input de movimineno y actualizamos la direccion que sea necesaria
	#if Input.is_action_pressed("move_right"):
		#direction.x += 1
	#if Input.is_action_pressed("move_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("move_back"):
		## En 3D, el plano XZ es el plano terrestre
		#direction.z += 1
	#if Input.is_action_pressed("move_forward"):
		#direction.z -= 1
		#
	#if direction != Vector3.ZERO:
		#direction = direction.normalized()
		#
	#target_velocity.x = direction.x * speed
	#target_velocity.z = direction.z * speed
	#
	#velocity = target_velocity
		#
	#animation_tree.set("parameters/IWR/blend_position", Vector2(target_velocity.x, -target_velocity.z) / speed)
		#
		
		
		
	# Seteamos look_at que afectara a la rotacion del personaje segun donde esta el mouse
	var mouse_position_result = ScreenpointToRay()
	var look_at_me = Vector3(mouse_position_result.x, 0, mouse_position_result.z)
	#look_at(look_at_me, Vector3.UP)
	#var distance_to_pointer = player_hand.global_transform.origin - look_at_me
	#if distance_to_pointer > 3:
	player_hand.look_at(look_at_me, Vector3.UP)
	move_and_slide()
	
	#Shoot Actions
	if Input.is_action_pressed("primary_action"):
		gun_controller.hold_trigger()
		#animation_state.travel("1H_Ranged_Shoot")
	else:
		gun_controller.release_trigger()
		
	#Reload
	if Input.is_action_just_pressed("reload"):
		gun_controller.reload()

	
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
