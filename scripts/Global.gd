extends Node
var target_pos=Vector3(0,0,0)
signal update_target(selected_color,selected_number)
signal clicked(color,number)
var attack_on_base=false
#var target_positions_blue=[]
#var blue_position
var current_tool=0
var show_health:bool
var focused:Node3D
var drag_pos:Vector3
var dragging=false
var base:Vector3
signal add_player
signal add_enemy(pos)
var red_coords=[]
var camera_position:Vector3
var show_name_tag=false


	
func restart():
	target_pos=Vector3.ZERO
	current_tool=0
	show_health=false
	focused=null
	attack_on_base=false
	dragging=false
	red_coords=[]
	show_name_tag=false
	
