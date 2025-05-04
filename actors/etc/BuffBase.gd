extends Node
class_name Buff

# the amount of rounds the buff will remain
# if this counter goes to zero, the buff will automatically delete itself and will run
# the  delete_buff() function see: ( on_wave_finished() )
# NOTE: you can override this as well if needed, when creating a new buff script, just change this value on the activate() function
var rounds_remaining = 3


# NOTE: this is also one of the advanced techniques i use when making complex skills system
# this uses something called inheritance where you can only override certain functions to customize how
# scripts should behave, you must not override _ready() when creating a new buff script or state script
# you only need to override activate() and delete_buff() functions, write your scripts there.
# see ( BuffAttack.gd )

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ManagerGame.wave_finished.connect(on_wave_finished)
	
	activate()

# meant to be overriden by scripts that inherits this class -- !!
func activate():
	pass

# meant to be overriden by scripts that inherits this class -- !!
func delete_buff():
	pass


func on_wave_finished(is_win: bool):
	rounds_remaining -= 1
	
	if rounds_remaining <= 0:
		delete_buff()
		queue_free()
