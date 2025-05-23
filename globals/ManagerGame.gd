extends Node


signal round_finished
signal round_started
signal wave_finished(is_win)
signal wave_started
signal entity_action_finished
signal game_over(is_win)
signal pop_to_ui(instance)
signal inventory_changed
signal player_data_changed


# here we reference the entire game level / the game world so we can easily access things
# like, adding damage floater objects or even manipulate the background on certain situations
# see ( World.tscn )
var global_main_world_ref: MainWorld
var global_ui_ref: UI


var player_data = {} : 
	set(value):
		player_data = value
		
		player_data_changed.emit()
var items_data = {}
var skills_data = {}


func _ready() -> void:
	player_data = get_data("res://reso/data/player_data.json")
	skills_data = get_data("res://reso/data/skills_data.json")
	items_data = get_data("res://reso/data/items_data.json")
	var characters = get_data("res://reso/data/characters.json")
	
	# add the starting characters into player_data :D
	player_data['characters'] = characters
	
	# duplicate skills_data
	for char in player_data['characters']:
		for skill in player_data['characters'][char]['skills']:
			var dup = skills_data[skill].duplicate()
			
			player_data['characters'][char]['skills_data'][skill] = dup


# a helper function which converts json files into a game-readable dictionary
func get_data(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	
	return j.data


func add_item_to_inv(data, amount = 1):
	if ManagerGame.player_data['inv'].has(data['name']):
		ManagerGame.player_data['inv'][data['name']]['amount'] += amount
	else:
		ManagerGame.player_data['inv'][data['name']] = data.duplicate()
		ManagerGame.player_data['inv'][data['name']]['amount'] = 1
