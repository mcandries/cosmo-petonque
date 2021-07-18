extends "res://Scripts/Petonque.gd"

var cheatcodedetect


func _init():
	music_playlist = ["boostiooooo v3.2", "water world v3.5"]
	current_level = 1

func _ready():
	cheatcodedetect = CheatCodeDetector.new()
	cheatcodedetect.codes = ["marisabat"]
	cheatcodedetect.connect("cheat_detected", self, "_on__cheatdected")
	self.add_child(cheatcodedetect)


func _process(delta):
	move_flower(delta)

func move_flower(delta):
	time_until_next_wind -= delta
	if time_until_next_wind<=0 :
#		$Flower1.animation = "Wind"
		for flower in get_tree().get_nodes_in_group("flowers"):
			flower.frame = 0
			flower.play("Wind")
		time_until_next_wind = randi() % 5
		
func _on__cheatdected(code):
	if code == "marisabat":
		$Taupes.visible = true
		#for n in get_tree().get_nodes_in_group("marisabat"):
		#	n.visible = true
