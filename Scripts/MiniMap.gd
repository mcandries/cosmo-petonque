extends Node2D


# to set
var field_top_left : Node2D = null
var cochonet : CochonetC = null
var mini_boules : Array # Array of BoulesC

var blue_circle  = preload("res://Arts/blue_circle.png")
var red_circle   = preload("res://Arts/red_circle.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.texture = $Viewport.get_texture()
	mini_boules.clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Viewport/mini_cochonnet.visible = false
	if not cochonet == null :
			if is_instance_valid(cochonet) :
				var pos : Vector2 = (cochonet.position - field_top_left.global_position)
				$Viewport/mini_cochonnet.position.x = (pos.x/10) * 2
				$Viewport/mini_cochonnet.position.y = (pos.y/10) * 2
				$Viewport/mini_cochonnet.visible = true

	for b in mini_boules:
		b.queue_free()
	mini_boules.clear()

	for b in get_tree().get_nodes_in_group("boules"):
		var mini_boule = Sprite.new()
		if b.player_number == 1 :
			mini_boule.texture = blue_circle
		else :
			mini_boule.texture = red_circle
		mini_boule.scale = Vector2 (0.03, 0.03)
		var pos : Vector2 = (b.position - field_top_left.global_position)
		mini_boule.position.x = (pos.x/10) * 2
		mini_boule.position.y = (pos.y/10) * 2
		self.add_child(mini_boule)
		mini_boule.visible = true
		mini_boules.append(mini_boule)
			
#	pass
