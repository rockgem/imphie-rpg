extends Node2D
class_name MainWorld

# 1 round means the player accomplished 10 waves, in after every round finishes,
# a panel will popup where the player can then buy stuff from the merchant or upgrade
# their gears in the blacksmith
var round = 1
var wave = 0 # 10 waves is equal to 1 round


# this will be an array of Entity.tscn objects
# pretty much will be holding references of the entities
var turns_arrangement = []


func _ready() -> void:
	ManagerGame.entity_action_finished.connect(on_entity_action_finished)
	ManagerGame.wave_finished.connect(on_wave_finished)
	
	ManagerGame.global_main_world_ref = self
	
	load_player_data()
	#generate_enemies()
	
	next_round()


# loading the player_data ['characters']
func load_player_data():
	var count = 0
	for char in ManagerGame.player_data['characters']:
		# here we create a new Entity object and assign the "data" variable to store the character's data
		# ( see Entity.tscn / .gd )
		var ent = load('res://actors/entities/Entity.tscn').instantiate()
		ent.data = ManagerGame.player_data['characters'][char]
		ent.global_position = $PlayerSpawnPoints.get_child(count).global_position
		
		add_child(ent) # we add the entity object itself into the scene / scene tree
		
		# we add a new displaying component into the UI passing the entity object as parameter,
		# because we need to be able to listen and reference the entity.tscn for the displaying
		# of hp, mana etc. ( see CharacterStatDisplay.tscn )
		$UI.add_player_display(ent)
		
		count += 1


# this is pretty much the same as the load_player_data() function
# but this loads up the enemies from enemies.json
func generate_enemies():
	$UI.clear_enemies_display()
	
	var enemies = ManagerGame.get_data("res://reso/data/enemies.json")
	
	var count = 0
	for enemy in enemies:
		var ent = load('res://actors/entities/Entity.tscn').instantiate()
		ent.is_player = false # we set the is_player to false because this is obviously not the player's lol
		ent.data = enemies[enemy]
		ent.global_position = $EnemySpawnPoints.get_child(count).global_position
		
		add_child(ent)
		
		$UI.add_enemy_display(ent)
		
		count += 1


# the parameters of these are just Entity.tscn objects
# since entity objects have data variable we can then access the entity's stats
# in this case, the "speed" is what we need to sort
func sort_speed(a, b):
	if a.data['speed'] > b.data['speed']:
		return true
	
	return false


func next_round():
	next_wave()
	
	ManagerGame.round_started.emit()
	ManagerGame.wave_started.emit()


func next_wave():
	# pops up shop view before every level starts
	if wave != 0:
		var i = load('res://actors/ui/ShopView.tscn').instantiate()
		ManagerGame.pop_to_ui.emit(i)
	
	generate_enemies()
	
	wave += 1
	
	if wave > 10:
		wave = 0
		end_round()
		return
	
	# here we arrange the arrangement of the array by using my custom sort callable function
	# it basically sorts the entity from the highest "speed" stat to lowest
	# sort_custom() documentation can be found in the "Array" section
	turns_arrangement = get_tree().get_nodes_in_group("Entity")
	turns_arrangement.sort_custom(sort_speed)
	
	if turns_arrangement[0].is_player:
		$UI.pop_bottom_panel(turns_arrangement[0])
	else:
		turns_arrangement[0].choose_random_player_attack()
	
	#ManagerGame.wave_finished.emit()
	#ManagerGame.wave_started.emit()


func end_round():
	ManagerGame.round_finished


func on_wave_finished(is_win: bool):
	next_wave()
	
	return is_win


func on_entity_action_finished():
	var alive_enemies = []
	var alive_players = []
	for entity: Entity in turns_arrangement:
		if entity.is_player and entity.is_dead == false:
			alive_players.append(entity)
		elif entity.is_player == false and entity.is_dead == false:
			alive_enemies.append(entity)
	
	# check and return from the function after every check or else the signals will
	# emit multiple times, we only need it to emit once to load up new set of enemies!
	if alive_enemies.is_empty():
		ManagerGame.wave_finished.emit(true)
		return
	if alive_players.is_empty():
		ManagerGame.wave_finished.emit(false)
		return
	
	# here we basically just removed the first entity in the array ( because they already made their move )
	# and push them at the back of the array, they will wait for their turn again
	var first = turns_arrangement.pop_front()
	turns_arrangement.push_back(first)
	
	# after the array has shifted, the previously second entity that were waiting for their turn,
	# are now at the first place, so they will now execute their turn
	if turns_arrangement[0].is_player and turns_arrangement[0].is_dead == false:
		$UI.pop_bottom_panel(turns_arrangement[0])
	else:
		$UI.hide_bottom_panel()
		turns_arrangement[0].choose_random_player_attack()
