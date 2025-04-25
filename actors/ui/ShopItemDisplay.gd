extends HBoxContainer


signal initiate_buy(own)

var data = {}


func _ready() -> void:
	if data.is_empty():
		return
	
	$ItemName.text = data['name']
	$Desc.text = data['desc']
	$Price.text = '$%s' % int(data['price'])
	
	$Icon.texture = load('%s' % data['icon'])


func _on_buy_pressed() -> void:
	
	# we are only using this signal so that the game will recognize that we are about to be
	# buying this item, passing the "self" as parameter so we can also access the data of the item
	# see ( ShopView.tscn/gd )
	initiate_buy.emit(self)
