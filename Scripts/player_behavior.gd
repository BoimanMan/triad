extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2.ZERO
export var speed = 250
export var friction = 0.5
onready var attack_player = $Attack/AnimationPlayer
onready var attack_body = $Attack
onready var game_ui = get_node("/root/Main/Camera2D/InGameUI")
signal player_hp_change(new_hp)
var mouse_pos
var knockback_vector
var dir
var hp
var kb_force = 500
var being_knocked_back = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("player_hp_change", game_ui, "_on_Player_player_hp_change")
	hp = 100
	print(hp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

#Attack function
func prim_attack():
	#Set the frame to zero on start to avoid conflicts
	#attack_player.set_frame(0)
	#Play the animation from frame 0.
	mouse_pos = get_global_mouse_position()
	attack_body.look_at(mouse_pos)
	attack_body.rotate(-PI/2)
	attack_player.play("attack")
	
func _on_Enemy_enemy_damage_player(damage, source):
	if !being_knocked_back:
		hp -= damage
		emit_signal("player_hp_change", hp)
		print(hp)
		velocity = Vector2.ZERO
		$KnockbackTimer.start(0.5)
		$FlashTimer.start(0.15)
		being_knocked_back = true
		knockback_vector = (self.position - source.position).normalized()
		
		#velocity = lerp(knockback_vector * kb_force, Vector2.ZERO, friction)
		#print("kb: " + str(self.position) + " " + str(source.position) + " " + str(knockback_vector * kb_force))
	
func _physics_process(delta):
	if !being_knocked_back:
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
		if Input.is_action_just_pressed("prim_attack") and !attack_player.is_playing():
			prim_attack()
	else:
		velocity = lerp(knockback_vector * kb_force, Vector2.ZERO, friction)
	#velocity = input_vector * speed
	move_and_slide(velocity)
	#If left mouse click, start attack animation.
		
	
	


func _on_KnockbackTimer_timeout():
	being_knocked_back = false 
	$FlashTimer.stop()
	$Sprite.show()

func _on_FlashTimer_timeout():
	if $Sprite.is_visible():
		$Sprite.hide()
	else:
		$Sprite.show()
