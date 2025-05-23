extends Control


var items_for_sale = [
	'small_hp_potion',
	'large_hp_potion',
]

var current_item_selected


func _ready() -> void:
	ManagerGame.player_data_changed.connect(on_player_data_changed)
	
	UIAnimation.animate_slide_from_right(self)
	
	# loading for sale items
	for child in $Panel/ScrollContainer/List.get_children():
		child.queue_free()
	
	for item in items_for_sale:
		var i = load('res://actors/ui/ShopItemDisplay.tscn').instantiate()
		i.data = ManagerGame.items_data[item]
		i.initiate_buy.connect(on_initiate_buy)
		
		$Panel/ScrollContainer/List.add_child(i)
	
	on_player_data_changed()
	
	for child in $Panel/SkillsPanel/SkillsList.get_children():
		child.queue_free()
	for child in $Panel/SkillsPanel/CharacterList.get_children():
		child.queue_free()
	
	for char in ManagerGame.player_data['characters']:
		var b = Button.new()
		b.text = char
		b.pressed.connect(on_char_selected.bind(b.text))
		
		$Panel/SkillsPanel/CharacterList.add_child(b)
	
	# it is important to pause the scene tree when this view is active, this essentially
	# pauses the game until this view is closed
	get_tree().paused = true


func _physics_process(delta: float) -> void:
	$Panel/Gold.text = '%s' % int(ManagerGame.player_data['gold'])

func on_initiate_buy(ref):
	current_item_selected = ref
	
	UIAnimation.animate_slide_from_right($ConfimationPanel)
	
	$ConfimationPanel/Icon.texture = ref.get_node('Icon').texture
	$ConfimationPanel/BuyFinal.text = 'Buy'


func _on_close_pressed() -> void:
	await UIAnimation.animate_slide_to_right(self)
	
	get_tree().paused = false
	queue_free()


func _on_amount_value_changed(value: float) -> void:
	$ConfimationPanel/BuyFinal.text = 'Buy %s' % int(value * current_item_selected.data['price'])


func _on_buy_final_pressed() -> void:
	if current_item_selected == null:
		return
	
	ManagerGame.add_item_to_inv(current_item_selected.data, $ConfimationPanel/Icon/Amount.value)
	
	ManagerGame.player_data['gold'] -= $ConfimationPanel/Icon/Amount.value * current_item_selected.data['price']
	ManagerGame.inventory_changed.emit()


func on_player_data_changed():
	$Panel/Gold.text = '%s' % int(ManagerGame.player_data['gold'])


func on_char_selected(char_name: String):
	for child in $Panel/SkillsPanel/SkillsList.get_children():
		child.queue_free()
	
	for skill in ManagerGame.player_data['characters'][char_name]['skills_data']:
		var i = load('res://actors/ui/SkillRefillDisplay.tscn').instantiate()
		i.data = ManagerGame.player_data['characters'][char_name]['skills_data'][skill]
		
		$Panel/SkillsPanel/SkillsList.add_child(i)
