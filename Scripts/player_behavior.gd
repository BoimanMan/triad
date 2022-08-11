extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2.ZERO
export var speed = 250
export var friction = 0.5
onready var attack_player = $StaticBody2D/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

#Attack function
func prim_attack():
	#Set the frame to zero on start to avoid conflicts
	attack_player.set_frame(0)
	#Play the animation from frame 0.
	attack_player.play("attack")
func _physics_process(delta):
	#If the animation is playing and it finished the cycle, stop it.
	#if attack_player.get_frame() == 3 and attack_player.is_playing():
		#attack_player.stop()
	#Get movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	#Move KinematicBody2D based on input
	if input_vector != Vector2.ZERO:
		velocity = lerp(Vector2.ZERO, input_vector * speed, 1)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	#velocity = input_vector * speed
	move_and_slide(velocity)
	#If left mouse click, start attack animation.
	if Input.is_action_just_pressed("prim_attack"):
		prim_attack()
	
	
