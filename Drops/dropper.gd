extends Node3D

var DropItem: PackedScene
var drop_item: Node

signal item_picked_up

func _ready():
	$PickupArea/CollisionShape3D.disabled = true

func drop():
	if DropItem:
		drop_item = DropItem.instantiate()
		
		if drop_item.has_method("drop"):
			var location = Vector3.ZERO
			self.global_transform.origin = Vector3(location.x, self.global_transform.origin.y, location.z)
			$PickupArea/CollisionShape3D.set_deferred("disabled", false)
			
			drop_item.drop()
			self.add_child(drop_item)
		else: 
			print("Invalid drop item")


func _on_pickup_area_body_entered(body):
	emit_signal("item_picked_up", DropItem)
	$PickupArea/CollisionShape3D.set_deferred("disabled", true)
	drop_item.queue_free()


func _on_spawner_drop_item(item: PackedScene):
	DropItem = item
	drop()
	
