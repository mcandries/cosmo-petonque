extends "res://Scripts/Petonque.gd"



func _init():
	music_playlist = ["boostiooooo v3.2", "water world v3.5"]
	current_level = 2

func _ready():
	pass 

func _process(delta):
	
	if current_step=="Swap_Player_Pos" and current_player==1: #On va passer de player 1 à player 2 
		$Majordome_AnimatedSprite.animation = "offre_balle"
	pass



func _on_Majordome_AnimatedSprite_animation_finished():
	$Majordome_AnimatedSprite.animation = "idle"
	pass # Replace with function body.
