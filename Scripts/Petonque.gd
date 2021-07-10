extends Node2D


class Player_info :
	var boules_left:int = 3
	var score:int = 0
	var color:String = ""

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const boule_impulse_factor = 1.4
const cochonet_impulse_factor = 3
const direction_random = 60  #in pixels
const score_to_win = 3
#distance & color to qualify a launch
const precision_perfect = 5  
const precision_nice = 15
const precision_normal = 25
const precision_perfect_color = Color (20/255.0,240/255.0,20/255.0)
const precision_nice_color  = Color (20/255.0,200/255.0,20/255.0)
const precision_bad_color   = Color (240/255.0,20/255.0,20/255.0)
const closest_boules_delay = 2 #in Seconds

var time_until_next_wind =  randi() % 5
var BouleP    = preload ("res://Scenes/Boule.tscn")
var CochonetP = preload ("res://Scenes/Cochonet.tscn")
var cochonet
var boule
var ViseurP    = preload ("res://Scenes/Viseur.tscn")
var viseur

var player1_info = Player_info.new()
var player2_info = Player_info.new()

var players_info = [player1_info, player2_info]

var current_player : int # N° of the current playing player
var current_player_info : Player_info
var current_player_path : Path2D
var current_player_path_follow : PathFollow2D
var current_player_animated_sprite : AnimatedSprite

var other_player : int # N° of the current playing player
var other_player_info : Player_info
var other_player_path : Path2D
var other_player_path_follow : PathFollow2D
var other_player_animated_sprite : AnimatedSprite

const camera_scroll_unit = 5
const camera_scroll_acceleration = 6
const camera_scroll_acceleration_delay_reset_ms = 500
const initial_camera_position = Vector2 (511,300)
var camera_scroll_offset = 0
var camera_scroll_velocity = 0
var camera_scroll_velocity_last_delta = 0

var cochonet_on_field = false
var showed_cochonet_lighter_tip = false #The tips has been showed

var closest_boules_time = 0

var actual_cam : Camera2D

var speed = 150
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


	player1_info.score = 0
	player1_info.score = 0
	_reset_round()
		
	$CanvasLayerGUI/Control/LabelPrecision.text=""
	$CanvasLayerGUI/Control/LabelTips.text=""
	$CanvasLayerGUI/Control/LabelMainMessage.text=""
	_hide_all_GUI_boules()
		
	current_step = "Arrive"
	$Path2D_Aloes/PathFollow2D.unit_offset = 0
	$Path2D/PathFollow2D.unit_offset = 0	
	actual_cam = $Camera2D


	
	############################################################ DEBUG TIME
	current_step = "Wait_Player_Play"
	current_step = "Select_First_Player"
	#cochonet_on_field = true
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
			$Player1_AnimatedSprite.position = $Path2D/PathFollow2D.position
			$Player1_AnimatedSprite.position = $Path2D/PathFollow2D.position
			if $Path2D/PathFollow2D.unit_offset >= 1:
				current_step = "Aloes_Put"
				
		"Aloes_Put":
			$Path2D_Aloes/PathFollow2D.offset +=  speed*delta
			$Player1_AnimatedSprite.position = $Path2D_Aloes/PathFollow2D.position
			if $Path2D_Aloes/PathFollow2D.unit_offset >= 1:
				current_step = "Select_First_Player"
				
		"Select_First_Player":
			_set_player(1 + (randi() % 1))
			_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage,"Player "+ str(current_player) + " start !",2)
			current_step = "Go_Terrain"
			
			
		"Go_Terrain":
			current_player_path_follow.offset +=  speed*delta
			current_player_animated_sprite.position = current_player_path_follow.position
			if current_player_path_follow.unit_offset >= 1:
				current_step = "Wait_Player_Play"
		
		"Wait_Player_Play":
			if Input.is_action_just_pressed("mouse_left"):
				$Viseur_StartPos.position = get_node("Player"+str(current_player)+"_AnimatedSprite/PlayerStartPos").global_position
				viseur = ViseurP.instance()
				viseur.init_pos = $Viseur_StartPos.position
				self.add_child(viseur)
				current_step = "Player_Set_direction"
			scroll_cam()

		"Player_Set_direction":
				
			if not cochonet_on_field and not showed_cochonet_lighter_tip:
				_set_label_text_for_second ($CanvasLayerGUI/Control/LabelTips, "Do not forget that it is lighter ...", 5.0)
				showed_cochonet_lighter_tip = true
			
			if Input.is_action_just_pressed("mouse_right"):
				viseur.queue_free()
				current_step = "Wait_Player_Play"
				
			if Input.is_action_just_pressed("mouse_left"):
				var impulse_factor
				if not cochonet_on_field:
					boule = CochonetP.instance() 
					cochonet = boule
					cochonet_on_field = true
					impulse_factor = cochonet_impulse_factor
				else:
					boule = BouleP.instance()
					boule.player_number = current_player
					current_player_info.boules_left -= 1
					boule.add_to_group("boules")
					boule.add_to_group("boules_player"+str(current_player))
					impulse_factor = boule_impulse_factor
				boule.position = $Viseur_StartPos.position
				var final_vector : Vector2 = Vector2(0,0)
				print (viseur.selected_vector)
				var x_error = - (direction_random/2.0) + (randi() % direction_random)
				var y_error = - (direction_random/2.0) + (randi() % direction_random)
				final_vector.x =  viseur.selected_vector.x + x_error
				final_vector.y =  viseur.selected_vector.y + y_error
				print (final_vector)
				var error_dist = final_vector.distance_to(viseur.selected_vector)
				if error_dist<=precision_perfect:
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelPrecision, "Perfect Precision !", 3.0)
					$CanvasLayerGUI/Control/LabelPrecision.add_color_override("font_color",precision_perfect_color)
				elif error_dist<=precision_nice:
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelPrecision, "Nice Precision !", 3.0)
					$CanvasLayerGUI/Control/LabelPrecision.add_color_override("font_color",precision_nice_color)
					$AudioStreamPlayer_VoiceWhouah.play()
				elif error_dist<=precision_normal:
					$CanvasLayerGUI/Control/LabelPrecision.text = ""
				else:
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelPrecision, "oHoH You miss of precision !", 3.0)
					$CanvasLayerGUI/Control/LabelPrecision.add_color_override("font_color",precision_bad_color)
					
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
				if boule is BouleC:
					var closest_player = _closest_player()
					for b in _closest_player_boules():
						b.show_circle(players_info[closest_player-1].color, 2)
					current_step = "Showing_Closest_Boules"
				else: #on  joue le cochonet acutellement
					_reset_cam_to_player()
					current_step = "Wait_Player_Play"

		"Showing_Closest_Boules":
			closest_boules_time += delta
			if closest_boules_time >= closest_boules_delay:
				closest_boules_time = 0
				_reset_cam_to_player()
				current_step = "Study_Game"

		
		"Study_Game" :
			
			# --- conditions imbriquées / liées
			#si je suis le plus proche et que l'autre à encore des boules, à lui
			if _closest_player() == current_player and other_player_info.boules_left>=1  : 
				current_step = "Swap_Player_Pos"
				continue
			
			#sinon si j'ai encore des boules, à moi
			if current_player_info.boules_left>=1:
				current_step = "Wait_Player_Play"
				continue
			
			#sinon si je n'ai plus de boules mais que l'autre oui, à lui
			if other_player_info.boules_left>=1:
				current_step = "Swap_Player_Pos"
				continue
			
			# --- si on arrive ici, fin de manche
			var round_winner_number = _closest_player()
			players_info[round_winner_number-1].score += _closest_player_boules().size()
			if players_info[round_winner_number-1].score>score_to_win:
				players_info[round_winner_number-1].score = score_to_win
			_update_score_show()
			_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Player "+str(round_winner_number)+" win this round with " + str(_closest_player_boules().size()) + " points !",4)
			if round_winner_number ==1:
				$AudioStreamPlayer_VoiceApplause.play()
			_audioread_score()
			_reset_round()
			if round_winner_number == current_player:
				current_step = "Swap_Player_Pos"
			else:
				current_step = "Wait_Player_Play"

			if player1_info.score>=score_to_win:
				_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "You win !",4)
				$AudioStreamPlayer_VoiceVictory.play()
				start_level()
				continue
				
			if player2_info.score>=score_to_win:
				_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "You loose !",4)
				$AudioStreamPlayer_VoiceDefeat.play()
				start_level()
				continue

			
		"Swap_Player_Pos":
			var all_ok = true
			
			if not (current_player_path_follow.unit_offset <= 0):
				current_player_path_follow.offset -=  speed*delta
				current_player_animated_sprite.position = current_player_path_follow.position
				all_ok = false

			if not (other_player_path_follow.unit_offset >= 1):								
				other_player_path_follow.offset +=  speed*delta
				other_player_animated_sprite.position = other_player_path_follow.position
				all_ok = false
				
			if all_ok: 
				_set_player(_inverse_player_number(current_player))
				current_step = "Wait_Player_Play"

		
	
			
	scroll_cam_process(delta)
	_show_GUI_boules(1, player1_info.boules_left)
	_show_GUI_boules(2, player2_info.boules_left)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		Gb.mouse_pos = event.position
		
	scroll_cam_input(event)

func _reset_cam_to_player():
	actual_cam.current = false
	$Camera2D.current = true
	$Camera2D.position = initial_camera_position
	actual_cam = $Camera2D

func _reset_round():
	player1_info.boules_left = 3
	player1_info.color = "blue"
	player2_info.boules_left = 3
	player2_info.color = "red"
	if cochonet != null:
		cochonet.queue_free()
	cochonet_on_field = false
		
	for b in get_tree().get_nodes_in_group("boules"):
		b.queue_free()

func _hide_all_GUI_boules():
	$CanvasLayerGUI/P1B1.visible = false
	$CanvasLayerGUI/P1B2.visible = false
	$CanvasLayerGUI/P1B3.visible = false
	$CanvasLayerGUI/P2B1.visible = false
	$CanvasLayerGUI/P2B2.visible = false
	$CanvasLayerGUI/P2B3.visible = false

func _show_GUI_boules(player_number, boules_count):
	match player_number:
		1:
			$CanvasLayerGUI/P1B1.visible = boules_count>=1
			$CanvasLayerGUI/P1B2.visible = boules_count>=2
			$CanvasLayerGUI/P1B3.visible = boules_count>=3
		2:
			$CanvasLayerGUI/P2B1.visible = boules_count>=1
			$CanvasLayerGUI/P2B2.visible = boules_count>=2
			$CanvasLayerGUI/P2B3.visible = boules_count>=3

func _inverse_player_number(number):
	return 2 - (number + 1) %2


func _closest_player () -> int:
	var closest_dist = INF
	var closest_player = null
	
	for b in get_tree().get_nodes_in_group("boules"):
		var d = (b as Node2D).position.distance_to(cochonet.position)
		if d < closest_dist :
			closest_dist = d
			closest_player = b.player_number
	
	return closest_player

func _closest_player_boules () -> Array:
	
	var closest_player = _closest_player ()
	var closest_player_boules = []
	var farest_player  = _inverse_player_number(closest_player)
	var farest_player_closest_dist = INF

	#cherche la boule la plus porche pour le moins bon des joeurs
	for b in get_tree().get_nodes_in_group("boules_player"+str(farest_player)):
		var d = (b as Node2D).position.distance_to(cochonet.position)
		if d < farest_player_closest_dist :
			farest_player_closest_dist = d

	#compte le nombre de boules plus proche que ça pour le meilleur joeur :
	for b in get_tree().get_nodes_in_group("boules_player"+str(closest_player)):
		var d = (b as Node2D).position.distance_to(cochonet.position)
		if d < farest_player_closest_dist :
			closest_player_boules.append(b)
	
	return closest_player_boules
	


func _set_player (number):
	current_player = number
	var p = str(current_player)
	current_player_animated_sprite = get_node("Player"+p+"_AnimatedSprite")
	current_player_path = get_node("Path2D_Terrain_Player"+p)
	current_player_path_follow = get_node("Path2D_Terrain_Player"+p+"/PathFollow2D")
	current_player_info = players_info[current_player-1]
	
	other_player = _inverse_player_number (number)
	var o = str(other_player)
	other_player_animated_sprite = get_node("Player"+o+"_AnimatedSprite")
	other_player_path = get_node("Path2D_Terrain_Player"+o)
	other_player_path_follow = get_node("Path2D_Terrain_Player"+o+"/PathFollow2D")
	other_player_info = players_info[other_player-1]

func _update_score_show():
	$CanvasLayerGUI/Control/LabelScore.text = str (player1_info.score) + " - " + str (player2_info.score)

			
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

func _set_label_text_for_second (label : Label, text : String, second : int):
	label.text = text
	var timer = Timer.new()
	timer.connect("timeout",self,"_on__set_label_text_for_second_timeout", [label]) 
	add_child(timer) #to process
	var group_name = "_set_label_text_for_second_timer_"+str(label.get_instance_id())
	for n in get_tree().get_nodes_in_group(group_name):
		n.queue_free()
	timer.add_to_group(group_name)
	timer.wait_time = second
	timer.one_shot = true
	timer.start() #to start
	
func _on__set_label_text_for_second_timeout (label):
	label.text = ""
	self.update()

func _audioread_number(number):
	number = clamp(number,1,13)
	var audio_file = load ("res://Voices-Line/"+str(number)+".mp3")
	audio_file.set_loop(false)
	$AudioStreamPlayer_VoiceNumber.stream = audio_file
	$AudioStreamPlayer_VoiceNumber.play()
	

func _audioread_score():
	_audioread_number(player1_info.score)
	var timer = Timer.new()
	timer.connect("timeout",self,"_on___audioread_score_timeout", [player2_info.score]) 
	add_child(timer) #to process
	timer.wait_time = 2
	timer.one_shot = true
	timer.start()
	
func _on___audioread_score_timeout (score):
	_audioread_number(score)
	
