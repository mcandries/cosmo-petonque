extends RigidBody2D

class_name BouleC

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var player_number : int
export var level_number : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$boule1_1.visible = false
	$boule1_2.visible = false
	$boule2_1.visible = false
	$boule2_2.visible = false
	
	$AudioStreamPlayer_Boule_tape.volume_db = Gb.P_Volume_Sound
	match level_number:
		1: 
			if player_number == 1 : 
				$boule1_1.visible = true
			else:
				$boule1_2.visible = true
		2: 
			if player_number == 1 : 
				$boule2_1.visible = true
			else:
				$boule2_2.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_RigidBody2D_body_entered(body):
	$AudioStreamPlayer_Boule_tape.play()
	pass # Replace with function body.



func show_circle (color, time):
	var obj
	match color:
		"blue":
			obj = $blue_circle
		"red":
			obj = $red_circle
		_:
			return

	obj.visible = true
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout",self,"_hide_circle", [obj])
	timer.one_shot = true
	timer.wait_time = 2
	timer.start()
	

func _hide_circle(obj):
	obj.visible = false
	self.update()
