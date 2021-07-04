extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var init_pos = Vector2 (0,0)
var target_pos = Vector2 (0,0)
var selected_angle = 0
var selected_direction = 0
var selected_vector = Vector2 (0,0)
var selected_power = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	#target_pos.x = Gb.mouse_pos.x 
	#target_pos.y = clamp (Gb.mouse_pos.y, init_pos.y, INF)

	target_pos.x = get_global_mouse_position().x
	target_pos.y = clamp (get_global_mouse_position().y, init_pos.y, INF)

	selected_angle = init_pos.angle_to_point(target_pos)
	selected_power = init_pos.distance_to(target_pos)
	selected_vector = target_pos - init_pos
	
	self.update()

func _draw():
	draw_line(init_pos, target_pos, Color(255,0,0))


#		#var v1 := Vector2 (0,0)
#		#var v2 := Vector2 (-500,0)
#		#la_queue.apply_impulse(v1,v2)
#		var angle_queue = la_queue.position.angle_to_point(mouse_pos)
#		var v2 := Vector2 (cos(angle_queue)*200, sin(angle_queue)*200)
#		la_queue.apply_central_impulse (v2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
