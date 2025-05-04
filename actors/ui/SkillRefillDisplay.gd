extends HBoxContainer


var data = {}


func _physics_process(delta: float) -> void:
	if data.is_empty():
		return
	
	$Amount.text = 'x%s' % int(data['uses_count'])
	$SkillName.text = '%s' % data['name']
	$Add.text = '%s' % int(data['refill_cost'])


func _on_add_pressed() -> void:
	data['uses_count'] += 1
	
	ManagerGame.player_data['gold'] -= data['refill_cost']
