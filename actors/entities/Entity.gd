extends Node2D
class_name Entity

@export var is_player = true

# in this dictionary, we store the entity's hp, mana, exp etc.
var data = {}


func _ready() -> void:
	if data.is_empty():
		return
	
	$Name.text = '%s' % data['name']


func receive_damage(damage = 1):
	pass
