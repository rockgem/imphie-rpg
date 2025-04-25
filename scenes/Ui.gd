extends CanvasLayer

var attack_queue = {}


func _ready() -> void:
	clear_players()
	
	$BottomPanel.hide()
	
	for skill_button in $BottomPanel/HBoxContainer/AttackOptionsBox/HBoxContainer.get_children():
		skill_button.pressed.connect(on_attack_selected.bind(skill_button.text))


func _physics_process(delta: float) -> void:
	$HBoxContainer/RoundDisplay/RoundAmount.text = '%s' % ManagerGame.global_main_world_ref.round


func clear_players():
	for child in $HBoxContainer/PlayerCharactersBox.get_children():
		child.queue_free()
	for child in $HBoxContainer/EnemyCharactersBox.get_children():
		child.queue_free()


func add_player_display(entity_ref: Entity):
	var display = load('res://actors/ui/CharacterStatDisplay.tscn').instantiate()
	display.entity_ref = entity_ref
	
	$HBoxContainer/PlayerCharactersBox.add_child(display)


func add_enemy_display(entity_ref: Entity):
	var display = load('res://actors/ui/CharacterStatDisplay.tscn').instantiate()
	display.entity_ref = entity_ref
	
	$HBoxContainer/EnemyCharactersBox.add_child(display)
	
	display.mana_bar.hide()


func pop_bottom_panel(entity: Entity):
	$BottomPanel/HBoxContainer/StatBox/EntityAttack/Label2.text = '%s' % int(entity.data['attack'])
	$BottomPanel/HBoxContainer/StatBox/EntityDefense/Label2.text = '%s' % int(entity.data['defense'])
	$BottomPanel/HBoxContainer/StatBox/EntitySpeed/Label2.text = '%s' % int(entity.data['speed'])
	
	$BottomPanel.show()


func hide_bottom_panel():
	
	$BottomPanel.hide()


func on_attack_selected(attack_name: String):
	var skill_data = ManagerGame.skills_data[attack_name]
	
	$BottomPanel/HBoxContainer/AttackOptionsBox/SkillDescription.text =  skill_data['desc']
