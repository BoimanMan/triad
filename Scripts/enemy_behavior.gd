extends KinematicBody2D
var speed = 150
var velocity
var damage_prob
var damage
var hp
var max_hp
var player_alive = true
var being_knocked_back = false
var knockback_vector
var burn_ticks = 0
var last_hit
const KB_FORCE = 250
onready var player = get_node("/root/Main/Player")
onready var world = get_node("/root/Main")
onready var sprite = self.get_node("Sprite")
onready var heat_wave = preload("res://Scenes/Attacks/HeatWave.tscn")
signal enemy_kill
signal enemy_hit(damage)
signal enemy_damage_player(damage)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("enemy_kill", world, "_on_Enemy_enemy_kill")
	self.connect("enemy_hit", world, "_on_Enemy_enemy_hit", [self])
	self.connect("enemy_damage_player", player, "_on_Enemy_enemy_damage_player", [self])
	self.connect("enemy_damage_player", world, "_on_Enemy_enemy_damage_player")
	max_hp = 20
	damage = 10
	match world.difficulty:
		"Easy":
			pass
		"Normal":
			max_hp = int(round(max_hp * 1.5))
			damage = int(round(damage * 1.5))
		"Hard":
			max_hp *= 2
			damage *= 2
		"Brutal":
			max_hp *= 3
			damage = int(round(damage * 2.5))
		"Insane":
			max_hp *= 5
			damage *= 3
	hp = max_hp
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	if player_alive and !being_knocked_back:
		velocity = position.direction_to(player.position) * speed
	elif being_knocked_back:
		velocity = lerp(knockback_vector * KB_FORCE, Vector2.ZERO, 0.5)
	else:
		velocity = Vector2.ZERO
	move_and_slide(velocity)

func burn_damage():
	hp -= player.burn_dam
	emit_signal("enemy_hit", player.burn_dam)
	if hp <= 0:
		emit_signal("enemy_kill")
		queue_free()
			
func _on_Player_player_death():
	player_alive = false

func _on_Hurtbox_body_entered(body):
	if body.name == "Attack":
		hp -= player.atk_dam
		emit_signal("enemy_hit", player.atk_dam)
		if hp > 0:
			velocity = Vector2.ZERO
			$KnockbackTimer.start(0.5)
			$FlashTimer.start(0.15)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$CollisionShape2D.set_deferred("disabled", true)
			being_knocked_back = true
			knockback_vector = (self.position - player.position).normalized()
		if hp <= 0:
			emit_signal("enemy_kill")
			queue_free()

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("Attack") and player.current_atk != last_hit:
		hp -= player.atk_dam
		last_hit = player.current_atk
		emit_signal("enemy_hit", player.atk_dam)
		if hp > 0:
			velocity = Vector2.ZERO
			$KnockbackTimer.start(0.5)
			$FlashTimer.start(0.15)
			$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
			$CollisionShape2D.set_deferred("disabled", true)
			being_knocked_back = true
			knockback_vector = (self.position - player.position).normalized()
		if hp <= 0:
			emit_signal("enemy_kill")
			queue_free()
	if area.is_in_group("Burn"):
		sprite.set_modulate(Color.red)
		$BurnTimer.start(1)
		burn_ticks = 0
func _on_Hitbox_body_entered(body):
	#var base_damage = damage
	if body.is_in_group("Players") and !being_knocked_back:
		#damage_prob = randi() % 101
		#if damage_prob > 0 and damage_prob < 21:
			#damage *= 0.9
		#elif damage_prob > 20 and damage_prob < 81:
			#pass
		#else:
			#damage *= 1.1
		emit_signal("enemy_damage_player", int(round(rand_range(0.9 * damage, 1.1 * damage))))
		#damage = base_damage

func _on_KnockbackTimer_timeout():
	being_knocked_back = false
	$FlashTimer.stop()
	$Sprite.show()
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D.set_deferred("disabled", false)

func _on_FlashTimer_timeout():
	if $Sprite.is_visible():
		$Sprite.hide()
	else:
		$Sprite.show()


func _on_BurnTimer_timeout():
	burn_ticks += 1
	if burn_ticks >= 5:
		$BurnTimer.stop()
		sprite.modulate(Color.white)
	else:
		burn_damage()


func _on_HeatWaveCD_timeout():
	pass
