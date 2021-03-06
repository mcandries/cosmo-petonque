extends Node

var settings_file = "user://settings.config"


var mouse_pos = Vector2 (0,0)   #expose mouse pos.
var BUILD_TIME = false			#Build time to disable music & others while debug/buiding

var P_Fullscreen = false
var P_Volume_Music = -15
var P_Volume_Sound = -5
var P_Volume_Voice = -5

var P_Help_Screen = true
var P_Show_Tips = true

var P_Short_Game = true

var P_Difficulty = 1

var Go_To = 1 #Fot help screen

var Speech_ms_per_char = 21

enum {MODE_STORY, MODE_1V1}
var Game_Mode


func load_settings():
#	var f = File.new()
#	if f.file_exists(settings_file):
#		f.open(settings_file, File.READ)
#		P_Fullscreen = f.get_var()
#		P_Volume_Music = f.get_var()
#		P_Volume_Sound = f.get_var()
#		P_Volume_Voice = f.get_var()
#		f.close()
	var f = ConfigFile.new()
	f.load(settings_file)
	P_Fullscreen   = f.get_value("SCREEN","P_Fullscreen",P_Fullscreen)
	P_Volume_Music = f.get_value("SOUND","P_Volume_Music",P_Volume_Music)
	P_Volume_Sound = f.get_value("SOUND","P_Volume_Sound",P_Volume_Sound)
	P_Volume_Voice = f.get_value("SOUND","P_Volume_Voice",P_Volume_Voice)
	P_Help_Screen  = f.get_value("PREFS","P_Help_Screen",P_Help_Screen)
	P_Show_Tips	   = f.get_value("PREFS","P_Show_Tips",P_Show_Tips)
	P_Difficulty   = f.get_value("PREFS","P_Difficulty",P_Difficulty)
	P_Short_Game   = f.get_value("PREFS","P_Short_Game",P_Short_Game)
	

func save_settings():
#	var f = File.new()
#	f.open(Gb.settings_file, File.WRITE)
#	f.store_var(OS.window_fullscreen)
#	f.store_var(Gb.P_Volume_Music)
#	f.store_var(Gb.P_Volume_Sound)
#	f.store_var(Gb.P_Volume_Voice)
#	f.close()
	var f = ConfigFile.new()
	f.set_value("SCREEN","P_Fullscreen",P_Fullscreen)
	f.set_value("SOUND","P_Volume_Music",P_Volume_Music)
	f.set_value("SOUND","P_Volume_Sound",P_Volume_Sound)
	f.set_value("SOUND","P_Volume_Voice",P_Volume_Voice)
	f.set_value("PREFS","P_Help_Screen",P_Help_Screen)
	f.set_value("PREFS","P_Show_Tips",P_Show_Tips)
	f.set_value("PREFS","P_Difficulty",P_Difficulty)
	f.set_value("PREFS","P_Short_Game",P_Short_Game)
	f.save(settings_file)
	
