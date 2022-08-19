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
const KB_FORCE = 500
onready var player = get_node("/root/Main/Player")
onready var world = get_node("/root/Main")
signal enemy_kill
signal enemy_damage_player(damage)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("enemy_kill", world, "_on_Enemy_enemy_kill")
	self.connect("enemy_damage_player", player, "_on_Enemy_enemy_damage_player", [self])
	max_hp = 20
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

func _on_Player_player_death():
	player_alive = false

func _on_Hurtbox_body_entered(body):
	if body.name == "Attack":
		hp -= player.atk_dam
		if hp > 0:
			velocity = Vector2.ZERO
			$KnockbackTimer.start(0.5)
			$FlashTimer.start(0.15)
			being_knocked_back = true
			knockback_vector = (self.position - player.position).normalized()
		if hp <= 0:
			emit_signal("enemy_kill")
			queue_free()
		
func _on_Hitbox_body_entered(body):
	if body.is_in_group("Players"):
		damage_prob = randi() % 101
		if damage_prob > 0 and damage_prob < 21:
			damage = 9
		elif damage_prob > 20 and damage_prob < 81:
			damage = 10
		else:
			damage = 11
		emit_signal("enemy_damage_player", damage)


func _on_KnockbackTimer_timeout():
	being_knocked_back = false
	$FlashTimer.stop()
	$Sprite.show()

func _on_FlashTimer_timeout():
	if $Sprite.is_visible():
		$Sprite.hide()
	else:
		$Sprite.show()
