extends Node3D

@export var person:PackedScene
@export var obstacle_wall:PackedScene
@export var weapon:PackedScene
@onready var camera:Camera3D =$Camerapivot/Camera3D
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
@onready var size_slider=$CanvasLayer/Controls/Panel/VBoxContainer/Size_slider
@onready var health_checkbox=$CanvasLayer/Controls/Panel/VBoxContainer/show_health
@onready var show_name_tag=$CanvasLayer/Controls/Panel/VBoxContainer/show_name_tag
@onready var time_slider=$CanvasLayer/Controls/Panel/VBoxContainer/Time_slider
@onready var real_drag_marker=$real_drag_marker
@onready var target_area=$Ground/set_target
@onready var loose_screen=$CanvasLayer/loose_screen
@onready var base_health_label=$CanvasLayer/ToolBar/base_health
@onready var red_label=$CanvasLayer/ToolBar/red_label
@onready var blue_label=$CanvasLayer/ToolBar/blue_label
@export var wall_piece:PackedScene
@export var base_scene:PackedScene
@onready var base:Node3D
@export var tree:PackedScene
@onready var base_health=$CanvasLayer/ToolBar/health_bar
@onready var anti_base_health=$CanvasLayer/ToolBar/anti_health_bar
@export var control_area:PackedScene
@onready var enemy_spawns=$enemy_spawn_controller
@onready var wall_up_notifier=$Walls/Wall1/up
@onready var wall_down_notifier=$Walls/Wall2/down
@onready var wall_left_notifier=$Walls/Wall3/left
@onready var wall_right_notifier=$Walls/Wall4/right
@onready var player_spawner=$player_spawner
@onready var player_indicator=$player_indicator
@onready var klick_indicator=$klick_indicator
@onready var fps_label=$CanvasLayer/Controls/Panel/VBoxContainer/FPS
@onready var navigation_indicator=$navigation_indicator
@onready var containment_slider=$CanvasLayer/Controls/Panel/VBoxContainer/containment_slider
@onready var containment_box=$CanvasLayer/Controls/Panel/VBoxContainer/containment
@onready var score_label=$CanvasLayer/Score
@onready var control_panel=$CanvasLayer/Controls/Panel
@onready var controls=$CanvasLayer/Controls
@onready var menu=$CanvasLayer/menu
@onready var show_explanations=$CanvasLayer/Controls/Panel/VBoxContainer/show_explanations
@onready var final_score_label=$CanvasLayer/loose_screen/Panel/VBoxContainer/MarginContainer2/final_score_label
@onready var explanations=$CanvasLayer/explanations
@onready var navigation=$navigation
@onready var loading_screen=$CanvasLayer/Loading_screen
@onready var load_label=$CanvasLayer/Loading_screen/VBoxContainer/load_label
@onready var build_position_mesh=$build_position
@export var fence:PackedScene
@onready var build_bar=$CanvasLayer/build_bar
@export var catapult:PackedScene
@onready var tool_bar=$CanvasLayer/ToolBar
@onready var fence_button=$CanvasLayer/build_bar/Panel/HBoxContainer/fence_button
@onready var catapult_button=$CanvasLayer/build_bar/Panel/HBoxContainer/catapult_button
@onready var close_menu=$CanvasLayer/menu/Panel/close_menu
@onready var inputs=$CanvasLayer/inputs
@onready var round_label=$CanvasLayer/round
@export var score_number:PackedScene
@onready var start_button=$CanvasLayer/menu/Panel/VBoxContainer/MarginContainer/start
var round_number=1

var time_survived=0
var build_mode=0
const RAY_LENGTH=1000
var trees=[]
var start_base_health=8000
var drawings=[]
var loose=false
var player_number=1
var current_unique_id=player_number
var blue_persons=[]
var red_persons=[]
var sensitivity=.005
var current_area=0
var control_areas=[]
var slowed=false
var current_player:Node3D
var klick_pos:Vector3
var release_pos:Vector3
var start_size=30
var weapons=[]
var obstacles=[]
var important_controls=[]
var tools=["normal mode","build mode"]
var wall_positions=[Vector3(start_size,2.5,0),Vector3(-start_size,2.5,0),Vector3(0,2.5,start_size),Vector3(0,2.5,-start_size)]

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	
		#camera_pivot.rotate_y(-event.relative.x * sensitivity)
		#if -event.relative.x>0:
			#if $Animated_Bayer/AnimationPlayer.current_animation=="Idle":
				#$Animated_Bayer/AnimationPlayer.play("Action_007")
		#camera.rotate_x(-event.relative.y * sensitivity)
		
		
		#camera.rotation.x = clamp(camera.rotation.x, -PI,PI)
		#camera.rotation.y = clamp(camera.rotation.y, -PI,PI)
	
					
		

func _ready() -> void:
	important_controls=[tool_bar,controls,build_bar]
	#var walls=[wall_up,wall_down,wall_left,wall_right]
	#for wa in walls:
	#	wa.scale.z=start_size*2
	var screen=get_window().size
	$CanvasLayer/ToolBar.position.x=screen.x/2-343
	$CanvasLayer/Controls.position.x=screen.x-180
	
	print(screen)
	add_base()
	Global.clicked.connect(on_player_clicked)
	Global.add_player.connect(add_player)
	Global.add_enemy.connect(add_enemy)
	Global.base=base.global_position
	spawn_players()
	spawn_obstacles()
	loading_screen.show()
	menu.show()
	#spawn_weapons()
	
func _on_load_timer_timeout() -> void:
	
	load_label.text="loading trees..."
	#print("Loading trees...")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	await add_trees()
	print("Loading navigation...")
	load_label.text="loading navigation..."
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	await navigation.create_grid()
	
	loading_screen.hide()
	print("done")
	

func add_trees():
	if trees !=[]:
		for tre in trees:
			tre.queue_free()
	trees.clear()
	for x in range(-70,70):
		
		for y in range(-45,45):
			if (x>-60 and x<60) and(y>-35 and y<35):
				continue
			var tre=tree.instantiate()
				
			add_child(tre)
				
			var factor=2
			tre.position=Vector3(randf_range(x*factor+1,x*factor-1),2,randf_range(y*factor+1,y*factor-1))
			trees.append(tre)
	return true
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
	
	for i in range(0,player_number):
		
		#var re=person.instantiate()
		var blu=person.instantiate()
		#red_persons.append(re)
		blue_persons.append(blu)
		#add_child(red_persons[i])
		add_child(blue_persons[i])
		
		
		
		blue_persons[i].initialize(i,"blue",Vector3(randi_range(10,20),2,randi_range(-13,13)),unique_id)
		

		blue_persons[i].killed.connect(delete_player)
		
		
	
		#red_persons[i].killed.connect(delete_player)
		#red_persons[i].initialize(i,"red",Vector3(randi_range(-10,-20),2,randi_range(-13,13)),unique_id)
		unique_id+=1
func _process(delta: float) -> void:
	round_label.text="Round: "+str(round_number)
	if Input.is_action_just_pressed("menu"):
		close_menu.show()
		menu.show()
		start_button.disabled=true
		
	if get_mouse_raycast() !={}:
		Global.object_under_mouse=get_mouse_raycast().collider
	else:
		Global.object_under_mouse=null

	if loose==false:
		time_survived+=delta
	score_label.text=str(Global.score)
	#print(target_area.position.y)
	#print(Engine.get_frames_per_second())
	if Global.current_tool==0:
		target_area.position.y=5
		build_position_mesh.hide()
		build_bar.hide()
	elif Global.current_tool==1:
		build_bar.show()
		target_area.position.y=0
		handle_building()
		#build_position_mesh.show()
	hide_navigation_indicator()
	
	Global.containment_size=containment_slider.value
	Global.player_number=len(blue_persons)
	Global.enemy_number=len(red_persons)
	fps_label.text="FPS: "+str(Engine.get_frames_per_second())
	find_red_players()#
	if !loose:
		show_base_health()
	Engine.time_scale=time_slider.value
	red_label.text=str(len(red_persons))
	blue_label.text=str(len(blue_persons))
	if current_player != null:
		
		show_player_stats()
	if Global.explanations:
		explanations.show()
	else:
		explanations.hide()
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
	
	if Input.is_action_just_pressed("tool1"):
		Global.current_tool=0
	if Input.is_action_just_pressed("tool2"):
		Global.current_tool=1
		build_mode=0
	if Input.is_action_just_pressed("tool3"):
		Global.current_tool=2
	if Global.current_tool==0:
		tool_label.text="normal mode"
	else:
		tool_label.text="build mode"
		
	
	
	tool_label.text=str(tools[Global.current_tool])
func handle_movement():
	if Input.is_action_pressed("forward") and !wall_up_notifier.is_on_screen():
		camera_pivot.position.z-=0.3
	if Input.is_action_pressed("back") and !wall_down_notifier.is_on_screen():
		camera_pivot.position.z+=0.3
	if Input.is_action_pressed("left") and !wall_left_notifier.is_on_screen():
		camera_pivot.position.x-=0.3
	if Input.is_action_pressed("right") and !wall_right_notifier.is_on_screen():
		camera_pivot.position.x+=0.3
	if Input.is_action_pressed("up") and !wall_up_notifier.is_on_screen() and !wall_down_notifier.is_on_screen() and !wall_left_notifier.is_on_screen() and !wall_right_notifier.is_on_screen():
		camera_pivot.position.y+=0.3
	if Input.is_action_pressed("down") and camera_pivot.position.y>15:
		camera_pivot.position.y-=0.3
	Global.camera_position=camera_pivot.position
	
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
		if event is InputEventMouseButton and event.is_pressed() and event.button_index==1:
			
			#target_area.position.y=5
			#if event is InputEventMouseMotion and event.button_mask==1:
				#draw(event_position)
			var fe=fence.instantiate()
			add_child(fe)
			fe.position=Vector3(floorf(event_position.x),2,floorf(event_position.z))
			print("b")
	if Global.current_tool==2:
		target_area.position.y=5
		#target_area.position.y=3
		if event is InputEventMouseButton and event.is_pressed() and event.button_index==1:
			set_area_start_point(event_position)
		if event is InputEventMouseMotion and event.button_mask==1:
			make_area(event_position)
		
			
		if event is InputEventMouseButton and event.is_released() and event.button_index==1:
			finish_area(event_position)
	if Global.current_tool==0:
		if event is InputEventMouseMotion and event.button_mask==1:
			
			start_dragging(event_position)
			player_indicator.show()
			player_indicator.position.x=event_position.x
			player_indicator.position.z=event_position.z
			player_indicator.position.y=2
			
		else:
			Global.dragging=false
			target_area.position.y=5
			if !(event is InputEventMouseButton and event.is_pressed() and event.button_index==3):
				player_indicator.hide()
			
		if event is InputEventMouseMotion and event.button_mask==MOUSE_BUTTON_MASK_MIDDLE :
			
			start_marking(event_position)
			player_indicator.show()
			player_indicator.position.x=event_position.x
			player_indicator.position.z=event_position.z
			player_indicator.position.y=2
		else:
			if !Global.dragging:
				player_indicator.hide()
				target_area.position.y=5
				explanations.text=""
		if event is InputEventMouseButton and event.is_pressed() and event.button_index==3:
			set_mark_start_point(event_position)
			
		if event is InputEventMouseButton and event.is_released() and event.button_index==3:
			release_pos=event_position
			if release_pos!=klick_pos and Global.current_tool==0:
				mark_players(event_position)
				player_indicator.hide()
				
		if event is InputEventMouseButton and event.is_released() and event.button_index==2:
			set_target(event_position)



func hide_navigation_indicator():
	var hiding=true
	for pe in blue_persons:
		if pe.new_pathfinding:
			hiding=false
	if hiding:
		navigation_indicator.hide()
			
	
func set_target(event_position):
	click_marker.hide()
	navigation_indicator.position=event_position
	navigation_indicator.position.y=2
	navigation_indicator.show()
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
	
	Global.target_pos=event_position
	Global.update_target.emit(selected_color,selected_number)	
	
func set_mark_start_point(event_position):
	target_area.position.y=5
	print(target_area.position.y)
	klick_pos=Vector3.ZERO
	
	#klick_pos.y=5
	#klick_indicator.position=klick_pos
	#klick_indicator.position.y=2
	#click_marker.position=event_position
	#click_marker.position.y=5
		

	
func start_marking(event_position):
	explanations.text="mark players"
	if klick_pos==Vector3.ZERO:
		klick_pos=event_position
		klick_indicator.position=klick_pos
		klick_indicator.position.y=2
		klick_indicator.show()
	drag_marker.show()
	drag_marker.position.y=2
	drag_marker.position.x=klick_pos.x-(klick_pos.x-event_position.x)/2
	drag_marker.position.z=klick_pos.z-(klick_pos.z-event_position.z)/2
	drag_marker.scale.x=abs((klick_pos.x-event_position.x))
	drag_marker.scale.z=abs((klick_pos.z-event_position.z))
	target_area.position.y=5
	
func mark_players(event_position):
	if !Input.is_action_pressed("hold"):
		for p in all_players():
			p.clicked=false
			Global.focused=null
	release_marker.position=event_position
	release_marker.position.y=2
	#release_marker.show()
	klick_indicator.hide()
	
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
	
	
	
	
func set_area_start_point(event_position):
	klick_pos=event_position
	click_marker.position=event_position
	click_marker.position.y=5
	target_area.position.y=5
	var ar=control_area.instantiate()
	add_child(ar)
	control_areas.append(ar)
	
func start_dragging(event_position):
	explanations.text="players follow you"
	real_drag_marker.position=event_position
	Global.drag_pos=real_drag_marker.position
	real_drag_marker.position.y=5
	Global.dragging=true	
	target_area.position.y=5	
	

func make_area(event_position):
	#target_area.position.y=5
	
	if len(control_areas)==current_area:
		var ar=control_area.instantiate()
		add_child(ar)
		control_areas.append(ar)
	control_areas[current_area].show()
	control_areas[current_area].position.y=3
	control_areas[current_area].position.x=klick_pos.x-(klick_pos.x-event_position.x)/2
	control_areas[current_area].position.z=klick_pos.z-(klick_pos.z-event_position.z)/2
	control_areas[current_area].scale.x=abs((klick_pos.x-event_position.x))
	control_areas[current_area].scale.z=abs((klick_pos.z-event_position.z))
	

func finish_area(event_position):
	
	control_areas[current_area].under_creation=false
	current_area+=1
	release_marker.position=event_position
	release_marker.position.y=2
	target_area.position.y=2
	release_marker.hide()
	click_marker.hide()
	
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
	
func delete_player(color,number,attacker,pos):
	
	for p in all_players():
		if p.unique_id==attacker:
			p.kills+=1
	if color=="red":
		Global.score +=1
		
		if current_player==red_persons[number]:
			reset_stat_board()
		red_persons[number].queue_free()
		red_persons.pop_at(number)
		generate_new_numbers_red()
		var sco=score_number.instantiate()
		sco.position=Vector3(pos.x,6,pos.z)
		sco.initialize(1,Color.RED)
		add_child(sco)
		var tween=get_tree().create_tween()
		tween.tween_property(sco,"scale",Vector3(8,8,8),0.2)
		
		await tween.finished
		await get_tree().create_timer(0.3).timeout
		sco.queue_free()
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
	
	
func add_player(pos):
	if len(all_players())<70:
		var blu=person.instantiate()
		
		blue_persons.append(blu)
		
		add_child(blue_persons[len(blue_persons)-1])
		blue_persons[len(blue_persons)-1].initialize(len(blue_persons)-1,"blue",pos,current_unique_id)

		current_unique_id+=1
		blue_persons[len(blue_persons)-1].killed.connect(delete_player)
		
func add_enemy(pos):
	if len(all_players())<70:
		var blu=person.instantiate()
		Global.enemys_to_spawn-=1
		red_persons.append(blu)
		
		add_child(red_persons[len(red_persons)-1])
		red_persons[len(red_persons)-1].initialize(len(red_persons)-1,"red",pos,current_unique_id)
		current_unique_id+=1
		red_persons[len(red_persons)-1].killed.connect(delete_player)
		if Global.enemys_to_spawn <=0:
			start_new_round()
		
		
		
func _on_show_health_toggled(toggled_on: bool) -> void:
	Global.show_health=toggled_on
func draw(event_position):
	var ma=wall_piece.instantiate()
	add_child(ma)
	ma.position=event_position
	ma.position.y=2
	drawings.append(ma)
	
func base_killed():
	
	loose=true
	show_loose_screen()
func show_loose_screen():
	var minutes=floorf(time_survived/60)
	var seconds=int(time_survived)%60
	final_score_label.text="Time Survived: "+str(minutes)+"m" + str(seconds)+"s"
	loose_screen.show()


func _on_restart_pressed() -> void:
	base.queue_free()
	loose_screen.hide()
	loose=false
	current_unique_id=player_number
	Global.restart()
	add_base()
	Global.base=base.global_position
	current_player=null
	spawn_players()
	spawn_obstacles()
	#spawn_weapons()
	health_checkbox.button_pressed=false
	time_slider.value=1
	size_slider.value=40
	enemy_spawns.reset()
	player_spawner.reset()
	#player_spawner.number=0
	#player_spawner.start()
	for fe in Global.fences:
		fe.queue_free()
	Global.fences.clear()
	#enemy_spawns.start()
	reset_stat_board()
	time_survived=0
	
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
	var hue_val = 1-base.health/start_base_health
	var col_begin=Color.from_hsv(0.522, 1.0, 1.0, 0.9)
	var col_end=Color.from_hsv(1, 1.0, 1.0, 0.9)
	base_health.color=col_begin.lerp(col_end,hue_val)
	base_health_label.add_theme_color_override("font_color",col_begin.lerp(col_end,hue_val))
	#anti_base_health.position.x=sca
func find_red_players():
	Global.red_coords=[]
	for re in red_persons:
		if re.show_location:
			Global.red_coords.append(re.position)


func _on_show_name_tag_toggled(toggled_on: bool) -> void:
	Global.show_name_tag=toggled_on





func _on_containment_toggled(toggled_on: bool) -> void:
	Global.containment=toggled_on


func _on_show_controls_toggled(toggled_on: bool) -> void:
	if toggled_on:
		control_panel.show()
		controls.size.y=420
	else:
		control_panel.hide()
		controls.size.y=0
		
		


func _on_show_containment_toggled(toggled_on: bool) -> void:
	Global.show_containment=toggled_on


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	time_survived=0
	Global.enemys_to_spawn=10
	player_spawner.start()
	enemy_spawns.start()
	menu.hide()


func _on_help_pressed() -> void:
	show_explanations.button_pressed=true
	Global.explanations=true


func _on_show_explanations_toggled(toggled_on: bool) -> void:
	Global.explanations=toggled_on


func _on_quit_loose_pressed() -> void:
	get_tree().quit()

func get_mouse_raycast() -> Dictionary:
	var mouse_pos := get_viewport().get_mouse_position()

	var origin := camera.project_ray_origin(mouse_pos)
	var end := origin + camera.project_ray_normal(mouse_pos) * 1000.0

	var query := PhysicsRayQueryParameters3D.create(origin, end)
	if Global.current_tool==1:
		query.collision_mask =  1 << 3 # only layer 4
	elif Global.current_tool==0:
		query.collision_mask =  1 << 11 
	query.collide_with_areas = true
	
	return get_world_3d().direct_space_state.intersect_ray(query)
	
func handle_building():
	#print(get_mouse_raycast().collider)
	#print(get_mouse_raycast().position.y)
	var mouse_position=get_viewport().get_mouse_position()
	var mat=build_position_mesh.get_active_material(0)
	
	if build_mode==0:
		fence_button.theme_type_variation= "selected"
		catapult_button.theme_type_variation= ""
	elif build_mode==1:
		catapult_button.theme_type_variation= "selected"
		fence_button.theme_type_variation= ""
	var on_controls=false
	for control in important_controls:
		if mouse_position.y>control.position.y and mouse_position.y<control.position.y+control.size.y and mouse_position.x<control.position.x+build_bar.size.x and mouse_position.x>control.position.x:
			on_controls=true
	
		
	if !on_controls:
		build_position_mesh.show()
		if build_mode==0:
			build_position_mesh.scale.x=1
			build_position_mesh.scale.z=1
			build_position_mesh.position=Vector3(2*floorf((get_mouse_raycast().position.x+1)/2),-0.4,2*floorf((get_mouse_raycast().position.z+1)/2))
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				
				Global.delete_mode=""
				var pos=get_mouse_raycast().position
				#if get_mouse_raycast().collider.is_in_group("floor"):
				var fence_pos=Vector3(2*floorf((pos.x+1)/2),1,2*floorf((pos.z+1)/2))
				var placable=true
				for f in Global.fences:
					if f.position==fence_pos:
						placable=false
				if !get_mouse_raycast().collider.is_in_group("floor"):
					placable=false
				if Global.score <=0:
					placable=false
					score_label.add_theme_color_override("font_color", Color.RED)
					await get_tree().create_timer(0.2).timeout
					score_label.add_theme_color_override("font_color", Color.WHITE)
					
				if placable:
					
					var fe=fence.instantiate()
					add_child(fe)
					Global.fences.append(fe)
					fe.position=fence_pos
					Global.fence_built.emit(fence_pos)
					Global.score-=1
			elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				mat.albedo_color=Color.from_hsv(0.0, 0.83, 0.86, 0.502)
				Global.delete_mode="fence"
			if !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				mat.albedo_color=Color.from_hsv(0.57, 0.832, 0.857, 0.5)
				Global.delete_mode=""
		elif build_mode==1:
			build_position_mesh.scale.x=3
			build_position_mesh.scale.z=3
			build_position_mesh.position=Vector3(6*floorf((get_mouse_raycast().position.x+3)/6),-0.4,6*floorf((get_mouse_raycast().position.z+3)/6))
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				
				var pos=get_mouse_raycast().position
				
				var catapult_pos=Vector3(6*floorf((pos.x+3)/6),0.5,6*floorf((pos.z+3)/6))
				var placable=true
				for c in Global.catapults:
					if c.position==catapult_pos:
						placable=false
				if !get_mouse_raycast().collider.is_in_group("floor"):
					placable=false
				if Global.score <=9:
					placable=false
					score_label.add_theme_color_override("font_color", Color.RED)
					await get_tree().create_timer(0.2).timeout
					score_label.add_theme_color_override("font_color", Color.WHITE)
					
				if placable:
					
					var ca=catapult.instantiate()
					add_child(ca)
					Global.catapults.append(ca)
					ca.position=catapult_pos
					#Global.fence_built.emit(fence_pos)
					Global.score-=10
			elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				mat.albedo_color=Color.from_hsv(0.0, 0.83, 0.86, 0.502)
				Global.delete_mode="catapult"
			if !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				mat.albedo_color=Color.from_hsv(0.57, 0.832, 0.857, 0.5)
				Global.delete_mode=""
	else:
		build_position_mesh.hide()
		

func _on_fence_button_pressed() -> void:
	build_mode=0


func _on_catapult_button_pressed() -> void:
	build_mode=1



func _on_tutorial_pressed() -> void:
	pass
	#start_tutorial()


func _on_close_menu_pressed() -> void:
	menu.hide()


func _on_inputs_pressed() -> void:
	inputs.show()

func _on_close_inputs_pressed() -> void:
	inputs.hide()
	
func start_new_round():
	round_number+=1
	Global.enemys_to_spawn=10
	
