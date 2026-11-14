extends CharacterBody3D
@onready var vision=$Vision
@onready var vision_r=$Vision_right
@onready var vision_l=$Vision_left
@export var marker:PackedScene
var player_position=Vector3.ZERO
var pathfinding=false
var Speed=100
var positions=[]
var direction=Vector3(0,0,0)
var collision=false
var markers=[]
var since_last_point=0
func _ready() -> void:
	#Global.update_target.connect(on_update_target)
	pass
func _physics_process(delta: float) -> void:
	since_last_point+=delta*Engine.time_scale
	velocity.y+=get_gravity().y*delta
	if position.x>=Global.target_pos.x-1.4 and position.x<=Global.target_pos.x+1.4 and position.z>=Global.target_pos.z-1.4 and position.z<=Global.target_pos.z+1.4 and pathfinding:
		pathfinding=false
		direction=Vector3.ZERO	
		positions.append(position)
		
		
	if pathfinding:
		if since_last_point>=0.1:
			add_position()
			#pass
		if vision.is_colliding() and !collision:
			var old_direction=direction
			var normal=vision.get_collision_normal()
			direction.x=-normal.z
			direction.z=normal.x
			collision=true
		
		
		if collision and !vision.is_colliding() :
			since_last_point=0
			collision=false
			await get_tree().create_timer(0.02).timeout
			add_position()
			go_to_target()
	vision.target_position=direction.normalized()*2
	var dir=direction.normalized()*2
	vision_r.target_position=Vector3(dir.z,dir.y,-dir.x)
	vision_l.target_position=Vector3(-dir.z,dir.y,dir.x)
	velocity=Vector3.ZERO
	velocity+=direction*Speed
	for index in range(get_slide_collision_count()):
		
		var collision = get_slide_collision(index)
		if collision.get_collider() == null:
			continue
		else:
			go_to_target()
	move_and_slide()

func go_to_target():
	direction.x=(Global.target_pos.x-position.x)
	direction.z=(Global.target_pos.z-position.z)
	direction=direction.normalized()

func add_position():
	positions.append(position)
	var ma=marker.instantiate()
	add_child(ma)
	ma.position=positions[len(positions)-1]
	markers.append(ma)
func start_pathfinding():
	since_last_point=0
	position=player_position
	positions.clear()
	go_to_target()
	pathfinding=true
	
	
