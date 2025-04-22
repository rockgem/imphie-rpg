extends Node


signal round_finished
signal round_started
signal wave_finished
signal wave_started


# here we reference the entire game level / the game world so we can easily access things
# like, adding damage floater objects or even manipulate the background on certain situations
# see ( World.tscn )
var global_main_world_ref: MainWorld


var player_data = {}


func _ready() -> void:
	player_data = get_data("res://reso/data/player_data.json")
	var characters = get_data("res://reso/data/characters.json")
	
	# add the starting characters into player_data :D
	player_data['characters'] = characters


# a helper function which converts json files into a game-readable dictionary
func get_data(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var j = JSON.new()
	j.parse(f.get_as_text())
	
	return j.data
