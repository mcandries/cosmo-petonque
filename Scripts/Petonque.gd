extends Node2D


class Player_info :
	var boules_left:int = 3
	var score:int = 0
	var color:String = ""
	var viseur_color = Color (0,0,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const boule_impulse_factor = 1.4
const cochonet_impulse_factor = 3
var  direction_random = 40  #in pixels
const score_to_win = 6 ############################ DBG !!! 13
#distance & color to qualify a launch
const precision_perfect = 0.15  
const precision_nice = 0.3
const precision_normal = 0.5
const precision_perfect_color = Color (20/255.0,240/255.0,20/255.0)
const precision_nice_color  = Color (20/255.0,200/255.0,20/255.0)
const precision_bad_color   = Color (240/255.0,20/255.0,20/255.0)
const closest_boules_delay = 1 #in Seconds

var music_playlist

var music_player_cursor = 0


var time_until_next_wind =  randi() % 5
var BouleP    = preload ("res://Scenes/Boule.tscn")
var CochonetP = preload ("res://Scenes/Cochonet.tscn")
var cochonet setget cochonet_setter
var cochonet_last_launcher
var boule
var ViseurP    = preload ("res://Scenes/Viseur.tscn")
var PrecisionSetP = preload ("res://Scenes/PrecisionSet.tscn")
var precision_set
var precision_set_setted = false
var precision_set_canceled = false
var precision_mult
var viseur
var viseur_selected_position
var cochonet_out_of_field_detected = false
var current_level = 1

var return_to_menu_launched = false

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

var go_to_next_level_launched = false

var closest_boules_time = 0

var actual_cam : Camera2D

var speed = 150
var speed_swap = 250
var current_step = ""
	# Arrive
	# Aloes_put
	# Go_Terrain



# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer_Music.volume_db = Gb.P_Volume_Music
	$AudioStreamPlayer_VoiceApplause.volume_db = Gb.P_Volume_Voice
	$AudioStreamPlayer_VoiceDefeat.volume_db = Gb.P_Volume_Voice
	$AudioStreamPlayer_VoiceINeedHealing.volume_db = Gb.P_Volume_Voice
	$AudioStreamPlayer_VoiceNumber.volume_db = Gb.P_Volume_Voice
	$AudioStreamPlayer_VoiceTimmyTimmy.volume_db = Gb.P_Volume_Voice
	$AudioStreamPlayer_VoiceVictory.volume_db = Gb.P_Volume_Voice
	$AudioStreamPlayer_VoiceWhouah.volume_db = Gb.P_Volume_Voice
	_on_AudioStreamPlayer_Music_finished()
	
	$CanvasLayerGUI/Minimap.field_top_left = $Anchor_Field_Start/Anchor_Field_Left
	
	start_level()


func start_level():
	player1_info.score = 0
	player1_info.viseur_color = Color (85/255.0,85/255.0,255/255.0)
	player2_info.score = 0
	player2_info.viseur_color = Color (255/255.0,85/255.0,85/255.0)
	_update_score_show()
	_reset_round()
			
	$CanvasLayerGUI/Control/LabelPrecision.text=""
	$CanvasLayerGUI/Control/LabelTips.text=""
	$CanvasLayerGUI/Control/LabelMainMessage.text=""
	_hide_all_GUI_boules()
	
	$Anchor_Field_Start.visible = false
	
	current_step = "Arrive"
	$Path2D_Aloes/PathFollow2D.unit_offset = 0
	$Path2D/PathFollow2D.unit_offset = 0	
	actual_cam = $Camera2D
	
	############################################################ DEBUG TIME
	Gb.BUILD_TIME = false
#	current_step = "Wait_Player_Play"
	#current_step = "Select_First_Player"

	############################################################
	if !Gb.BUILD_TIME:
		#cochonet_on_field = true
		$AudioStreamPlayer_Music.play()
		randomize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://Menu.tscn")

	$Anchor_Field_Start.visible = false
	$Anchor_Field_Start.visible = false


	if cochonet_out_of_field_detected: #Le cochonet viens de sortir du terrain :
		cochonet_out_of_field_detected = false
		var tmp_winner
		if  (player1_info.boules_left == 0) or (player2_info.boules_left == 0): #Only if one of the two players have 0 boules left
			if player1_info.boules_left >=1  and player2_info.boules_left ==0:
				_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Cochonet go out of field ! Player 1 get " + str (player1_info.boules_left) + " points", 5)
				player1_info.score += player1_info.boules_left
				tmp_winner = 1
			if player1_info.boules_left == 0 and player2_info.boules_left >=1:
				_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Cochonet go out of field ! Player 2 get " + str (player2_info.boules_left) + " points", 5)
				player2_info.score += player2_info.boules_left
				tmp_winner = 2
			if tmp_winner == 1:
				$AudioStreamPlayer_VoiceApplause.play()
			if player1_info.boules_left == 0 and player2_info.boules_left ==0:
				_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Null round !", 5)
				tmp_winner = current_player #to make them swap
			if check_and_set_current_step_if_endgame():
				_update_score_show()
			else:
				_audioread_score()
				_update_score_show()
				_reset_round()
				if tmp_winner == current_player:
					current_step = "Swap_Player_Pos"
				else:
					current_step = "Wait_Player_Play"
		else: #Les deux en ont encore ? Dans ce cs il faut faire relancer le cochonet au dernier qui l'a lancé
			cochonet.queue_free()
			cochonet_on_field = false
			_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Cochonet go out of field ! Last cochonet launcher relaunch-it !", 5)
			_reset_cam_to_player()
			if cochonet_last_launcher != current_player:
				current_step = "Swap_Player_Pos"
			else:
				current_step = "Wait_Player_Play"
		

	match current_step:
		"Arrive":
			$Path2D/PathFollow2D.offset +=  speed*delta
			$Player1_AnimatedSprite.position = $Path2D/PathFollow2D.position
			$Aloes_transp.position = $Path2D/PathFollow2D.position
			if $Path2D/PathFollow2D.unit_offset >= 1:
				current_step = "Aloes_Put"
				
		"Aloes_Put":
			$Path2D_Aloes/PathFollow2D.offset +=  speed*delta
			$Aloes_transp.position = $Path2D_Aloes/PathFollow2D.position
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
			if not cochonet_on_field:
				$Anchor_Field_Start.visible = true
			
			if not cochonet_on_field and not showed_cochonet_lighter_tip:
				if Gb.P_Show_Tips :
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelTips, "Chochonet is lighter and go further than ball...", 5.0)
				showed_cochonet_lighter_tip = true

			if Input.is_action_just_pressed("mouse_left"):
				$Viseur_StartPos.position = get_node("Player"+str(current_player)+"_AnimatedSprite/PlayerStartPos").global_position
				viseur = ViseurP.instance()
				viseur.color = current_player_info.viseur_color
				viseur.init_pos = $Viseur_StartPos.position
				self.add_child(viseur)
				current_step = "Player_Set_direction"
			scroll_cam()

		"Player_Set_direction":
			
			if Gb.P_Show_Tips :
				_set_label_text_for_second ($CanvasLayerGUI/Control/LabelTips, "Choose direction and power.\nThe ball will roll further than the point you choose...", 5.0)
			
			if not cochonet_on_field:
				$Anchor_Field_Start.visible = true
			
			if Input.is_action_just_pressed("mouse_right"):
				viseur.queue_free()
				current_step = "Wait_Player_Play"
				
			if Input.is_action_just_pressed("mouse_left"):
				viseur_selected_position = viseur.selected_vector
				viseur.queue_free()
				precision_set = PrecisionSetP.instance()
				$CanvasLayerGUI.add_child(precision_set)
				precision_set.position = $CanvasLayerGUI/PrecisionSetPos.position
				precision_set.connect("precision_set", self, "_on__precision_set")
				precision_set.connect("precision_cancel", self, "_on__precision_cancel")
				current_step = "Player_Set_Precision"
				
			scroll_cam()
			
		"Player_Set_Precision":
	
			if Gb.P_Show_Tips :
				_set_label_text_for_second ($CanvasLayerGUI/Control/LabelTips, "Try to do a precise shot by clicking\nwhen the moving line is on the Green zone !", 5.0)
			
			if precision_set_canceled:
				precision_set_canceled = false
				precision_set.queue_free()
				_set_label_text_for_second ($CanvasLayerGUI/Control/LabelTips, "", 0.1)
				current_step = "Wait_Player_Play"
				
			if precision_set_setted:
				precision_set_setted = false
				precision_set.queue_free()
				
				var impulse_factor
				if not cochonet_on_field:
					boule = CochonetP.instance() 
					cochonet = boule
					$CanvasLayerGUI/Minimap.cochonet = cochonet
					cochonet_on_field = true
					cochonet_last_launcher = current_player
					impulse_factor = cochonet_impulse_factor
					cochonet.connect("out_of_field",self, "_on___cochonet_out_of_field")
				else:
					boule = BouleP.instance()
					boule.level_number = current_level
					boule.player_number = current_player
					current_player_info.boules_left -= 1
					boule.add_to_group("boules")
					boule.add_to_group("boules_player"+str(current_player))
					impulse_factor = boule_impulse_factor
				boule.position = $Viseur_StartPos.position
				var final_vector : Vector2 = Vector2(0,0)
#				var x_error = - (direction_random/2.0) + (randi() % direction_random)
#				var y_error = - (direction_random/2.0) + (randi() % direction_random)
				var x_error = direction_random*precision_mult
				var y_error = direction_random*precision_mult
				final_vector.x =  viseur_selected_position.x + x_error
				final_vector.y =  viseur_selected_position.y + y_error
				if abs(precision_mult)<=precision_perfect:
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelPrecision, "Perfect Precision !", 3.0)
					$CanvasLayerGUI/Control/LabelPrecision.add_color_override("font_color",precision_perfect_color)
					$AudioStreamPlayer_VoiceWhouah.play()
				elif abs(precision_mult)<=precision_nice:
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelPrecision, "Nice Precision !", 3.0)
					$CanvasLayerGUI/Control/LabelPrecision.add_color_override("font_color",precision_nice_color)
				elif abs(precision_mult)<=precision_normal:
					$CanvasLayerGUI/Control/LabelPrecision.text = ""
				else:
					_set_label_text_for_second ($CanvasLayerGUI/Control/LabelPrecision, "Ho no ! You miss of precision !", 3.0)
					$CanvasLayerGUI/Control/LabelPrecision.add_color_override("font_color",precision_bad_color)
					$AudioStreamPlayer_VoiceINeedHealing.play()
					
				boule.apply_impulse(Vector2(0,0), final_vector * impulse_factor )
				
				self.add_child(boule)
				for i in boule.get_child_count():
					if boule.get_child(i) is Camera2D :
						boule.get_child(i).current = true
						actual_cam = boule.get_child(i)
				
				_set_label_text_for_second ($CanvasLayerGUI/Control/LabelTips, "", 0.1)
				current_step = "Rolling_Boule"
			
			scroll_cam()
			
		"Rolling_Boule" :
			if boule is CochonetC:
				$Anchor_Field_Start.visible = true

			if boule.sleeping:
				show_nearest_boule_circle()
				current_step = "Showing_Closest_Boules"
				if not (boule is BouleC): #on  joue le cochonet acutellement
					var dist_tmp
					dist_tmp = boule.position.y - $Anchor_Field_Start.position.y
					if dist_tmp<600 or dist_tmp>1000:
						_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Cochonet is out of limit (must be between 6 meters and 10 meters)", 5)
						boule.queue_free()
						cochonet_on_field = false
						_reset_cam_to_player()
						current_step = "Wait_Player_Play"
					dist_tmp = abs(boule.position.x - $Anchor_Field_Start.position.x)
					if dist_tmp>200:
						_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Cochonet is too close from border", 5)
						boule.queue_free()
						cochonet_on_field = false
						_reset_cam_to_player()
						current_step = "Wait_Player_Play"

		"Showing_Closest_Boules":
			if get_tree().get_nodes_in_group("boules").size()==0: # si pas de boules sur le terrain :
				_reset_cam_to_player()
				current_step = "Study_Game" # on n'attend pas
			else : 
				closest_boules_time += delta
				if closest_boules_time >= closest_boules_delay:
					closest_boules_time = 0
					_reset_cam_to_player()
					current_step = "Study_Game"

		
		"Study_Game" :
			scroll_cam()
			
			# --- conditions imbriquées / liées
			#si je suis le plus proche et que l'autre à encore des boules, à lui
			if not _closest_player() == null: #pour ne pas tester ce cas s'il n'y a que le cochonet sur la piste
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
			if players_info[round_winner_number-1].score>=score_to_win:
				players_info[round_winner_number-1].score = score_to_win
			else : 
				_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "Player "+str(round_winner_number)+" win this round with " + str(_closest_player_boules().size()) + " points !",4)
				if round_winner_number == 1:
					$AudioStreamPlayer_VoiceApplause.play()
				_audioread_score()				
				_reset_round()
			
			_update_score_show()

			if round_winner_number != current_player:
				current_step = "Swap_Player_Pos"
			else:
				current_step = "Wait_Player_Play"

			check_and_set_current_step_if_endgame()

				
			
		"Swap_Player_Pos":
			scroll_cam()
			var all_ok = true
			
			if not (current_player_path_follow.unit_offset <= 0):
				current_player_path_follow.offset -=  speed_swap*delta
				current_player_animated_sprite.position = current_player_path_follow.position
				all_ok = false

			if not (other_player_path_follow.unit_offset >= 1):								
				other_player_path_follow.offset +=  speed_swap*delta
				other_player_animated_sprite.position = other_player_path_follow.position
				all_ok = false
			else : 
				var my_array = Array(other_player_animated_sprite.frames.get_animation_names())
				if my_array.has("ready_battle"):
					other_player_animated_sprite.animation = "ready_battle"
				
			if all_ok: 
				_set_player(_inverse_player_number(current_player))
				current_step = "Wait_Player_Play"
			
		"Go_Next_Level":
			if not go_to_next_level_launched:
				go_to_next_level_launched = true
				yield(get_tree().create_timer(4.0), "timeout")
				get_tree().change_scene("res://Petonque_lvl2.tscn")
				
		"Return_To_Menu":
		
			if not return_to_menu_launched:
				return_to_menu_launched = true
#				var timer = Timer.new()
#				timer.second = 5
#				timer.connect("timeout","_on___return_to_menu")
#				add_child(timer)
#				timer.start()
				yield(get_tree().create_timer(4.0), "timeout")
				get_tree().change_scene("res://Menu.tscn")
				
				
	
			
	scroll_cam_process(delta)
	_show_GUI_boules(1, player1_info.boules_left)
	_show_GUI_boules(2, player2_info.boules_left)
	pass

func show_nearest_boule_circle():
	var closest_player = _closest_player()
	for b in _closest_player_boules():
		b.show_circle(players_info[closest_player-1].color, 2)

func check_and_set_current_step_if_endgame() -> bool:
	if player1_info.score>=(score_to_win/10.0)*8:
		$AudioStreamPlayer_VoiceTimmyTimmy.play()

	if player1_info.score>=score_to_win:
		_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "You win !",4)
		$AudioStreamPlayer_VoiceVictory.play()
		if current_level <2:
			current_step = "Go_Next_Level"
		else : 
			current_step = "Return_To_Menu"
		return true
		
	if player2_info.score>=score_to_win:
		_set_label_text_for_second($CanvasLayerGUI/Control/LabelMainMessage, "You loose !",4)
		_show_animated_sprite_for_second ($CanvasLayerGUI/DefeatSprite,4)
		$AudioStreamPlayer_VoiceDefeat.play()
		current_step = "Return_To_Menu"
		return true
	
	return false

func _input(event):
	if event is InputEventMouseMotion:
		Gb.mouse_pos = event.position
		
	scroll_cam_input(event)


func _reset_cam_to_player():
#	if actual_cam != null:
#		actual_cam.current = false
	actual_cam = $Camera2D
	$Camera2D.current = true
	$Camera2D.position = initial_camera_position
	

func _reset_round():
	_reset_cam_to_player()
	cochonet_out_of_field_detected = false
	player1_info.boules_left = 3
	player1_info.color = "blue"
	player2_info.boules_left = 3
	player2_info.color = "red"
	if is_instance_valid(cochonet):
		cochonet.queue_free()
	cochonet_on_field = false
	showed_cochonet_lighter_tip = false
		
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


func _closest_player ():
	var closest_dist = INF
	var closest_player = null
	
	if not (is_instance_valid(cochonet)):
		return null
	
	for b in get_tree().get_nodes_in_group("boules"):
		var d = (b as Node2D).position.distance_to(cochonet.position)
		if d < closest_dist :
			closest_dist = d
			closest_player = b.player_number
	
	return closest_player

func _closest_player_boules () -> Array:
	
	var closest_player = _closest_player ()
	if closest_player == null:
		return []
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
	$CanvasLayerGUI/Control/LabelScore.text = str (player1_info.score) + "/" + str (score_to_win) + " - " + str (player2_info.score) + "/" + str (score_to_win)

			


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
	if number is int:
		number = clamp(number,0,13)

	var audio_file = load ("res://Voices-Line/"+str(number)+".mp3")
	audio_file.set_loop(false)
	$AudioStreamPlayer_VoiceNumber.stream = audio_file
	$AudioStreamPlayer_VoiceNumber.play()
	

func _timer_func (delay, function, function_param):
	var timer = Timer.new()
	timer.connect("timeout",self,function, function_param) 
	add_child(timer) #to process
	timer.wait_time = delay
	timer.one_shot = true
	timer.start()
	

func _audioread_score():
	_audioread_number(player1_info.score)
	_timer_func(1.25, "_on___audioread_score_timeout", ["To"])
	_timer_func(2.0, "_on___audioread_score_timeout", [player2_info.score])

	
func _on___audioread_score_timeout (score):
	_audioread_number(score)
	
func _on_Player1_AnimatedSprite_animation_finished():
	$Player1_AnimatedSprite.animation = "idle_front"
	
func _on_Player2_AnimatedSprite_animation_finished():
	$Player2_AnimatedSprite.animation = "idle_front"


func _show_animated_sprite_for_second(sprite, second):
	sprite.visible = true
	var timer = Timer.new()
	timer.connect("timeout",self,"_on___show_animated_sprite_for_second_timeout", [sprite]) 
	add_child(timer) #to process
	timer.wait_time = second
	timer.one_shot = true
	timer.start()

func _on___show_animated_sprite_for_second_timeout(sprite):
	sprite.visible = false
	
func _on___cochonet_out_of_field():
#	print ("out of field")
	cochonet_out_of_field_detected = true

func _on__precision_cancel():
	precision_set_canceled = true
	print ("canceled")
	
func _on__precision_set(precision):
	precision_mult = precision
	precision_set_setted = true
	
	
func cochonet_setter (new_value):
	cochonet = new_value
	$CanvasLayerGUI/Minimap.cochonet = new_value


func _on_AudioStreamPlayer_Music_finished():
	music_player_cursor += 1
	if (music_player_cursor>music_playlist.size()-1):
		music_player_cursor = 0
	var zik : AudioStreamMP3 = load ("res://Musics/"+music_playlist[music_player_cursor]+".mp3")
	zik.set_loop(false)
	$AudioStreamPlayer_Music.stream = zik
	$AudioStreamPlayer_Music.play()
