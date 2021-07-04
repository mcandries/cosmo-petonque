extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_Quit_pressed():
	get_tree().quit()



func _on_Button_Play_pressed():
	get_tree().change_scene("res://Petonque.tscn")



func _on_Button_Credits_pressed():
	get_tree().change_scene("res://Credits.tscn")
	


func _on_Button_Options_pressed():
	get_tree().change_scene("res://Options.tscn")
	pass # Replace with function body.
