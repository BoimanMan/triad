extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var flash = $FlashTimer
onready var bgm = $BGM
onready var game_start_text = $CanvasLayer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Label
#onready var intro_finished = false
# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			if $BGM.get_playback_position() >= 2.75:
				$BGM.stop()
				get_tree().change_scene("res://Scenes/UI/MainMenu.tscn")
			elif $BGM.get_playback_position() < 2.75:
				bgm.seek(2.75)
	
func _physics_process(delta):
	if $BGM.get_playback_position() >= 2.75 and flash.is_stopped():
		enable_start()
		
func enable_start():
	flash.start(0.5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FlashTimer_timeout():
	if game_start_text.is_visible():
		game_start_text.hide()
	else:
		game_start_text.show()



