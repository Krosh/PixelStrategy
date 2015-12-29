extends Node2D


var map = get_node("map")
var width = 200
var height = 200
var activeCountry

var rightMousePressed = false
var leftMousePressed = false

func updateGui():
	get_node("gui/sizeLabel/value").set_text(str(map.sizes[activeCountry]))
	

func _ready():
	set_process(true)
	map = get_node("map")

func _process(delta):
	var mousePos = map.get_local_mouse_pos()+Vector2(map.width/2,map.height/2)
	print(mousePos)
	if (Input.is_mouse_button_pressed(1)):
		leftMousePressed = true
	else:
		if (leftMousePressed):
			#OnClick
			if (mousePos.x>=0 && mousePos.x<width && mousePos.y>=0 && mousePos.y<height):
				var cursorCountry = map.map[mousePos.x][mousePos.y]
				print(cursorCountry)
				if (map.neighbours[activeCountry][cursorCountry]>0):
					for i in range(150):
						map.expanseTerritory(activeCountry,cursorCountry)
					map.updateMap()
					updateGui()
#					calcNeighbours()
		leftMousePressed = false
	if (Input.is_mouse_button_pressed(2)):
		rightMousePressed = true
	else:
		if (rightMousePressed):
			#OnRightClick
			activeCountry =  map.map[mousePos.x][mousePos.y]
			updateGui()
		rightMousePressed = false