extends Node2D


func _ready() -> void:
	var t = create_tween()
	t.tween_property(self, 'global_position:y', global_position.y - 32.0, .3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.tween_property(self, 'modulate:a', modulate.a, .3).set_delay(1.0)
	
	await t.finished
	
	queue_free()
