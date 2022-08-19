extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed

# Called when the node enters the scene tree for the first time.
func _ready():
	 speed = Vector2.UP * 2

func _physics_process(delta):
	self.position += speed
	speed.y += 0.1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
