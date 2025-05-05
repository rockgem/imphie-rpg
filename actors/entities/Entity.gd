extends Node2D
class_name Entity

# this signal can be used to detect when this entity is clicked
# currently being used in when the player's character are choosing which enemy to attack!
# we always pass in the self reference as parameter so we can access this entity and its entire
# values such as the "data"
signal clicked(own)
signal buff_added(buff_ref)


@export var is_player = true
@export var is_dead = false
var can_move = true

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
		
		# we get the previous entity that did an action
		# which means the the entity killed this one
		var last_entity: Entity = ManagerGame.global_main_world_ref.turns_arrangement.front()
		last_entity.gain_exp(randf_range(10, 25))
		
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


func gain_exp(exp = 1):
	data['exp'] += exp
	
	# if this hero reaches max exp, level up by one and reset exp counter
	if data['exp'] > data['exp_max']:
		data['exp'] = 0.0
		data['level'] += 1
		data['exp_max'] *= 1.2
	
	$ExpEffect.play("default")


func add_buff(buff: Buff):
	buff.add_to_group('Buff')
	
	add_child(buff)
	buff_added.emit(buff)


func reduce_buff_remaining():
	var buffs = get_tree().get_nodes_in_group('Buff')
	if buffs.is_empty() == false:
		var buff: Buff = buffs[0]
		
		buff.reduce_remaining()


# this is only going to be used for ENEMY type entities,
# it automatically attacks random player characters
func choose_random_player_attack():
	reduce_buff_remaining()
	
	if can_move == false:
		ManagerGame.entity_action_finished.emit()
		return
	
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
		var entity_id = ''
		if is_player:
			entity_id = 'team'
		else:
			entity_id = 'enemy'
		
		# checks if the selected skill allows targeting of valid entities ( see skill's data at skills_data.json -> "target": [] )
		# returns from function if this entity isn't in the skill's target list
		if ManagerGame.global_ui_ref.current_skill_selected['target'].has(entity_id) == false:
			return
		
		# reduce the skill's usage
		# do not reduce usage when its just the normal attack
		if ManagerGame.global_ui_ref.current_skill_selected['name'] != 'Attack':
			ManagerGame.global_ui_ref.current_skill_selected['uses_count'] -= 1
		
		# NOTE: states such as "stunned" is still considered as a "buff" because buffs and state essentially works
		# the same under the hood, bacause they disappear at a certain period/turn and executes an effect on _ready()
		if ManagerGame.global_ui_ref.current_skill_selected.has('skill_script'):
			var state: Buff = load(ManagerGame.global_ui_ref.current_skill_selected['skill_script']).instantiate()
			state.icon = load(ManagerGame.global_ui_ref.current_skill_selected['icon'])
			# add the buff on this entity itself
			# the buff will automatically execute its own code since it is in its own script/node ( _ready() )
			add_buff(state)
		
		# for now, there are just simple 4-types of attack, if ever the skills gets more complicated
		# a different approach may be needed, perhaps it may need to have separate scripts for each skills.
		# but for now, its not that complicated. this will work just fine.
		match ManagerGame.global_ui_ref.current_skill_selected['name']:
			'Attack':
				if ManagerGame.global_main_world_ref.turns_arrangement[0].is_player and ManagerGame.global_main_world_ref.turns_arrangement[0] != self:
					ManagerGame.global_main_world_ref.turns_arrangement[0].attack(self)
			"Heal":
				var heal_amount = 100
				
				$HealFX.play("default")
				data['hp'] = clamp(data['hp'] + heal_amount, 0, data['hp_max'])
				
				var df = load('res://actors/objs/HealFloater.tscn').instantiate()
				df.get_node('Label').text = '%s' % int(heal_amount)
				add_child(df)
				
				ManagerGame.entity_action_finished.emit()
			"Bolt":
				ManagerGame.entity_action_finished.emit()
			"Buff":
				ManagerGame.entity_action_finished.emit()
		
		ManagerGame.global_main_world_ref.turns_arrangement[0].reduce_buff_remaining()
		
		clicked.emit(self) # pass self reference
