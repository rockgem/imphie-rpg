extends Buff



func activate():
	get_parent().get_parent().data['attack'] += 5


func delete_buff():
	get_parent().get_parent().data['attack'] -= 5
