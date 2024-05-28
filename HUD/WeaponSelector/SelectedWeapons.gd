extends ItemList

@export var weapon_inventory: Array[PackedScene]

signal weapon_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	for WeaponScene in weapon_inventory:
		add_weapon(WeaponScene)
		
	self.select(0)
		
func _input(event):
	if event.is_action_pressed("secondary_action"):
		var new_index = self.get_selected_items()[0] + 1
		
		if new_index >= self.get_item_count():
			new_index = 0
			
		self.select(new_index)
		self._on_item_selected(new_index)
		
	if event is InputEventKey and event.is_pressed():
		var new_index = null
		match  event.keycode:
			KEY_1:
				new_index = 0
			KEY_2:
				new_index = 1
			KEY_3:
				new_index = 2
			KEY_4:
				new_index = 3
			KEY_5:
				new_index = 4
				
		if new_index != null and new_index <= self.get_item_count():
			self. select(new_index)
			_on_item_selected(new_index)
			
		
func add_weapon(WeaponScene: PackedScene):
	var weapon: Gun = WeaponScene.instantiate()	
	var text = str(self.get_item_count() + 1) + ": " + weapon.gun_name
	self.add_item(text, weapon.icon, true)	
	self.select(self.get_item_count() - 1)
	if not WeaponScene in weapon_inventory:
		weapon_inventory.append(WeaponScene)

func is_duplicate(new_weapon: PackedScene):
	var weapon = new_weapon.instantiate() 
	var index = 0
	
	for actual_weapon in weapon_inventory:
		if actual_weapon.instantiate().gun_name == weapon.gun_name:
			self.select(index)
			return true
		
		index += 1
		
func _on_item_selected(index):
	var WeaponScene = weapon_inventory[index]
	emit_signal("weapon_selected", WeaponScene)


func _on_dropper_item_picked_up(item_scene: PackedScene):
	if not is_duplicate(item_scene):
		add_weapon(item_scene)
