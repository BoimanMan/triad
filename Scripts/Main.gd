extends Node2D

#Global Variables
var enemy_count
var enemies_this_wave
var wave_enemy_limit
var screen_enemy_limit
var enemies_defeated
var wave
var spawn_interval
var difficulty
var current_time
var second_of_diff_change
var damage_number_scene = preload("res://Scenes/Systems/DamageNumber.tscn")

#Onready variables
onready var enemy_timer = $EnemyTimer
onready var wave_timer = $WaveTimer
onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	difficulty = "Easy"
	spawn_interval = 5
	enemy_count = 0
	enemies_defeated = 0
	enemies_this_wave = 0
	wave_enemy_limit = 3
	screen_enemy_limit = 1
	wave = 1
func _physics_process(delta):
	
#Countdown to wave start
	if ceil(wave_timer.time_left) != current_time:
		current_time = ceil(wave_timer.time_left)
		if current_time > 0:
			print("Wave Timer: " + str(current_time))
			
#Stop spawning when limit is hit
	if enemies_this_wave >= wave_enemy_limit:
		enemy_timer.stop()
		
#If no enemies and no more spawning, wave is complete
		if wave_enemy_limit - enemies_this_wave <= 0 and enemy_count <= 0 and wave_timer.is_stopped():
			wave += 1
			enemies_defeated = 0
			wave_enemy_limit += 3
			enemies_this_wave = 0
			wave_timer.start(5)
			
#TBD: Difficulty
func difficulty_change():
	match difficulty:
		"Easy":
			difficulty = "Normal"
			spawn_interval *= 0.9
		"Normal":
			difficulty = "Hard"
			spawn_interval *= 0.8
		"Hard":
			difficulty = "Brutal"
			spawn_interval *= 0.7
		"Brutal":
			difficulty = "Insane"
			spawn_interval *= 0.5
		"Insane":
			$DifficultyTimer.stop()
	if difficulty != "Easy":
		print("Your enemies grow more aggressive. The difficulty has been increased to " + difficulty + ".")

#creates instance for damage number
func dmg_num_instantiate(damage, color):
	var dmg_num = damage_number_scene.instance()
	var lbl = dmg_num.get_node("Label")
	lbl.text = "-" + str(damage)
	lbl.add_color_override("font_color", color)
	return dmg_num

#Signal: When enemy damages player, make damage number
func _on_Enemy_enemy_damage_player(damage):
	if !player.being_knocked_back:
		var dmg_num = dmg_num_instantiate(damage, Color.purple)
		dmg_num.position = player.position
		self.add_child(dmg_num)

#Signal: When player damages enemy, make damage number
func _on_Enemy_enemy_hit(damage, source):
	if !source.being_knocked_back:
		var dmg_num = dmg_num_instantiate(damage, Color.red)
		dmg_num.position = source.position
		self.add_child(dmg_num)

#Signal: When spawner spawns an enemy, increase enemy count and count of enemies
#that have spawned this wave.
func _on_EnemySpawner_enemy_spawned(enemy_instance):
	enemy_count += 1
	enemies_this_wave += 1

#Signal: When an enemy dies, print debug message.
func _on_Enemy_enemy_kill():
	enemy_count -= 1
	enemies_defeated += 1
	if wave_enemy_limit - enemies_defeated > 1:
		print(str(wave_enemy_limit - enemies_defeated) + " enemies remain.")
	elif wave_enemy_limit - enemies_defeated <= 0 and enemy_count == 0:
		print("Wave complete!")
	else:
		print("1 enemy remains.")

#Signal: When WaveTimer times out, new wave begins, start enemy timer.
func _on_WaveTimer_timeout():
	print("Wave " + str(wave) + " has begun. Defeat " + str(wave_enemy_limit) + " enemies.")
	if spawn_interval >= 1 and wave != 1:
		spawn_interval *= 0.99
	print(str(spawn_interval))
	enemy_timer.start(spawn_interval)

#Signal: When DifficultyTimer times out, increase difficulty.
func _on_DifficultyTimer_timeout():
	difficulty_change()
