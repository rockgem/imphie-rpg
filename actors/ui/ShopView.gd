extends Control


var items_for_sale = [
	'small_hp_potion',
	'large_hp_potion',
]



func _ready() -> void:
	# loading for sale items
	for child in $Panel/ScrollContainer/List.get_children():
		child.queue_free()
	
	for item in items_for_sale:
		var i = load('res://actors/ui/ShopItemDisplay.tscn').instantiate()
		i.data = ManagerGame.items_data[item]
		
		$Panel/ScrollContainer/List.add_child(i)


func _on_close_pressed() -> void:
	queue_free()
