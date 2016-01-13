extends Node2D


var map
var width = 400
var height = 400
var activeCountry

var rightMousePressed = false
var leftMousePressed = false

var gui

var thread
var threadWorked = false

func updateGui():
	gui.get_node("sizeLabel/value").set_text(str(map.countries[activeCountry].size))
	gui.get_node("growLabel/value").set_text(str(map.countries[activeCountry].grow))
	gui.get_node("foodLabel/value").set_text(str(map.countries[activeCountry].food))
	gui.get_node("moneyLabel/value").set_text(str(map.countries[activeCountry].money))
	gui.get_node("peonsLabel/value").set_text(str(map.countries[activeCountry].peons))
	gui.get_node("foodLabel/sellSlider").set_max(map.countries[activeCountry].food)
	gui.get_node("foodLabel/buySlider").set_max(map.countries[activeCountry].getMaxFoodBuyCount())
	gui.get_node("scientistsLabel/value").set_text(str(map.countries[activeCountry].scientists))
	gui.get_node("scientistsLabel/sellSlider").set_max(map.countries[activeCountry].scientists)
	gui.get_node("scientistsLabel/buySlider").set_max(map.countries[activeCountry].getMaxScientistBuyCount())
	gui.get_node("growLabel/slider").set_max(map.countries[activeCountry].getMaxGrow())
	_on_slider_value_changed(0)

func _ready():
	thread = Thread.new()
	gui = get_node("gui")
	


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
	map.countries[activeCountry].sellFood(gui.get_node("foodLabel/sellSlider").get_value())
	updateGui()

func buyFood():
	map.countries[activeCountry].buyFood(gui.get_node("foodLabel/buySlider").get_value())
	updateGui()

func growFood():
	map.countries[activeCountry].growFood(gui.get_node("growLabel/slider").get_value())
	updateGui()

func sellScientists():
	map.countries[activeCountry].sellScientists(gui.get_node("scientistsLabel/sellSlider").get_value())
	updateGui()

func buyScientists():
	map.countries[activeCountry].buyScientists(gui.get_node("scientistsLabel/buySlider").get_value())
	updateGui()


func _on_slider_value_changed( value ):
	
	gui.get_node("growLabel/slider/value").set_text(str(gui.get_node("growLabel/slider").get_value()))
	#### FOOD SLIDER
	var sellFoodVal = gui.get_node("foodLabel/sellSlider").get_value()
	var sellFoodCost = floor(sellFoodVal*map.countries[activeCountry].getSellFoodCost())
	var buyFoodVal = gui.get_node("foodLabel/buySlider").get_value()
	var buyFoodCost = floor(buyFoodVal*map.countries[activeCountry].getBuyFoodCost())
	gui.get_node("foodLabel/sellSlider/value").set_text(str(sellFoodVal)+" ("+str(sellFoodCost)+"$)")
	gui.get_node("foodLabel/buySlider/value").set_text(str(buyFoodVal)+" ("+str(buyFoodCost)+"$)")
	#### WARRIOR SLIDER
	var sellScientistVal = gui.get_node("scientistsLabel/sellSlider").get_value()
	var sellScientistCost = floor(sellScientistVal*map.countries[activeCountry].getSellScientistCost())
	var buyScientistVal = gui.get_node("scientistsLabel/buySlider").get_value()
	var buyScientistCost = floor(buyScientistVal*map.countries[activeCountry].getBuyScientistCost())
	gui.get_node("scientistsLabel/sellSlider/value").set_text(str(sellScientistVal)+" ("+str(sellScientistCost)+"$)")
	gui.get_node("scientistsLabel/buySlider/value").set_text(str(buyScientistVal)+" ("+str(buyScientistCost)+"$)")



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

func showDialog():
	get_node("Popup").show_modal(true)
