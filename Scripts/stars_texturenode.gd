extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var stars = []
const nb_stars = 100

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a.z < b.z:
			return true
		return false



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(0,nb_stars-1):
		stars.append ( Vector3 (randi()%321, randi()%201, randi()%10) )
	#print (stars)
	

func _draw():
	stars.sort_custom(MyCustomSorter,"sort_ascending")
	for i in range(0,nb_stars-1):
		var col = (25 + (stars[i].z *25)) / 255
		#print (col)
		draw_circle(Vector2(int(stars[i].x), int(stars[i].y)), int(stars[i].z/2), Color(col,col,col/1.2))
		#draw_rect(Rect2(Vector2(stars[i].x,stars[i].y),Vector2(int(stars[i].z/2),int(stars[i].z/2))),Color(col,col,col))
		#draw_line(Vector2(stars[i].x,stars[i].y-int(stars[i].z/2)), Vector2(stars[i].x,stars[i].y+int(stars[i].z/2)-1), Color(col,col,col)  )
		#draw_line(Vector2(stars[i].x-int(stars[i].z/2),stars[i].y), Vector2(stars[i].x+int(stars[i].z/2)-1,stars[i].y), Color(col,col,col) )
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(0,nb_stars-1):
		#stars[i] = Vector3 (stars[i].x + (stars[i].y*delta), stars[i].y, stars[i].z)
		stars[i].x -= stars[i].z * delta
		if stars[i].x<-10:
			stars[i] = Vector3 (330, randi()%201, randi()%10)

	update()		
