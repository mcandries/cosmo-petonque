extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#OS.set_window_size(Vector2(320*4, 200*4))
	$TextureRect.rect_size = OS.window_size
	$Viewport.size = Vector2 (320, 200)
	$TextureRect.texture = $Viewport.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
