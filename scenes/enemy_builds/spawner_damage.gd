extends Area3D

var health:float=2000
var emitted=false
signal kill

func initialize(start_health):
	health=start_health
func get_damage(val):
	health-=val
	if health <=0 and !emitted:
		kill.emit()
		emitted=true
