extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemy_count
var enemies_this_wave
var enemy_limit
var wave
onready var enemy_timer = $EnemyTimer
onready var wave_timer = $WaveTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	enemy_count = 0
	enemies_this_wave = 0
	enemy_limit = 3
	wave = 1
func _physics_process(delta):
	if wave_timer.time_left is int:
		print("Wave Timer: " + str(wave_timer.time_left))
	#if enemy_count <= 0 and enemy_timer.is_stopped():
		#enemy_timer.start(3)
	if enemies_this_wave >= enemy_limit:
		enemy_timer.stop()
		if enemy_count <= 0 and wave_timer.is_stopped():
			wave += 1
			enemy_limit += 3
			enemies_this_wave = 0
			wave_timer.start(5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_EnemySpawner_enemy_spawned(enemy_instance):
	enemy_count += 1
	enemies_this_wave += 1
	print(enemy_count)

func _on_Enemy_enemy_kill():
	enemy_count -= 1
	print(enemy_count)

func _on_WaveTimer_timeout():
	print("Wave " + str(wave) + " has begun. Defeat " + str(enemy_limit) + " enemies.")
	enemy_timer.start(3)
