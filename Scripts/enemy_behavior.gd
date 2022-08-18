extends KinematicBody2D
var speed = 150
var velocity
var damage_prob
var damage
var hp
onready var player = get_node("/root/Main/Player")
onready var world = get_node("/root/Main")
onready var game_ui = get_node("/root/Main/InGameUI")
signal enemy_kill
signal enemy_damage_player(damage)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("enemy_kill", world, "_on_Enemy_enemy_kill")
	self.connect("enemy_damage_player", player, "_on_Enemy_enemy_damage_player", [self])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	velocity = position.direction_to(player.position) * speed
	move_and_slide(velocity)



func _on_Hurtbox_body_entered(body):
	if body.name == "Attack":
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
