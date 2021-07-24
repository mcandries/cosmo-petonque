extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal precision_set
signal precision_cancel

var cursor_speed = 675 #pixel/seconds
var cursor_sns = 1

var x_start 
var x_stop

# Called when the node enters the scene tree for the first time.
func _ready():
	match Gb.P_Difficulty:
		0:
			cursor_speed = 450
		1:
			cursor_speed = 700
		2:
			cursor_speed = 900
		3:
			cursor_speed = 1100
		
	x_start = $precision_bar.position.x - $precision_bar.get_rect().size.x/2
	x_stop =  $precision_bar.position.x + $precision_bar.get_rect().size.x/2
	$precision_cursor.position.x = x_start

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.is_action_just_pressed("mouse_left"):
		var precision # from 0 to 1. 1 is full precision
		var abs_cursor = abs ($precision_cursor.position.x)
		precision = (abs_cursor/x_stop)
		if $precision_cursor.position.x <0:
			precision = -precision
		self.emit_signal("precision_set", precision)

	if Input.is_action_just_pressed("mouse_right"):
		self.emit_signal("precision_cancel")
	
	$precision_cursor.position.x += cursor_speed * cursor_sns * delta
	$precision_cursor.position.x = clamp($precision_cursor.position.x, x_start , x_stop)
	
	if ($precision_cursor.position.x == x_start) or ($precision_cursor.position.x == x_stop)  :
			cursor_sns = -cursor_sns
	pass



