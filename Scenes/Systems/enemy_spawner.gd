extends Position2D
var enemy = preload("../Characters/Enemy.tscn")
signal enemy_spawned
onready var world = get_node("/root/Main")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Replace with function body.
	self.connect("enemy_spawned", world, "_on_EnemySpawner_enemy_spawned")
func spawn():
	var enemy_instance = enemy.instance()
	enemy_instance.position = self.position
	emit_signal("enemy_spawned")
	world.add_child(enemy_instance)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	spawn()
