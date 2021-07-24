extends Node2D


var last_car_delta = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# dialog 1 
	var tick = OS.get_ticks_msec()
	
	if $RichTextLabel_Pedro1.visible_characters < $RichTextLabel_Pedro1.text.length():
		if (last_car_delta + Gb.Speech_ms_per_char) < tick:
			last_car_delta = tick
			$RichTextLabel_Pedro1.visible_characters += 1 
	else : 
		# dialog 2
		if $RichTextLabel_Timmy.visible_characters < $RichTextLabel_Timmy.text.length():
			tick = OS.get_ticks_msec()
			if (last_car_delta + Gb.Speech_ms_per_char) < tick:
				last_car_delta = tick
				$RichTextLabel_Timmy.visible_characters += 1
		else:
			if (last_car_delta + Gb.Speech_ms_per_char) < tick:
				last_car_delta = tick
				$RichTextLabel_Pedro2.visible_characters += 1 	
		



func _on_Button_Back_pressed():
	get_tree().change_scene("res://Petonque_lvl2.tscn")
