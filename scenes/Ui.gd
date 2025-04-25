extends CanvasLayer

#var attack_queue = {}


func _ready() -> void:
	ManagerGame.pop_to_ui.connect(on_pop_to_ui)
	ManagerGame.wave_finished.connect(on_wave_finished)
	
	clear_players()
	
	$BottomPanel.hide()
	
	for skill_button in $BottomPanel/HBoxContainer/AttackOptionsBox/HBoxContainer.get_children():
		skill_button.pressed.connect(on_attack_selected.bind(skill_button.text))


func _physics_process(delta: float) -> void:
	$HBoxContainer/RoundDisplay/RoundAmount.text = '%s' % ManagerGame.global_main_world_ref.round


func clear_enemies_display():
	for child in $HBoxContainer/EnemyCharactersBox.get_children():
		child.queue_free()


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
	
	on_attack_selected('Attack')
	
	$BottomPanel.show()
	
	for child in $BottomPanel/TurnsDisplayBox.get_children():
		child.queue_free()
	
	for e in ManagerGame.global_main_world_ref.turns_arrangement:
		if e.is_dead == false:
			var l = Label.new()
			l.text = e.data['name']
			
			if e.is_player == false:
				l.set('theme_override_colors/font_color', Color.RED)
			
			$BottomPanel/TurnsDisplayBox.add_child(l)


func hide_bottom_panel():
	
	$BottomPanel.hide()


func on_attack_selected(attack_name: String):
	var skill_data = ManagerGame.skills_data[attack_name]
	
	$BottomPanel/HBoxContainer/AttackOptionsBox/SkillDescription.text = skill_data['desc']
	
	# attack is a melee attack ( based on the character's attack value itself )
	if attack_name == 'Attack':
		var current_entity_turn = ManagerGame.global_main_world_ref.turns_arrangement[0]
		$BottomPanel/HBoxContainer/SkillStatBox/SkillAttack/Label2.text = '%s' % int(current_entity_turn.data['attack'])
	else:
		$BottomPanel/HBoxContainer/SkillStatBox/SkillAttack/Label2.text = '%s' % int(skill_data['attack'])


func _on_shop_pressed() -> void:
	var i = load('res://actors/ui/ShopView.tscn').instantiate()
	
	ManagerGame.pop_to_ui.emit(i)


func on_pop_to_ui(instance):
	for child in $Popups.get_children():
		child.queue_free()
	
	$Popups.add_child(instance)


func on_wave_finished():
	$HBoxContainer/RoundDisplay/RoundAmount.text = '%s' % int(ManagerGame.global_main_world_ref.wave)
