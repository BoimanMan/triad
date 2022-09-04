extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#Onready variables
onready var attack_player = $Attack/AnimationPlayer
onready var attack_body = $Attack
onready var spec1_player = $HeatWave/AnimationPlayer
onready var spec1_area = $HeatWave
onready var spec2_player = $EruptArc/AnimationPlayer
onready var spec2_area = $EruptArc
onready var spec1_cd = $CooldownTimer1
onready var spec2_cd = $CooldownTimer2
onready var game_ui = get_node("/root/Main/Camera2D/InGameUI")
onready var camera = get_node("../Camera2D")
onready var world = get_node("/root/Main")
onready var spawner_array = get_tree().get_nodes_in_group("Spawners")

#Signals
signal player_hp_change(new_hp)
signal player_death
signal player_deathanim_end
signal special1_used
signal special2_used

#Variables
var velocity = Vector2.ZERO
var speed = 250
var friction = 0.5
var mouse_pos
var knockback_vector
var dir
var hp
var current_atk
var atk_dam
var burn_dam = 2
var base_dmg = 10
var kb_force = 500
var being_knocked_back = false
var death_effect_scene = preload("res://Scenes/Systems/DeathEffect.tscn")
var player_death_sprite = preload("res://Sprites/sLeaderDeath.png")
var heatwave_scene = preload("res://Scenes/Attacks/HeatWave.tscn")
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("player_hp_change", game_ui, "_on_Player_player_hp_change")
	self.connect("player_death", game_ui, "_on_Player_player_death")
	self.connect("player_deathanim_end", world, "_on_Player_player_deathanim_end")
	for n in spawner_array:
		self.connect("player_death", n, "_on_Player_player_death")
	hp = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

#Calculate damage
func calc_dmg(attack):
	var dmg_multiplier
	match attack:
		"prim":
			dmg_multiplier = 1
		"spec1":
			dmg_multiplier = 1.25
		"spec2":
			dmg_multiplier = 2.5
	var damage_prob = randi() % 101
	var base_dmg_multiplied = base_dmg * dmg_multiplier
	if damage_prob > 0 and damage_prob < 21:
		atk_dam = int(rand_range(base_dmg_multiplied * 0.9, base_dmg_multiplied))
	elif damage_prob > 20 and damage_prob < 81:
		atk_dam = int(base_dmg_multiplied)
	else:
		atk_dam = int(rand_range(base_dmg_multiplied, base_dmg_multiplied * 1.1 + 1))
	
#Attack function
func prim_attack():
	#Set the frame to zero on start to avoid conflicts
	#attack_player.set_frame(0)
	#Play the animation from frame 0.
	current_atk = "prim"
	calc_dmg(current_atk)
	mouse_pos = get_global_mouse_position()
	attack_body.look_at(mouse_pos)
	attack_body.rotate(-PI/2)
	attack_player.play("attack")
	
#Special 1 -> Heat Wave
func spec1_attack():
	current_atk = "spec1"
	calc_dmg(current_atk)
	mouse_pos = get_global_mouse_position()
	var local_mouse_pos = get_local_mouse_position()
	spec1_area.look_at(mouse_pos)
	spec1_area.rotate(-PI/2)
	spec1_player.play("attack")
	emit_signal("special1_used")
	spec1_cd.start(5)
	var proj_instance = heatwave_scene.instance()
	proj_instance.position = spec1_area.get_node("Sprite").global_position + (22 * local_mouse_pos.normalized())
	proj_instance.rotation = spec1_area.rotation + PI/2
	proj_instance.rotate(-PI/2)
	proj_instance.dir = local_mouse_pos.normalized()
	proj_instance.get_node("Hitbox").add_to_group("Attack")
	proj_instance.get_node("Hitbox").add_to_group("Burn")
	world.add_child(proj_instance)
	
#Special 2 -> Erupt Arc
func spec2_attack():
	current_atk = "spec2"
	calc_dmg(current_atk)
	mouse_pos = get_global_mouse_position()
	spec2_area.look_at(mouse_pos)
	spec2_area.rotate(-PI/2)
	spec2_player.play("attack")
	emit_signal("special2_used")
	spec2_cd.start(8)
	
#When player damaged by enemy
func _on_Enemy_enemy_damage_player(damage, source):
	if being_knocked_back:
		pass
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
			#$CollisionShape2D.set_deferred("disabled", true)
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
	
#If not knocked_back or dead, can move and physics take effect
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
			
	#If primary attack button pressed and attack isn't already happening, attack start
		if Input.is_action_just_pressed("prim_attack") and !attack_player.is_playing():
			prim_attack()
			
	#Same goes for specials, except it's based on a cooldown timer
		elif Input.is_action_just_pressed("spec_attack_1") and spec1_cd.is_stopped():
			spec1_attack()
		elif Input.is_action_just_pressed("spec_attack_2") and spec2_cd.is_stopped():
			spec2_attack()
			
#If being knocked back but not dead, move away from damage source
	elif being_knocked_back and !dead:
		velocity = lerp(knockback_vector * kb_force, Vector2.ZERO, friction)
#If dead, freeze
	else:
		velocity = Vector2.ZERO
	#velocity = input_vector * speed
	move_and_slide(velocity)
		
	
	

#Timeout functions

#On knockback duration end, stop sprite flash
func _on_KnockbackTimer_timeout():
	being_knocked_back = false 
	$FlashTimer.stop()
	$Sprite.show()
	$CollisionShape2D.set_deferred("disabled", false)
	
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
	print("Game Over.")
	get_parent().get_node("DifficultyTimer").stop()
	emit_signal("player_deathanim_end")
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	current_atk = "none"
