extends HBoxContainer


var data = {}


func _ready() -> void:
	if data.is_empty():
		return
	
	$ItemName.text = data['name']
	$Desc.text = data['desc']
	$Price.text = '$%s' % int(data['price'])
	
	$Icon.texture = load('%s' % data['icon'])
