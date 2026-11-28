extends Node

var number=3

func increment():
	await get_tree().create_timer(randf_range(1,2)).timeout
	if Global.player_number+number < Global.MAX_PLAYERS and Global.player_number+number<Global.max_player_count:
		number+=1
	increment()
func start():
	
	increment()
	#number=20


func reset():
	number=0
	
