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
export var color = Color (0,0,0)



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
	draw_line(init_pos, target_pos, color)
	if Gb.P_Difficulty<=1:
		var ln_col = color * 0.9
		var from_pos  = target_pos
		var to_pos
		var nb_step
		var col_mult
		if Gb.P_Difficulty == 0 :
			nb_step = 15
			col_mult = 0.8
		else : 
			nb_step = 9
			col_mult = 0.7
			
		for i in range (nb_step):
			to_pos = from_pos + (selected_vector.normalized()*(selected_power/30))
			if i%2 != 1 : 
				draw_line(from_pos, to_pos , ln_col)
			from_pos = to_pos
			ln_col = ln_col * col_mult


#		#var v1 := Vector2 (0,0)
#		#var v2 := Vector2 (-500,0)
#		#la_queue.apply_impulse(v1,v2)
#		var angle_queue = la_queue.position.angle_to_point(mouse_pos)
#		var v2 := Vector2 (cos(angle_queue)*200, sin(angle_queue)*200)
#		la_queue.apply_central_impulse (v2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
