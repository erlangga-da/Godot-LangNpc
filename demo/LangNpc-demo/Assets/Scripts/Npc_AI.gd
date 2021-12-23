extends KinematicBody2D

export (String) var wall_node_name = "TileMap"

export(float, 1.5, 5.5) var walk_time = 3.0
export(float, 0.5, 4.5) var break_time = 1

export (float) var GRAVITY = 200.0
export (float) var ACCELERATION = 16
export (float) var MAX_SPEED = 80

var velocity = Vector2()
var random = RandomNumberGenerator.new()

enum {IDLE,WALK_LEFT,WALK_RIGHT}
var STATE = IDLE
var can_right = true
var can_left = true

var selectedState

func _ready():
	$Timer/Timer.wait_time = random.randf_range(walk_time,4.5)

func _physics_process(_delta):
	velocity.y = GRAVITY
	
	match STATE :
		IDLE:
			velocity.x = lerp(velocity.x, 0, .4)
			$AnimatedSprite.play("Idle")
		WALK_LEFT:
			walk("left",true)
		WALK_RIGHT:
			walk("right",false)
	var _move = move_and_slide(velocity, Vector2.UP)

func walk(dir,flip):
	if dir == "left":
		velocity.x =  max(velocity.x-ACCELERATION ,-MAX_SPEED)
	else:
		velocity.x =  min(velocity.x+ACCELERATION ,MAX_SPEED)
	$AnimatedSprite.flip_h = flip
	$AnimatedSprite.play("Walk")
	random.randomize()
	$Timer/Timer.wait_time = random.randf_range(walk_time,4.5)

#decision
func set_state(rand):
	if rand <= 10:
		STATE = IDLE
	elif rand <= 20:
		STATE = IDLE
		if can_left:
			set_direction(WALK_LEFT)
		else:
			set_direction(WALK_RIGHT)
	elif rand <= 30:
		STATE = IDLE
		if can_right:
			set_direction(WALK_RIGHT)
		else:
			set_direction(WALK_LEFT)

func set_direction(dir):
	selectedState = dir
	$Timer/BreakTimer.start(random.randf_range(break_time,4.5))

#set the state
func _on_BreakTimer_timeout():
	STATE = selectedState

#timer
func _on_Timer_timeout():
	#set the random decision
	random.randomize()
	var stateGenerator = random.randi_range(0,30)
	set_state(stateGenerator)

#DetectRight
func _on_DetectRight_body_entered(body):
	if body.get_name() == wall_node_name:
		can_right = false
		set_state(19)
	
func _on_DetectRight_body_exited(body):
	if body.get_name() == wall_node_name:
		can_right = true

#DetectLeft
func _on_DetectLeft_body_entered(body):
	if body.get_name() == wall_node_name:
		can_left = false
		set_state(29)
	
func _on_DetectLeft_body_exited(body):
	if body.get_name() == wall_node_name:
		can_left = true
		

#custom func
func _on_InteractArea_body_entered(_body):
	pass 
