extends Node3D
class_name Gun

enum FireMode {
	SINGLE,
	BURST,
	AUTO
}

@export var gun_name = "Gun"
@export var icon:Texture
@export var bullet: PackedScene
@export var muzzle_speed = 30
@export var millisec_between_shots = 100
@export var fire_mode: FireMode = FireMode.AUTO
@export var BulletSpawns:Array[PackedScene]
@export var burst_shots = 3
@export var mag_capacity = 13

var can_shoot = true
var trigger_released = true
var burst_shots_remaining
var bullet_spawns = []
var bullets_in_mag

@onready var rof_timer = $Timer
@onready var shoot_audio = $AudioShoot
@onready var reload_audio = $AudioReload

signal update_ammo

# Called when the node enters the scene tree for the first time.
func _ready():
	$Muzzle/MuzzleFlash/Timer.connect("timeout", func(): $Muzzle/MuzzleFlash.visible = false)
	$Muzzle/MuzzleFlash/Timer.set_wait_time(0.03)
	rof_timer.wait_time = millisec_between_shots / 1000.0
	reset_bursts()
	#reload()
	init_bullet_spawn()
	
	
func init_bullet_spawn():
	for spawn in BulletSpawns:
		var spawn_bullet = spawn.instantiate()
		$Muzzle.add_child(spawn_bullet)
		
	bullet_spawns = $Muzzle.get_children()
	
func reset_bursts():
	burst_shots_remaining = burst_shots	
	
func reload():
	#Animacion de reload
	$AnimationPlayer.play("Reload")
	reload_audio.play()
	
func refill_mag():
	bullets_in_mag = mag_capacity
	emit_signal("update_ammo", bullets_in_mag, mag_capacity)
	
	
func hold_trigger(): # Cuando esta presionando el gatillo
	
	match fire_mode:
		FireMode.SINGLE:
			if trigger_released:
				shoot()
		FireMode.BURST:
			if burst_shots_remaining:
				if shoot():
					burst_shots_remaining -= 1
		FireMode.AUTO:
			shoot()
	trigger_released = false
	
	
func release_trigger(): # Cuando dejo de disparar
	trigger_released = true
	reset_bursts()

func shoot():
	if can_shoot and bullets_in_mag:
		for spawn in bullet_spawns:
			var new_bullet = bullet.instantiate()
			new_bullet.global_transform = spawn.global_transform
			new_bullet.speed = muzzle_speed 
			var root_scene = get_tree().root.get_children()[0]
			root_scene.add_child(new_bullet)
		can_shoot = false
		rof_timer.start()
		bullets_in_mag -= 1
		emit_signal("update_ammo", bullets_in_mag, mag_capacity)
		$Muzzle/MuzzleFlash.visible = true
		$Muzzle/MuzzleFlash/Timer.start()
		shoot_audio.play()
		return true
	elif not bullets_in_mag:
		reload()
	else:
		return false

func drop():
	#$Malla.position = Vector3.ZERO
	$AnimationPlayer.play("Drop")

func _on_timer_timeout():
	can_shoot = true
