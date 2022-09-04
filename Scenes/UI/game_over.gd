extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal restart_game
signal exit_to_main_menu
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_RestartButton_button_down():
	emit_signal("restart_game")


func _on_ExitToMenuButton_button_down():
	emit_signal("exit_to_main_menu")
