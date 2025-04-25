extends Node

var default_offset = 8.0
var default_speed = 0.3



func animate_slide_from_left(node, offset = default_offset, speed = default_speed):
	node.position.x = -node.size.x
	
	var t = create_tween()
	t.tween_property(node, 'position:x', default_offset, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_slide_to_left(node, offset = default_offset, speed = default_speed):
	var t = create_tween()
	t.tween_property(node, 'position:x', -node.size.x, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished


func animate_slide_from_right(node, offset = default_offset, speed = default_speed):
	node.position.x = get_viewport().size.x
	
	var vp_size = get_viewport().get_visible_rect().size.x
	
	var t = create_tween()
	t.tween_property(node, 'position:x', (vp_size - node.size.x) - default_offset, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished


func animate_slide_to_right(node, offset = default_offset, speed = default_speed):
	var t = create_tween()
	t.tween_property(node, 'position:x', get_viewport().size.x, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	return t.finished


func animate_pop(node):
	node.scale = Vector2.ZERO
	
	var t = create_tween()
	t.tween_property(node, 'scale', Vector2.ONE, default_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return t.finished
