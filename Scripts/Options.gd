extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Slider_Music/HSliderMusic.value = Gb.P_Volume_Music
	$Slider_Sound/HSliderSound.value = Gb.P_Volume_Sound
	$Slider_Voice/HSliderVoice.value = Gb.P_Volume_Voice
	
	$Help_Screen.pressed = Gb.P_Help_Screen
	$Show_Tips.pressed = Gb.P_Show_Tips

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_Back_pressed():
	Gb.save_settings()
	get_tree().change_scene("res://Menu.tscn")


func _on_Button_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	Gb.P_Fullscreen = OS.window_fullscreen


func _on_HSliderMusic_value_changed(value):
	Gb.P_Volume_Music = value
	$AudioStreamPlayer_Music.volume_db = value

func _on_HSliderSound_value_changed(value):
	Gb.P_Volume_Sound = value
	$AudioStreamPlayer_SoundTest.volume_db = value
	if not $AudioStreamPlayer_SoundTest.playing:
		$AudioStreamPlayer_SoundTest.play()

func _on_HSliderVoice_value_changed(value):
	Gb.P_Volume_Voice = value
	$AudioStreamPlayer_VoiceTest.volume_db = value
	if not $AudioStreamPlayer_VoiceTest.playing : 
		$AudioStreamPlayer_VoiceTest.play()


func _on_Help_Screen_toggled(button_pressed):
	Gb.P_Help_Screen = button_pressed
	


func _on_Show_Tips_toggled(button_pressed):
	Gb.P_Show_Tips = button_pressed
