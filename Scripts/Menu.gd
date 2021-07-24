extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Gb.load_settings()
	if Gb.P_Fullscreen :
		OS.window_fullscreen = true
	$AudioStreamPlayer.volume_db = Gb.P_Volume_Music
	$AudioStreamPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_Quit_pressed():
	get_tree().quit()


func _on_Button_Credits_pressed():
	get_tree().change_scene("res://Credits.tscn")

func _on_Button_Options_pressed():
	get_tree().change_scene("res://Options.tscn")
	pass # Replace with function body.



func _on_Button_Story_pressed():
	Gb.Game_Mode = Gb.MODE_STORY
	Gb.Go_To = 1
	if Gb.P_Help_Screen:
		get_tree().change_scene("res://Help_screen.tscn")
	else:
		get_tree().change_scene("res://Scenes/Petonque_lvl1_diag.tscn")


func _on_Button_1v1_Earth_pressed():
	Gb.Game_Mode = Gb.MODE_1V1
	Gb.Go_To = 1
	if Gb.P_Help_Screen:
		get_tree().change_scene("res://Help_screen.tscn")
	else:
		get_tree().change_scene("res://Petonque_lvl1.tscn")


func _on_Button_1v1_Cosmos_pressed():
	Gb.Game_Mode = Gb.MODE_1V1
	Gb.Go_To = 2
	if Gb.P_Help_Screen:
		get_tree().change_scene("res://Help_screen.tscn")
	else:
		get_tree().change_scene("res://Petonque_lvl2.tscn")
