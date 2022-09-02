extends Node2D
var speed = 1
var dir

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.position += speed * dir
	speed += 0.2


func _on_LifeTimer_timeout():
	queue_free()
