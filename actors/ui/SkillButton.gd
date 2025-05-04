extends Button
class_name SkillButton

var data = {}


func _physics_process(delta: float) -> void:
	if data['uses_count'] <= 0:
		disabled = true
	else:
		disabled = false
