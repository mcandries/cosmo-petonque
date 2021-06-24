extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var time_until_next_wind =  randi() % 5

var speed = 100
var current_path = ""
	# Arrive
	# Aloes_put
	# Go_Terrain

# Called when the node enters the scene tree for the first time.
func _ready():
	start_level()
	pass # Replace with function body.

func start_level():
	current_path = "Arrive"
	$Path2D_Aloes/PathFollow2D.unit_offset = 0
	$Path2D/PathFollow2D.unit_offset = 0	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match current_path:
		"Arrive":
			$Path2D/PathFollow2D.offset +=  speed*delta
			$Timmy_transp.position = $Path2D/PathFollow2D.position
			$Aloes_transp.position = $Path2D/PathFollow2D.position
			if $Path2D/PathFollow2D.unit_offset >= 1:
				current_path = "Aloes_Put"
				
		"Aloes_Put":
			$Path2D_Aloes/PathFollow2D.offset +=  speed*delta
			$Aloes_transp.position = $Path2D_Aloes/PathFollow2D.position
			if $Path2D_Aloes/PathFollow2D.unit_offset >= 1:
				current_path = "Go_Terrain"
				
		"Go_Terrain":
			$Path2D_Terrain/PathFollow2D.offset +=  speed*delta
			$Timmy_transp.position = $Path2D_Terrain/PathFollow2D.position
			if $Path2D_Terrain/PathFollow2D.unit_offset >= 1:
				current_path = ""
	
	time_until_next_wind -= delta
	if time_until_next_wind<=0 :
#		$Flower1.animation = "Wind"
		for flower in get_tree().get_nodes_in_group("flowers"):
			flower.frame = 0
			flower.play("Wind")
		time_until_next_wind = randi() % 5
	
	
	pass
