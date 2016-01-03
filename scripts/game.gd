extends Node2D


var map
var width = 400
var height = 400
var activeCountry

var rightMousePressed = false
var leftMousePressed = false

var thread
var threadWorked = false

func updateGui():
	get_node("gui/sizeLabel/value").set_text(str(map.countries[activeCountry].size))
	get_node("gui/growLabel/value").set_text(str(map.countries[activeCountry].grow))
	get_node("gui/foodLabel/value").set_text(str(map.countries[activeCountry].food))
	get_node("gui/moneyLabel/value").set_text(str(map.countries[activeCountry].money))
	get_node("gui/peonsLabel/value").set_text(str(map.countries[activeCountry].peons))
	get_node("gui/foodLabel/sellSlider").set_max(map.countries[activeCountry].food)
	get_node("gui/foodLabel/buySlider").set_max(map.countries[activeCountry].getMaxFoodBuyCount())
	get_node("gui/growLabel/slider").set_max(map.countries[activeCountry].getMaxGrow())
	_on_slider_value_changed(0)

func _ready():
	thread = Thread.new()
	


func selectCountry(idCountry):
	activeCountry = idCountry
	map.get_material().set_shader_param("myColor",map.colors[idCountry])
	updateGui()


func _process(delta):
	var mousePos = map.get_local_mouse_pos()
	if (Input.is_mouse_button_pressed(1)):
		leftMousePressed = true
	else:
		if (leftMousePressed):
			#OnClick
			if (mousePos.x>=0 && mousePos.x<width && mousePos.y>=0 && mousePos.y<height):
				var cursorCountry = map.map[mousePos.x][mousePos.y]
				print(cursorCountry)
				if (map.neighbours[activeCountry][cursorCountry]>0):
					if (thread.is_active()):
						return
					thread.start(self,"attackInThread",cursorCountry)
#					calcNeighbours()
		leftMousePressed = false
	if (Input.is_mouse_button_pressed(2)):
		rightMousePressed = true
	else:
		if (rightMousePressed):
			#OnRightClick
			selectCountry(map.map[mousePos.x][mousePos.y])
		rightMousePressed = false

func nextTurn():
	map.countries[activeCountry].nextTurn()
	updateGui()


func sellFood():
	map.countries[activeCountry].sellFood(get_node("gui/foodLabel/sellSlider").get_value())
	updateGui()


func growFood():
	map.countries[activeCountry].growFood(get_node("gui/growLabel/slider").get_value())
	updateGui()



func _on_slider_value_changed( value ):
	var sellFoodVal = get_node("gui/foodLabel/sellSlider").get_value()
	var sellFoodCost = floor(sellFoodVal*map.countries[activeCountry].getFoodCost())
	var buyFoodVal = get_node("gui/foodLabel/buySlider").get_value()
	var buyFoodCost = floor(buyFoodVal*map.countries[activeCountry].getBuyFoodCost())
	get_node("gui/foodLabel/sellSlider/value").set_text(str(sellFoodVal)+" ("+str(sellFoodCost)+"$)")
	get_node("gui/foodLabel/buySlider/value").set_text(str(buyFoodVal)+" ("+str(buyFoodCost)+"$)")
	get_node("gui/growLabel/slider/value").set_text(str(get_node("gui/growLabel/slider").get_value()))


func buyFood():
	map.countries[activeCountry].buyFood(get_node("gui/foodLabel/buySlider").get_value())
	updateGui()

func attackInThread(obj):
	for i in range(150):
		map.expanseTerritory(activeCountry,obj)
	map.updateMap()
	map.countries[activeCountry].updateLabel()
	map.countries[obj].updateLabel()
	call_deferred("successThread")
	return true

func generateInThread(obj):
	map = get_node("map")
	map.start()
	for item in map.countries:
		item.startGame()
	activeCountry = 0
	call_deferred("successThread")
	return true

func successThread():
	var flag = thread.wait_to_finish()
	updateGui()
	set_process(true)
	

func generate():
	if (thread.is_active()):
		return
	thread.start(self,"generateInThread")