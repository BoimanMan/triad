extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hp_bar_green = preload("res://Sprites/hp_green.png")
var hp_bar_yellow = preload("res://Sprites/hp_yellow.png")
var hp_bar_red = preload("res://Sprites/hp_red.png")
var hp_letter_green = preload("res://Sprites/hp_green_letters.png")
var hp_letter_yellow = preload("res://Sprites/hp_yellow_letters.png")
var hp_letter_red = preload("res://Sprites/hp_red_letters.png")
onready var hpBar = $MarginContainer/VBoxContainer/BottomUI/VBoxContainer/HPBar
onready var max_health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	hpBar.value = max_health # Replace with function body.
func _physics_process(delta):
	if hpBar.value > 50:
		hpBar.texture_progress = hp_bar_green
	if hpBar.value <= 50 and hpBar.value > 25:
		hpBar.texture_progress = hp_bar_yellow
	if hpBar.value < 25:
		hpBar.texture_progress = hp_bar_red

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
