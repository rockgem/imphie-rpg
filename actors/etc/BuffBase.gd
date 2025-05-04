extends Node
class_name Buff


func _ready() -> void:
	ManagerGame.entity_action_finished.connect(on_entity_action_finished)


func on_entity_action_finished():
	pass
