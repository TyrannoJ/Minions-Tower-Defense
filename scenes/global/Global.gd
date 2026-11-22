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
signal add_player(pos)
signal add_enemy(pos)
var red_coords=[]
var camera_position:Vector3
var show_name_tag=false
var navigation_list=[]
var navigation_block_list=[]
var containment_size:int=5
var containment=true
var player_number=2
var enemy_number=0
const MAX_PLAYERS=30
const MAX_ENEMYS=40
var score=100
var show_containment=true
var explanations=false
var fences=[]
signal fence_built(position:Vector3)
var catapults=[]
var object_under_mouse
var delete_mode=""
var enemys_spawned=0
var enemys_to_spawn=10
var max_player_count=10
var build_mode=0
var spawner_positions=[]
var visible_spawners=[]
var round_number=0
var max_spawner_count=3
var towers=[]
var build_spots:=[]
signal build_destroyed(pos,type)
func _ready() -> void:
	
	for x in range(0,280):
		build_spots.append([])
		for z in range(-90,91):
			build_spots[x].append(false)
		
func restart():
	target_pos=Vector3.ZERO
	current_tool=0
	show_health=false
	focused=null
	attack_on_base=false
	dragging=false
	red_coords=[]
	show_name_tag=false
	containment_size=5
	containment=true
	score=0
	enemys_spawned=0
	spawner_positions=[]
	visible_spawners=[]
	round_number=0
	enemys_spawned=0
	enemys_to_spawn=10
	max_player_count=10
	max_spawner_count=3
	towers=[]
	fences=[]
	catapults=[]
	build_spots.clear()
	for x in range(0,280):
		build_spots.append([])
		for z in range(-90,91):
			build_spots[x].append(false)
