extends Node2D


var last_car_delta = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tick = OS.get_ticks_msec()
	if (last_car_delta + Gb.Speech_ms_per_char) < tick:
		last_car_delta = tick
		$RichTextLabel.visible_characters += 1 



func _on_Button_Back_pressed():
	get_tree().change_scene("res://Credits.tscn")
