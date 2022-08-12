extends Position2D
var enemy = preload("../Characters/Enemy.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn():
	var enemy_instance = enemy.instance()
	enemy_instance.position = self.position
	get_tree().current_scene.add_child(enemy_instance)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	spawn()
