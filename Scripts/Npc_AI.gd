extends KinematicBody2D

export (String) var wall_node_name = "TileMap"
export (String) var Idle_Animation_name = "Idle"
export (String) var Walk_Animation_name = "Walk"

export(float, 1.5, 2.5) var walk_time = 1.5

export (float) var GRAVITY = 200.0
export (float) var ACCELERATION = 16
export (float) var MAX_SPEED = 80

var velocity = Vector2()
var random = RandomNumberGenerator.new()

enum {IDLE,WALK}
var STATE = IDLE
var direction

func _ready():
	random.randomize()
	$Timer.wait_time = random.randf_range(walk_time,3.0)
	$Timer.start()

#make decision when timeout
func _on_Timer_timeout():
	STATE = IDLE
	random.randomize()
	var stateGenerator = random.randi_range(0,1)
	set_state(stateGenerator)
	$Timer.start()

func set_state(rand):
	if rand == 0:
		STATE = IDLE
	else:
		if !$groundCheck.is_colliding() or $wallCheck.is_colliding():
			direction = (
				0 if $groundCheck.position.x > 0
				else 1
			)
		else:
			random.randomize()
			direction = random.randi_range(0,1)
		
		random.randomize()
		yield(get_tree().create_timer(random.randf_range(0.0,walk_time)), "timeout")
		
		if direction == 0:
			$wallCheck.cast_to.x = -20
			$groundCheck.position.x = -20
			$AnimatedSprite.flip_h = true
			STATE = WALK
		else:
			$wallCheck.cast_to.x = 20
			$groundCheck.position.x = 20
			$AnimatedSprite.flip_h = false
			STATE = WALK

func _physics_process(_delta):
	if !is_on_floor():
		velocity.y = GRAVITY
	
	match STATE :
		IDLE:
			velocity.x = lerp(velocity.x, 0, .4)
			$AnimatedSprite.play(Idle_Animation_name)
		WALK:
			if !$groundCheck.is_colliding() or $wallCheck.is_colliding():
				STATE = IDLE
			else:
				$AnimatedSprite.play(Walk_Animation_name)
				velocity.x = (
					max(velocity.x-ACCELERATION ,-MAX_SPEED) if direction == 0
					else min(velocity.x+ACCELERATION ,MAX_SPEED)
				)
	
	var _move = move_and_slide(velocity, Vector2.UP)

#custom func
func _on_InteractArea_body_entered(_body):
	pass 
