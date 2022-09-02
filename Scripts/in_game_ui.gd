extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hp_bar_green = preload("res://Sprites/hp_green.png")
var hp_bar_yellow = preload("res://Sprites/hp_yellow.png")
var hp_bar_red = preload("res://Sprites/hp_red.png")
var hp_letter_green = preload("res://Sprites/hp_green_letters.png")
var hp_letter_yellow = preload("res://Sprites/hp_yellow_letters.png")
var hp_letter_red = preload("res://Sprites/hp_red_letters.png")
var seconds = 0
var minutes = 0
var player_alive = true
var game_start_time
onready var cd1 = get_node("/root/Main/Player/CooldownTimer1")
onready var hp_bar = $MarginContainer/VBoxContainer/BottomUI/VBoxContainer/HPBar
onready var hp_bar_text = $MarginContainer/VBoxContainer/BottomUI/VBoxContainer/HPBar/Label
onready var timer = $MarginContainer/VBoxContainer/TopUI/VBoxContainer/TextureRect/TimeDisplay
onready var difficulty_display = $MarginContainer/VBoxContainer/TopUI/VBoxContainer/TextureRect/DiffDisplay
onready var cd1_display = $MarginContainer/VBoxContainer/BottomUI/HBoxContainer/EruptArc
onready var max_health = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	hp_bar.value = max_health # Replace with function body.
	hp_bar_text.text = str(max_health)
	game_start_time = Time.get_ticks_msec()
func _on_Player_player_hp_change(new_hp):
	#Do this operation to support hp values higher than 100.
	hp_bar.value = (int(round((new_hp/max_health) * 100)))
	hp_bar_text.text = str(new_hp)
	pass
func _physics_process(delta):
#HP bar logic
	if hp_bar.value > max_health * 0.5:
		hp_bar.texture_progress = hp_bar_green
		hp_bar.texture_under = hp_letter_green
	if hp_bar.value <= max_health * 0.5 and hp_bar.value > max_health * 0.25:
		hp_bar.texture_progress = hp_bar_yellow
		hp_bar.texture_under = hp_letter_yellow
	if hp_bar.value < max_health * 0.25:
		hp_bar.texture_progress = hp_bar_red
		hp_bar.texture_under = hp_letter_red

#Timer logic
	seconds = (Time.get_ticks_msec() - game_start_time) / 1000
	minutes = seconds / 60
	if player_alive:
		if seconds % 60 < 10:
			timer.text = (str(minutes) + ":0" + str(seconds % 60))
		else:
			timer.text = (str(minutes) + ":" + str(seconds % 60))

#Cooldowns
	if !cd1.is_stopped():
		$MarginContainer/VBoxContainer/BottomUI/HBoxContainer/EruptArc/CooldownTime.set_text(str(int(cd1.get_time_left() + 1)) + "s")
	else:
		$MarginContainer/VBoxContainer/BottomUI/HBoxContainer/EruptArc/CooldownTime.set_text("")
		cd1_display.set_modulate(Color.white)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Main_difficulty_changed(difficulty):
	difficulty_display.text = difficulty

func _on_Player_player_death():
	player_alive = false


func _on_Player_special1_used():
	cd1_display.set_modulate(Color.darkgray)
