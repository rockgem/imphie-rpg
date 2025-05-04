extends CanvasLayer
class_name UI

#var attack_queue = {}


# this dict's structure will be the same as skills_data
var current_skill_selected = {}


func _ready() -> void:
	ManagerGame.global_ui_ref = self
	
	ManagerGame.pop_to_ui.connect(on_pop_to_ui)
	
	clear_players()
	
	$BottomPanel.hide()
	
	# #########################################################################
	# dynamically loading buttons instead
	for button in $BottomPanel/HBoxContainer/AttackOptionsBox/SkillsButtonBox.get_children():
		button.queue_free()
	
	for skill in ManagerGame.skills_data:
		var new_button: SkillButton = load('res://actors/ui/SkillButton.tscn').instantiate()
		# btw, you need to be aware that this data is essentially going to be the same even though it is getting passed around like a college girl
		# that means when you edit this data's values, it edits every single reference it has around the game
		# i made it like this so you won't have to keep changing the data individualy but only change one of them and the rest will be reflected
		# i feel like this is a bit more advanced side of programming, hopefully you will get the idea.
		
		# P.S. i also did this same technique in other areas of the game such as; Entity.tscn -> "data" dictionary being reference in CharacterStatDisplay.tscn
		new_button.data = ManagerGame.skills_data[skill]
		# ###################################################################################################
		
		new_button.text = skill
		
		$BottomPanel/HBoxContainer/AttackOptionsBox/SkillsButtonBox.add_child(new_button)
	
	for skill_button in $BottomPanel/HBoxContainer/AttackOptionsBox/SkillsButtonBox.get_children():
		skill_button.pressed.connect(on_attack_selected.bind(skill_button.text))
	
	# #########################################################################


func _physics_process(delta: float) -> void:
	$HBoxContainer/RoundDisplay/RoundAmount.text = '%s' % ManagerGame.global_main_world_ref.wave


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
	var display = load('res://actors/ui/CharacterStatDisplayFlipped.tscn').instantiate()
	display.entity_ref = entity_ref
	
	$HBoxContainer/EnemyCharactersBox.add_child(display)
	
	display.exp_bar.hide()


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
	current_skill_selected = ManagerGame.skills_data[attack_name]
	#var attack_name = current_skill_button_selected.text
	
	$BottomPanel/HBoxContainer/AttackOptionsBox/SkillDescription.text = current_skill_selected['desc']
	
	# attack is a melee attack ( based on the character's attack value itself )
	if attack_name == 'Attack':
		var current_entity_turn = ManagerGame.global_main_world_ref.turns_arrangement[0]
		$BottomPanel/HBoxContainer/SkillStatBox/SkillAttack/Label2.text = '%s' % int(current_entity_turn.data['attack'])
	else:
		$BottomPanel/HBoxContainer/SkillStatBox/SkillAttack/Label2.text = '%s' % int(current_skill_selected['attack'])
	
	$BottomPanel/HBoxContainer/SkillStatBox/SkillUses/Label2.text = '%s' % int(current_skill_selected['uses_count'])


func _on_shop_pressed() -> void:
	var i = load('res://actors/ui/ShopView.tscn').instantiate()
	
	ManagerGame.pop_to_ui.emit(i)


func on_pop_to_ui(instance):
	for child in $Popups.get_children():
		child.queue_free()
	
	$Popups.add_child(instance)
