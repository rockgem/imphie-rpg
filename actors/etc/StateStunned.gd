extends Buff




func activate():
	pass


func delete_buff():
	get_parent().data['attack'] -= 5
