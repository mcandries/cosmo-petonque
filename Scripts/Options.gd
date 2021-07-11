extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Slider_Music/HSliderMusic.value = Gb.P_Volume_Music
	$Slider_Sound/HSliderSound.value = Gb.P_Volume_Sound
	$Slider_Voice/HSliderVoice.value = Gb.P_Volume_Voice
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_Back_pressed():
	save_settings()
	get_tree().change_scene("res://Menu.tscn")
	pass # Replace with function body.


func _on_Button_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	pass # Replace with function body.


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

#############################

func save_settings():
	var f = File.new()
	f.open(Gb.settings_file, File.WRITE)
	f.store_var(OS.window_fullscreen)
	f.store_var(Gb.P_Volume_Music)
	f.store_var(Gb.P_Volume_Sound)
	f.store_var(Gb.P_Volume_Voice)
	f.close()
