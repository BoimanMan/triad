extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var attack_player = $Attack/AnimationPlayer
onready var attack_body = $Attack
onready var game_ui = get_node("/root/Main/Camera2D/InGameUI")
onready var camera = get_node("../Camera2D")
onready var world = get_node("/root/Main")
onready var spawner_array = get_tree().get_nodes_in_group("Spawners")
signal player_hp_change(new_hp)
signal player_death
var velocity = Vector2.ZERO
var speed = 250
var friction = 0.5
var mouse_pos
var knockback_vector
var dir
var hp
var atk_dam
var kb_force = 500
var being_knocked_back = false
var death_effect_scene = preload("res://Scenes/Systems/DeathEffect.tscn")
var player_death_sprite = preload("res://Sprites/sLeaderDeath.png")
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("player_hp_change", game_ui, "_on_Player_player_hp_change")
	for n in spawner_array:
		self.connect("player_death", n, "_on_Player_player_death")
	hp = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

#Attack function
func prim_attack():
	#Set the frame to zero on start to avoid conflicts
	#attack_player.set_frame(0)
	#Play the animation from frame 0.
	var damage_prob = randi() % 101
	if damage_prob > 0 and damage_prob < 21:
		atk_dam = 9
	elif damage_prob > 20 and damage_prob < 81:
		atk_dam = 10
	else:
		atk_dam = 11
	mouse_pos = get_global_mouse_position()
	attack_body.look_at(mouse_pos)
	attack_body.rotate(-PI/2)
	attack_player.play("attack")
	
func _on_Enemy_enemy_damage_player(damage, source):
	if !being_knocked_back and !dead:
		hp -= damage
		if hp < 0:
			hp = 0
		emit_signal("player_hp_change", hp)
	#Take the hit, knockback and invuln (TBD)
		if hp > 0:
			velocity = Vector2.ZERO
			$KnockbackTimer.start(0.5)
			$FlashTimer.start(0.15)
			being_knocked_back = true
			knockback_vector = (self.position - source.position).normalized()
	#Death Logic
		else:
			dead = true
			emit_signal("player_death")
			$Sprite.set_texture(player_death_sprite)
			$DeathAnimTimer.start(1)
		#velocity = lerp(knockback_vector * kb_force, Vector2.ZERO, friction)
		#print("kb: " + str(self.position) + " " + str(source.position) + " " + str(knockback_vector * kb_force))

func _on_EnemySpawner_enemy_spawned(enemy_instance):
	self.connect("player_death", enemy_instance, "_on_Player_player_death")
	
func _physics_process(delta):
	if !being_knocked_back and !dead:
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
	elif being_knocked_back and !dead:
		velocity = lerp(knockback_vector * kb_force, Vector2.ZERO, friction)
	else:
		velocity = Vector2.ZERO
	#velocity = input_vector * speed
	move_and_slide(velocity)
	#If left mouse click, start attack animation.
		
	
	

#Timer functions
#On knockback duration end, stop sprite flash
func _on_KnockbackTimer_timeout():
	being_knocked_back = false 
	$FlashTimer.stop()
	$Sprite.show()

#Create sprite blinking effect
func _on_FlashTimer_timeout():
	if $Sprite.is_visible():
		$Sprite.hide()
	else:
		$Sprite.show()

#After a second long freeze, destroy player and instantiate death effects
func _on_DeathAnimTimer_timeout():
	for n in 8:
		var death_effect = death_effect_scene.instance()
		death_effect.position = self.position
		death_effect.get_node("AnimationPlayer").play("move")
		#There's probably a better way to do this
		match n:
			0:
				dir = Vector2.UP
			1:
				dir = (Vector2.UP + Vector2.RIGHT) * 2
			2:
				dir = Vector2.RIGHT
			3:
				dir = (Vector2.RIGHT + Vector2.DOWN) * 2
			4:
				dir = Vector2.DOWN
			5:
				dir = (Vector2.DOWN + Vector2.LEFT) * 2
			6:
				dir = Vector2.LEFT
			7:
				dir = (Vector2.LEFT + Vector2.UP) * 2
		death_effect.velocity = dir
		world.add_child(death_effect)
	queue_free()
