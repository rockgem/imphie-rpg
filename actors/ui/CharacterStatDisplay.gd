extends VBoxContainer


@onready var exp_bar = $EXPBar


var entity_ref: Entity = null



func _ready() -> void:
	if entity_ref == null:
		return
	
	$Stats/HPBar/Name.text = '%s' % entity_ref.data['name']
	
	# if the entity is an enemy, set the hp bar to display reverse
	if entity_ref.is_player == false:
		$Stats/HPBar.fill_mode = $Stats/HPBar.FILL_END_TO_BEGIN
		$EXPBar.fill_mode = $EXPBar.FILL_END_TO_BEGIN


func _physics_process(delta: float) -> void:
	
	# here we constantly listen for changes of the entity's hp, mana, etc.
	# the actual values that changes these are found in the entity's node itself ( Entity.tscn instance ) see ( World.tscn -> load_player_data() function )
	# see also; ( Entity.tscn -> receive_damage() function )
	if entity_ref != null:
		$Stats/HPBar/Name.text = '%s Lv.%s' % [entity_ref.data['name'], int(entity_ref.data['level'])]
		
		$Stats/HPBar.value = entity_ref.data['hp']
		$Stats/HPBar.max_value = entity_ref.data['hp_max']
		
		$Stats/HPBar/HPCurrent.text = '%s' % int(entity_ref.data['hp'])
		$Stats/HPBar/HPMax.text = '%s' % int(entity_ref.data['hp_max'])
		
		$EXPBar.value = entity_ref.data['exp']
		$EXPBar.max_value = entity_ref.data['exp_max']
		
		# set the text of the entity's HP to "DEAD" when their hp is 0
		if entity_ref.data['hp'] <= 0:
			$Stats/HPBar/HPCurrent.text = 'DEAD'
