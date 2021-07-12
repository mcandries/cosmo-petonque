extends RigidBody2D

class_name CochonetC

signal out_of_field

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RigidBody2D_body_entered(body):
	if body is TileMap:
		emit_signal("out_of_field")
