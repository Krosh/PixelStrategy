extends Node2D


var map
var width = 400
var height = 400
var activeCountry

var rightMousePressed = false
var leftMousePressed = false

func updateGui():
	get_node("gui/sizeLabel/value").set_text(str(map.countries[activeCountry].size))
	get_node("gui/growLabel/value").set_text(str(map.countries[activeCountry].grow))
	get_node("gui/foodLabel/value").set_text(str(map.countries[activeCountry].food))
	get_node("gui/moneyLabel/value").set_text(str(map.countries[activeCountry].money))
	get_node("gui/foodLabel/slider").set_max(map.countries[activeCountry].food)
	get_node("gui/growLabel/slider").set_max(map.countries[activeCountry].getMaxGrow())
	_on_slider_value_changed(0)

func _ready():
	set_process(true)
	map = get_node("map")
	map.start()
	for item in map.countries:
		item.startGame()
	activeCountry = 0
	updateGui()

func _process(delta):
	var mousePos = map.get_local_mouse_pos()+Vector2(map.width/2,map.height/2)
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

func nextTurn():
	map.countries[activeCountry].nextTurn()
	updateGui()


func sellFood():
	map.countries[activeCountry].sellFood(get_node("gui/foodLabel/slider").get_value())
	updateGui()


func growFood():
	map.countries[activeCountry].growFood(get_node("gui/growLabel/slider").get_value())
	updateGui()



func _on_slider_value_changed( value ):
	var sellFoodVal = get_node("gui/foodLabel/slider").get_value()
	var sellFoodCost = floor(sellFoodVal*map.countries[activeCountry].getFoodCost())
	get_node("gui/foodLabel/slider/value").set_text(str(sellFoodVal)+" ("+str(sellFoodCost)+"$)")
	get_node("gui/growLabel/slider/value").set_text(str(get_node("gui/growLabel/slider").get_value()))
