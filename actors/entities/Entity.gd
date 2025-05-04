extends Node2D
class_name Entity

# this signal can be used to detect when this entity is clicked
# currently being used in when the player's character are choosing which enemy to attack!
# we always pass in the self reference as parameter so we can access this entity and its entire
# values such as the "data"
signal clicked(own)


@export var is_player = true
@export var is_dead = false

# in this dictionary, we store the entity's hp, mana, exp etc.
var data = {}


func _ready() -> void:
	if data.is_empty():
		return
	
	$Sprite2D/Name.text = '%s' % data['name']
	
	# dynamically loading the entity's textures ( see reso://sprites/entities )
	# these are just bunch of AtlasTextures using the entity's "name" to load the appropriate sprite
	# for now, this is the easy way of loading it since the sprites are static and have no animations yet.
	# in the future, is you want the mobs and characters to move, you will be using AnimatedSprite2D node
	# and instead of loading an AtlasTexture, you will be loading a SpriteFrames resource instead ( this is a bit more advanced )
	$Sprite2D.texture = load("res://reso/sprites/entities/%s.tres" % data['name'])
	
	if is_player == false:
		$Sprite2D.flip_h = true


func receive_damage(damage = 1):
	data['hp'] -= damage
	
	var df = load('res://actors/objs/DamageFloater.tscn').instantiate()
	df.get_node('Label').text = '%s' % int(damage)
	
	add_child(df)
	
	if data['hp'] <= 0:
		is_dead = true
		data['hp'] = 0
		
		hide()
		
		#queue_free()


func attack(entity: Entity):
	var t = create_tween()
	t.tween_property($Sprite2D, 'global_position', entity.global_position, .2)
	t.tween_property($Sprite2D, 'global_position', global_position, .2)
	
	await t.step_finished
	var damage_rate = randi_range(data['attack'] - 2, data['attack'] + 2)
	entity.receive_damage(damage_rate)
	
	await t.finished
	
	# this signal needs to be emmitted after every action such as; attacking, healing or even skipping a turn
	# so that the game will be able tell that the next queued entity is next to do their thing.
	# see ( World.gd -> on_entity_action_finished() function )
	ManagerGame.entity_action_finished.emit()


func add_buff():
	pass


# this is only going to be used for ENEMY type entities,
# it automatically attacks random player characters
func choose_random_player_attack():
	
	# check if the entity is already dead, if so, skip the action by calling entity_action_finished
	if is_dead:
		ManagerGame.entity_action_finished.emit()
		return
	
	var entities = get_tree().get_nodes_in_group("Entity")
	var players: Array[Entity] = []
	
	for e: Entity in entities:
		if e.is_player and e.is_dead == false:
			players.append(e)
	
	players.shuffle()
	attack(players[0])


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch and !event.pressed:
		if ManagerGame.global_main_world_ref.turns_arrangement[0].is_player and is_player == false:
			ManagerGame.global_main_world_ref.turns_arrangement[0].attack(self)
		
		clicked.emit(self) # pass self reference
