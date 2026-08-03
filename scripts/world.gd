extends Node3D

@export var person:PackedScene
@export var obstacle_wall:PackedScene
@export var weapon:PackedScene
@onready var camera =$Camerapivot/Camera3D
@onready var camera_pivot =$Camerapivot
@onready var character_view=$CanvasLayer/character_view
@onready var name_label=$CanvasLayer/character_view/Panel/character_view/Name_Label
@onready var color_label=$CanvasLayer/character_view/Panel/character_view/Color_Label
@onready var weapon_label=$CanvasLayer/character_view/Panel/character_view/Weapon_Label
@onready var kill_label=$CanvasLayer/character_view/Panel/character_view/Kill_Label
@onready var health_bar=$CanvasLayer/character_view/Panel/character_view/Health_bar
@onready var click_marker=$click_marker
@onready var release_marker=$release_marker
@onready var drag_marker=$dragMmarker
@onready var tool_label=$CanvasLayer/ToolBar/Panel/HBoxContainer/Tool_Label
@onready var wall_up=$Walls/Wall1
@onready var wall_down=$Walls/Wall2
@onready var wall_left=$Walls/Wall3
@onready var wall_right=$Walls/Wall4
@onready var size_slider=$CanvasLayer/Controls/VBoxContainer/Size_slider
@onready var health_checkbox=$CanvasLayer/Controls/VBoxContainer/show_health
@onready var time_slider=$CanvasLayer/Controls/VBoxContainer/Time_slider
@onready var real_drag_marker=$real_drag_marker
@onready var target_area=$Ground/set_target
@onready var loose_screen=$CanvasLayer/loose_screen
@onready var base_health_label=$CanvasLayer/ToolBar/base_health
@onready var red_label=$CanvasLayer/ToolBar/red_label
@onready var blue_label=$CanvasLayer/ToolBar/blue_label
@export var wall_piece:PackedScene
@export var base_scene:PackedScene
@onready var base:Node3D
@onready var base_health=$CanvasLayer/ToolBar/health_bar
@onready var anti_base_health=$CanvasLayer/ToolBar/anti_health_bar
var start_base_health=8000
var drawings=[]
var loose=false
var player_number=2
var current_unique_id=player_number
var blue_persons=[]
var red_persons=[]
var sensitivity=.005

var slowed=false
var current_player:Node3D
var klick_pos:Vector3
var release_pos:Vector3
var start_size=30
var weapons=[]
var obstacles=[]
var tools=["normal","draw","create_areas","draw"]
var wall_positions=[Vector3(start_size,2.5,0),Vector3(-start_size,2.5,0),Vector3(0,2.5,start_size),Vector3(0,2.5,-start_size)]

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		#camera_pivot.rotate_y(-event.relative.x * sensitivity)
		#if -event.relative.x>0:
			#if $Animated_Bayer/AnimationPlayer.current_animation=="Idle":
				#$Animated_Bayer/AnimationPlayer.play("Action_007")
		#camera.rotate_x(-event.relative.y * sensitivity)
		
		
		camera.rotation.x = clamp(camera.rotation.x, -PI,PI)
		camera.rotation.y = clamp(camera.rotation.y, -PI,PI)

func _ready() -> void:
	#var walls=[wall_up,wall_down,wall_left,wall_right]
	#for wa in walls:
	#	wa.scale.z=start_size*2
	add_base()
	Global.clicked.connect(on_player_clicked)
	Global.add_player.connect(add_player)
	Global.base=base.global_position
	spawn_players()
	spawn_obstacles()
	spawn_weapons()
	
func add_base():
	if base !=null:
		base.queue_free()
	base=base_scene.instantiate()
	add_child(base)
	base.position=Vector3(0,2,0)
	base.base_killed.connect(base_killed)
func spawn_weapons():
	if weapons !=[]:
		for we in weapons:
			if we !=null:
				we.queue_free()
	weapons.clear()
	for i in range (0,player_number):
		var we=weapon.instantiate()
		add_child(we)
		we.position.x=randi_range(-25,25)
		we.position.z=randi_range(-13,13)
		we.position.y=2
		weapons.append(we)
func spawn_obstacles():
	if obstacles !=[]:
		for obs in obstacles:
			obs.queue_free()
	obstacles.clear()
	for x in range(-3,4):
		for y in range(-2,3):
			if randi_range(0,3)!=0:
				var obs=obstacle_wall.instantiate()
				
				#add_child(obs)
				obs.scale.x=randf_range(3,7)
				obs.rotation.y=randf_range(-PI,PI)
				obs.position=Vector3(randf_range(x*10-2,x*10+2),0,randf_range(y*10-2,y*10+2))
				obstacles.append(obs)
func spawn_players():
	var unique_id=0
	if red_persons !=[]:
		for re in red_persons:
			re.queue_free()
	red_persons.clear()
	if blue_persons !=[]:
		for blu in blue_persons:
			blu.queue_free()
	blue_persons.clear()
	
	for i in range(0,player_number/2):
		
		var re=person.instantiate()
		var blu=person.instantiate()
		red_persons.append(re)
		blue_persons.append(blu)
		add_child(red_persons[i])
		add_child(blue_persons[i])
		
		
		blue_persons[i].number=i
		blue_persons[i].color="blue"
		blue_persons[i].position=Vector3(randi_range(10,20),2,randi_range(-13,13))
		blue_persons[i].initialize()
		
		blue_persons[i].unique_id=unique_id+player_number/2
		blue_persons[i].killed.connect(delete_player)
		
		
		red_persons[i].number=i
		
		red_persons[i].color="red"
		red_persons[i].position=Vector3(randi_range(-10,-20),2,randi_range(-13,13))
		red_persons[i].unique_id=unique_id
		red_persons[i].killed.connect(delete_player)
		red_persons[i].initialize()
		unique_id+=1
func _process(delta: float) -> void:
	#print(target_area.position.y)
	#print(Engine.get_frames_per_second())
	find_red_players()#
	if !loose:
		show_base_health()
	Engine.time_scale=time_slider.value
	red_label.text=str(len(red_persons))
	blue_label.text=str(len(blue_persons))
	if current_player != null:
		
		show_player_stats()
	handle_movement()
	handle_tools()
	#set_map_size()
	handle_time()
func handle_time():
	if Input.is_action_pressed("time_up"):
		time_slider.value+=0.01
	if Input.is_action_pressed("time_down"):
		time_slider.value-=0.01
	Engine.time_scale=time_slider.value
	
func handle_tools():
	if Input.is_action_just_pressed("select all"):
		for re in red_persons:
			if re !=null:
				re.clicked=true
		for blu in blue_persons:
			if blu !=null:
				blu.clicked=true
	if Input.is_action_just_pressed("select red"):
		for re in red_persons:
			re.clicked=true
	if Input.is_action_just_pressed("select blue"):
		for blu in blue_persons:
			blu.clicked=true
	
	if Input.is_action_just_pressed("tool_up"):
		
		if Global.current_tool<2:
			Global.current_tool+=1
		
	if Input.is_action_just_pressed("tool_down"):
		if Global.current_tool>0:
			Global.current_tool-=1
	
	tool_label.text=str(tools[Global.current_tool])
func handle_movement():
	if Input.is_action_pressed("forward"):
		camera_pivot.position.z-=0.3
	if Input.is_action_pressed("back"):
		camera_pivot.position.z+=0.3
	if Input.is_action_pressed("left"):
		camera_pivot.position.x-=0.3
	if Input.is_action_pressed("right"):
		camera_pivot.position.x+=0.3
	if Input.is_action_pressed("up"):
		camera_pivot.position.y+=0.3
	if Input.is_action_pressed("down"):
		camera_pivot.position.y-=0.3
func set_map_size():
	wall_positions[0].x=size_slider.value
	wall_positions[1].x=-size_slider.value
	wall_positions[2].z=size_slider.value
	wall_positions[3].z=-size_slider.value
	wall_up.position=wall_positions[0]
	wall_down.position=wall_positions[1]
	wall_left.position=wall_positions[2]
	wall_right.position=wall_positions[3]
	var walls=[wall_up,wall_down,wall_left,wall_right]
	for wa in walls:
		wa.scale.z=size_slider.value*2


func _on_set_target_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	
	if Global.current_tool==1:
		target_area.position.y=5
		if event is InputEventMouseMotion and event.button_mask==1:
			draw(event_position)

	if Global.current_tool==0:
		if event is InputEventMouseMotion and event.button_mask==1:
			
			start_dragging(event_position)
		else:
			Global.dragging=false
			target_area.position.y=0
		if event is InputEventMouseMotion and event.button_mask==MOUSE_BUTTON_MASK_MIDDLE :
			
			start_marking(event_position)
		else:
			if !Global.dragging:
				target_area.position.y=0
		if event is InputEventMouseButton and event.is_pressed() and event.button_index==3:
			set_drag_start_point(event_position)
			
		if event is InputEventMouseButton and event.is_released() and event.button_index==3:
			release_pos=event_position
			if release_pos!=klick_pos and Global.current_tool==0:
				mark_players(event_position)
				
		if event is InputEventMouseButton and event.is_released() and event.button_index==2:
			set_target(event_position)



func set_drag_start_point(event_position):
	klick_pos=event_position
	click_marker.position=event_position
	click_marker.position.y=2
	target_area.position.y=5
		
func mark_players(event_position):
	if !Input.is_action_pressed("hold"):
		for p in all_players():
			p.clicked=false
			Global.focused=null
	release_marker.position=event_position
	release_marker.position.y=2
	#release_marker.show()
	
	
	for pe in red_persons:
		if pe !=null:
			if is_in_area(pe.position,klick_pos,release_pos):
				#pe.clicked=true
				pass
	for pe in blue_persons:
		if pe != null:
			if is_in_area(pe.position,klick_pos,release_pos):
				pe.clicked=true
	release_marker.hide()
	click_marker.hide()
	drag_marker.hide()
	
func set_target(event_position):
	click_marker.hide()
	
	var selected_color=[]
	var selected_number=[]
	for pe in red_persons:
		if pe !=null:
			if pe.clicked:
				selected_color.append("red")
				selected_number.append(pe.number)
				pe.clicked=false
	for pe in blue_persons:
		if pe != null:
			if pe.clicked:
				selected_color.append("blue")
				selected_number.append(pe.number)
				pe.clicked=false
	$Sword.position=event_position
	$Sword.position.y=2
	Global.target_pos=event_position
	Global.update_target.emit(selected_color,selected_number)	
		
func start_dragging(event_position):
	Global.drag_pos=real_drag_marker.position
	real_drag_marker.position=event_position
	real_drag_marker.position.y=2
	Global.dragging=true	
	target_area.position.y=5	
	
func start_marking(event_position):
	drag_marker.show()
	drag_marker.position.y=5
	drag_marker.position.x=klick_pos.x-(klick_pos.x-event_position.x)/2
	drag_marker.position.z=klick_pos.z-(klick_pos.z-event_position.z)/2
	drag_marker.scale.x=abs((klick_pos.x-event_position.x))
	drag_marker.scale.z=abs((klick_pos.z-event_position.z))
	target_area.position.y=5
	
func show_player_stats():
	if current_player !=null:
		character_view.show()
	name_label.text=str(current_player.number)
	color_label.text=current_player.color
	weapon_label.text=str(current_player.has_weapon)
	kill_label.text=str(current_player.kills)
	health_bar.value=current_player.health
	
	
func on_player_clicked(color,number):
	if color=="red":
		current_player=red_persons[number]
	elif color== "blue":
		current_player=blue_persons[number]
	Global.focused=current_player
func is_in_area(pos:Vector3,x:Vector3,y:Vector3):
	var higher_x=max(x.x,y.x)
	var lower_x=min(x.x,y.x)
	var higher_z=max(x.z,y.z)
	var lower_z=min(x.z,y.z)
	if pos.x<higher_x and pos.x>lower_x and pos.z>lower_z and pos.z<higher_z:
		return true
	else:
		return false


func all_players():
	var result=[]
	for re in red_persons:
		result.append(re)
	for blu in blue_persons:
		result.append(blu)
	return result
	
func delete_player(color,number,attacker):
	
	for p in all_players():
		if p.unique_id==attacker:
			p.kills+=1
	if color=="red":
		if current_player==red_persons[number]:
			reset_stat_board()
		red_persons[number].queue_free()
		red_persons.pop_at(number)
		generate_new_numbers_red()
	elif color=="blue":
		if current_player==blue_persons[number]:
			reset_stat_board()
		blue_persons[number].queue_free()
		blue_persons.pop_at(number)
		generate_new_numbers_blue()
		
	
	
func generate_new_numbers_blue():
	
	for i in range(0,len(blue_persons)):
		blue_persons[i].number=i
	
	
		
func generate_new_numbers_red():
	
	for i in range(0,len(red_persons)):
		red_persons[i].number=i
	
	
func add_player():
	if len(all_players())<140:
		var blu=person.instantiate()
		
		blue_persons.append(blu)
		
		add_child(blue_persons[len(blue_persons)-1])
		
		blue_persons[len(blue_persons)-1].get_node("Blue").show()
		blue_persons[len(blue_persons)-1].number=len(blue_persons)-1
		blue_persons[len(blue_persons)-1].color="blue"
		blue_persons[len(blue_persons)-1].position=Vector3(0,2,0)
		
		blue_persons[len(blue_persons)-1].unique_id=current_unique_id
		current_unique_id+=1
		blue_persons[len(blue_persons)-1].killed.connect(delete_player)
func _on_show_health_toggled(toggled_on: bool) -> void:
	Global.show_health=toggled_on
func draw(event_position):
	var ma=wall_piece.instantiate()
	add_child(ma)
	ma.position=event_position
	ma.position.y=2
	drawings.append(ma)
	
func base_killed():
	base.queue_free()
	loose=true
	show_loose_screen()
func show_loose_screen():
	loose_screen.show()


func _on_restart_pressed() -> void:
	loose_screen.hide()
	loose=false
	current_unique_id=player_number
	Global.restart()
	add_base()
	Global.base=base.global_position
	current_player=null
	spawn_players()
	spawn_obstacles()
	spawn_weapons()
	health_checkbox.button_pressed=false
	time_slider.value=1
	size_slider.value=40
	reset_stat_board()
func reset_stat_board():
	name_label.text=""
	color_label.text=""
	weapon_label.text=""
	kill_label.text=""
	health_bar.value=0
	character_view.hide()
	

func show_base_health():
	var sca:float=float(base.health/start_base_health)
	sca=sca*690
	anti_base_health.size.x=690
	#base_health.position.x=-(1-sca)
	base_health.size.x=sca
	base_health_label.text=str(int(base.health))
	#anti_base_health.position.x=sca
func find_red_players():
	Global.red_coords=[]
	for re in red_persons:
		if re.show_location:
			Global.red_coords.append(re.position)
