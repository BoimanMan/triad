extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_alive = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _physics_process(delta):
	if player_alive:
		self.position = $"../Player".position
	else:
		self.position = self.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_player_death():
	player_alive = false # Replace with function body.
