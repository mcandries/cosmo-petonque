extends Node

var settings_file = "user://settings.save"


var mouse_pos = Vector2 (0,0)   #expose mouse pos.
var BUILD_TIME = false			#Build time to disable music & others while debug/buiding

var P_Fullscreen = false
var P_Volume_Music = -8
var P_Volume_Sound = -2
var P_Volume_Voice = -2



func load_settings():
	var f = File.new()
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ)
		P_Fullscreen = f.get_var()
		P_Volume_Music = f.get_var()
		P_Volume_Sound = f.get_var()
		P_Volume_Voice = f.get_var()
		f.close()
