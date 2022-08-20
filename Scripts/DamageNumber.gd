extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed
var starting_pos
var hit_peak = false
# Called when the node enters the scene tree for the first time.
func _ready():
	speed = Vector2.UP * 2
	starting_pos = self.position
func _physics_process(delta):
	if speed.y >= 0:
		hit_peak = true
	if !hit_peak:
		self.position += speed
		speed.y += 0.1
	elif self.position.y <= starting_pos.y + 50:
		self.position += speed
		speed.y += 0.1
	else:
		queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
