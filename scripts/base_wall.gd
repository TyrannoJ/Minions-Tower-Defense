extends Area3D

var health:float=1000

signal kill

func get_damage(val):
	health-=val
	
	
	
	
		
	Global.attack_on_base=true
	
	if health <=0:
		kill.emit()
	
	
	
