extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game_start_text = $CanvasLayer/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		get_tree().change_scene("res://Scenes/UI/MainMenu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FlashTimer_timeout():
	if game_start_text.is_visible():
		game_start_text.hide()
	else:
		game_start_text.show()
