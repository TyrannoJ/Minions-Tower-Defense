extends Area3D
var health:float=10000
var has_killed_emitted=false
signal base_killed
@onready var health_bar=$Health_bar
@onready var anti_health_bar=$anti_health_bar
@onready var rescue_timer=$rescue_timer
func get_damage(val):
	health-=val
	rescue_timer.start(5)
	Global.attack_on_base=true
	
	if health <=0:
		if !has_killed_emitted:
			
			
			base_killed.emit()
			has_killed_emitted=true
	var sca:float=float(health/10000)
	
	anti_health_bar.scale.x=1-sca
	health_bar.position.x=-(1-sca)
	health_bar.scale.x=sca
	
	anti_health_bar.position.x=sca


func _on_rescue_timer_timeout() -> void:
	Global.attack_on_base=false
