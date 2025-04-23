extends CanvasLayer




func _ready() -> void:
	clear_players()


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
