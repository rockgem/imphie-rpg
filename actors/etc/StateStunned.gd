extends Buff




func activate():
	get_parent().can_move = false


func delete_buff():
	get_parent().can_move = true


func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.hide()
