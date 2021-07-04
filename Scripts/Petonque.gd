extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const boule_impulse_factor = 1.4
const cochonet_impulse_factor = 3
const direction_random = 50
var time_until_next_wind =  randi() % 5
var Boule     = preload ("res://Scenes/Boule.tscn")
var Cochonet  = preload ("res://Scenes/Cochonet.tscn")
var boule
var Viseur    = preload ("res://Scenes/Viseur.tscn")
var viseur

const camera_scroll_unit = 5
const camera_scroll_acceleration = 6
const camera_scroll_acceleration_delay_reset_ms = 500
const initial_camera_position = Vector2 (511,300)
var camera_scroll_offset = 0
var camera_scroll_velocity = 0
var camera_scroll_velocity_last_delta = 0

var cochonet_on_field = false


var actual_cam : Camera2D

var speed = 100
var current_step = ""
	# Arrive
	# Aloes_put
	# Go_Terrain

# Called when the node enters the scene tree for the first time.
func _ready():
	#OS.window_fullscreen = !OS.window_fullscreen
	start_level()
	pass # Replace with function body.

func start_level():
	current_step = "Arrive"
	$Path2D_Aloes/PathFollow2D.unit_offset = 0
	$Path2D/PathFollow2D.unit_offset = 0	
	actual_cam = $Camera2D
	
	############################################################ DEBUG TIME
	current_step = "Wait_Timmy_Play"
	Gb.BUILD_TIME = true	
	############################################################
	
	if !Gb.BUILD_TIME:
		$AudioStreamPlayer.play()
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://Menu.tscn")

	move_flower(delta)

	match current_step:
		"Arrive":
			$Path2D/PathFollow2D.offset +=  speed*delta
			$Timmy_transp.position = $Path2D/PathFollow2D.position
			$Aloes_transp.position = $Path2D/PathFollow2D.position
			if $Path2D/PathFollow2D.unit_offset >= 1:
				current_step = "Aloes_Put"
				
		"Aloes_Put":
			$Path2D_Aloes/PathFollow2D.offset +=  speed*delta
			$Aloes_transp.position = $Path2D_Aloes/PathFollow2D.position
			if $Path2D_Aloes/PathFollow2D.unit_offset >= 1:
				current_step = "Go_Terrain"
				
		"Go_Terrain":
			$Path2D_Terrain/PathFollow2D.offset +=  speed*delta
			$Timmy_transp.position = $Path2D_Terrain/PathFollow2D.position
			if $Path2D_Terrain/PathFollow2D.unit_offset >= 1:
				current_step = "Wait_Timmy_Play"
		
		"Wait_Timmy_Play":
			if Input.is_action_just_pressed("mouse_left"):
				viseur = Viseur.instance()
				viseur.init_pos = $Viseur_StartPos.position
				self.add_child(viseur)
				current_step = "Timmy_Set_direction"
			scroll_cam()

		"Timmy_Set_direction":
			if Input.is_action_just_pressed("mouse_right"):
				viseur.queue_free()
				current_step = "Wait_Timmy_Play"
				
			if Input.is_action_just_pressed("mouse_left"):
				var impulse_factor
				if not cochonet_on_field:
					boule = Cochonet.instance() 
					cochonet_on_field = true
					impulse_factor = cochonet_impulse_factor
				else:
					boule = Boule.instance()
					impulse_factor = boule_impulse_factor
				boule.position = $Viseur_StartPos.position
				var final_vector : Vector2 = Vector2(0,0)
				print (viseur.selected_vector)
				var x_error = - (direction_random/2.0) + (randi() % direction_random)
				var y_error = - (direction_random/2.0) + (randi() % direction_random)
				final_vector.x =  viseur.selected_vector.x + x_error
				final_vector.y =  viseur.selected_vector.y + y_error
				print (final_vector)
				boule.apply_impulse(Vector2(0,0), final_vector * impulse_factor )
				self.add_child(boule)
				for i in boule.get_child_count():
					if boule.get_child(i) is Camera2D :
						boule.get_child(i).current = true
						actual_cam = boule.get_child(i)
				
				viseur.queue_free()
				current_step = "Rolling_Boule"
			
			scroll_cam()
			
		"Rolling_Boule" :
			if boule.sleeping:
				actual_cam.current = false
				$Camera2D.current = true
				$Camera2D.position = initial_camera_position
				actual_cam = $Camera2D
				current_step = "Wait_Timmy_Play"
		
	scroll_cam_process(delta)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		Gb.mouse_pos = event.position
		
	scroll_cam_input(event)

		 


func move_flower(delta):
	time_until_next_wind -= delta
	if time_until_next_wind<=0 :
#		$Flower1.animation = "Wind"
		for flower in get_tree().get_nodes_in_group("flowers"):
			flower.frame = 0
			flower.play("Wind")
		time_until_next_wind = randi() % 5

func scroll_cam():
	$Camera2D.position.y += camera_scroll_offset
	
	var viewport_height = get_viewport().get_visible_rect().size.y
	$Camera2D.position.y = clamp ($Camera2D.position.y, $Camera2D.limit_top + (viewport_height/2), $Camera2D.limit_bottom - (viewport_height/2))
	

func scroll_cam_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			camera_scroll_velocity_last_delta = OS.get_ticks_msec()
			if camera_scroll_offset <= 0 :
				camera_scroll_offset = camera_scroll_unit
				camera_scroll_velocity = camera_scroll_unit
			else :
				if camera_scroll_velocity <camera_scroll_unit:
					camera_scroll_velocity = camera_scroll_unit
				else:
					camera_scroll_velocity *=camera_scroll_acceleration
				camera_scroll_offset += camera_scroll_velocity
			
		if event.button_index == BUTTON_WHEEL_UP:
			camera_scroll_velocity_last_delta = OS.get_ticks_msec()
			if camera_scroll_offset >= 0 :
				camera_scroll_offset = -camera_scroll_unit
				camera_scroll_velocity = -camera_scroll_unit
			else : 
				if camera_scroll_velocity >-camera_scroll_unit:
					camera_scroll_velocity = -camera_scroll_unit
				else:
					camera_scroll_velocity *=camera_scroll_acceleration
					
				camera_scroll_offset += camera_scroll_velocity

func scroll_cam_process (delta):
	camera_scroll_offset = 0
	if OS.get_ticks_msec() - camera_scroll_velocity_last_delta > camera_scroll_acceleration_delay_reset_ms:
		camera_scroll_velocity = 0
