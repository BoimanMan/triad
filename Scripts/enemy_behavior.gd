extends KinematicBody2D
var speed = 150
var velocity
onready var player = $"../Player"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	velocity = position.direction_to(player.position) * speed
	move_and_slide(velocity)



func _on_Hurtbox_body_entered(body):
	if body.name == "Attack":
		 queue_free()
