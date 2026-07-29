extends Area3D

var health:float=10

signal kill

func get_damage(val):
	health-=val
	print("a")
	
	Global.attack_on_base=true
	
	if health <=0:
		kill.emit()
	
	
	
