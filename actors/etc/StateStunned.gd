extends Buff




func activate():
	pass


func delete_buff():
	get_parent().data['attack'] -= 5


func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.hide()
