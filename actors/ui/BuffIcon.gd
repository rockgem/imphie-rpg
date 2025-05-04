extends TextureRect


var buff_ref: Buff

func _ready() -> void:
	buff_ref.tree_exiting.connect(on_tree_exiting)


func on_tree_exiting():
	queue_free()
