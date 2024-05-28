extends Node

@export var starting_weapon: PackedScene
var hand: BoneAttachment3D
var equipped_weapon: Gun

signal ammo_update

func _ready():
	hand = get_parent().find_child("1H_Crossbow")
	
	# Si hay un arma colocada como arma inicial, la equipamos
	if starting_weapon:
		equip_weapon(starting_weapon.instantiate())
		
func equip_weapon(weapon_to_equip: Gun):
	if equipped_weapon:
		equipped_weapon.queue_free()
		
	equipped_weapon = weapon_to_equip
	hand.add_child(equipped_weapon)
	equipped_weapon.connect("update_ammo", _on_Gun_update_ammo)
	equipped_weapon.reload()
	
func _on_Gun_update_ammo(ammo_value, mag_capacity):
	emit_signal("ammo_update", ammo_value, mag_capacity)
	
func hold_trigger(): # Cuando esta presionando el gatillo
	if equipped_weapon:
		equipped_weapon.hold_trigger()
		
func release_trigger(): # Cuando dejo de disparar
	if equipped_weapon:
		equipped_weapon.release_trigger()
		
func reload():
	if equipped_weapon:
		equipped_weapon.reload()
