extends VBoxContainer


var entity_ref: Entity = null



func _ready() -> void:
	if entity_ref == null:
		return
	
	$Stats/HPBar/Name.text = '%s' % entity_ref.data['name']


func _physics_process(delta: float) -> void:
	
	# here we constantly listen for changes of the entity's hp, mana, etc.
	# the actual values that changes these are found in the entity's node itself ( Entity.tscn instance ) see ( World.tscn -> load_player_data() function )
	# see also; ( Entity.tscn -> receive_damage() function )
	if entity_ref != null:
		$Stats/HPBar.value = entity_ref.data['hp']
		$Stats/HPBar.max_value = entity_ref.data['hp_max']
		
		$Stats/HPBar/HPCurrent.text = '%s' % int(entity_ref.data['hp'])
		$Stats/HPBar/HPMax.text = '%s' % int(entity_ref.data['hp_max'])
		
		$ManaBar.value = entity_ref.data['mana']
		$ManaBar.max_value = entity_ref.data['mana_max']
