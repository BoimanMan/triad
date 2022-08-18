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
onready var hp_bar = $MarginContainer/VBoxContainer/BottomUI/VBoxContainer/HPBar
onready var hp_bar_text = $MarginContainer/VBoxContainer/BottomUI/VBoxContainer/HPBar/Label
onready var max_health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	hp_bar.value = max_health # Replace with function body.
	hp_bar_text.text = str(hp_bar.value)
func _physics_process(delta):
	if hp_bar.value > max_health * 0.5:
		hp_bar.texture_progress = hp_bar_green
		hp_bar.texture_under = hp_letter_green
	if hp_bar.value <= max_health * 0.5 and hp_bar.value > max_health * 0.25:
		hp_bar.texture_progress = hp_bar_yellow
		hp_bar.texture_under = hp_letter_yellow
	if hp_bar.value < max_health * 0.25:
		hp_bar.texture_progress = hp_bar_red
		hp_bar.texture_under = hp_letter_red
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
