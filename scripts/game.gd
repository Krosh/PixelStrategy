extends Node2D


var map
var width = 400
var height = 400
var activeCountry

var rightMousePressed = false
var leftMousePressed = false

var economicGui
var scienceGui

var thread
var threadWorked = false

func updateEconomicsGui():
	economicGui.get_node("sizeLabel/value").set_text(str(map.countries[activeCountry].size))
	economicGui.get_node("growLabel/value").set_text(str(map.countries[activeCountry].grow))
	economicGui.get_node("foodLabel/value").set_text(str(map.countries[activeCountry].food))
	economicGui.get_node("moneyLabel/value").set_text(str(map.countries[activeCountry].money))
	economicGui.get_node("peonsLabel/value").set_text(str(map.countries[activeCountry].peons))
	economicGui.get_node("foodLabel/sellSlider").set_max(map.countries[activeCountry].food)
	economicGui.get_node("foodLabel/buySlider").set_max(map.countries[activeCountry].getMaxFoodBuyCount())
	economicGui.get_node("scientistsLabel/value").set_text(str(map.countries[activeCountry].scientists))
	economicGui.get_node("scientistsLabel/sellSlider").set_max(map.countries[activeCountry].scientists)
	economicGui.get_node("scientistsLabel/buySlider").set_max(map.countries[activeCountry].getMaxScientistBuyCount())
	economicGui.get_node("growLabel/slider").set_max(map.countries[activeCountry].getMaxGrow())
	_on_slider_value_changed(0)

func updateScientistsGui():
	for i in range(map.countries[activeCountry].researchs.size()):
		var research = map.countries[activeCountry].researchs[i]
		var researchNode = scienceGui.get_node("research"+str(i+1))
		researchNode.get_node("progress").set_max(research.endValue)
		researchNode.get_node("progress").set_value(research.curValue)
		researchNode.get_node("levelValue").set_text("Level "+str(research.level))
		researchNode.get_node("stateValue").set_text(str(research.curValue) + "/"+ str(research.endValue))
		if (research.scientistsCount > 0):
			researchNode.get_node("needTurnValue").show()
			researchNode.get_node("needTurnValue").set_text("Need "+str(research.getNeedTurn())+" turns")
		else:
			researchNode.get_node("needTurnValue").hide()
		researchNode.get_node("scientistsCount").set_value(research.scientistsCount)
	scienceGui.get_node("freeScientistsLabel/value").set_text(str(map.countries[activeCountry].getFreeScientists()))

func updateGui():
	updateEconomicsGui()
	updateScientistsGui()

func _ready():
	thread = Thread.new()
	economicGui = get_node("gui")
	scienceGui = get_node("science")
	


func selectCountry(idCountry):
	activeCountry = idCountry
	map.get_material().set_shader_param("myColor",map.colors[idCountry])
	#   RECALC VISION
	map.updateMap()
	map.updateVision(idCountry)
	get_node("Sprite").set_texture(map.visionTexture)
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
	map.countries[activeCountry].sellFood(economicGui.get_node("foodLabel/sellSlider").get_value())
	updateGui()

func buyFood():
	map.countries[activeCountry].buyFood(economicGui.get_node("foodLabel/buySlider").get_value())
	updateGui()

func growFood():
	map.countries[activeCountry].growFood(economicGui.get_node("growLabel/slider").get_value())
	updateGui()

func sellScientists():
	map.countries[activeCountry].sellScientists(economicGui.get_node("scientistsLabel/sellSlider").get_value())
	updateGui()

func buyScientists():
	map.countries[activeCountry].buyScientists(economicGui.get_node("scientistsLabel/buySlider").get_value())
	updateGui()


func _on_slider_value_changed( value ):
	
	economicGui.get_node("growLabel/slider/value").set_text(str(economicGui.get_node("growLabel/slider").get_value()))
	#### FOOD SLIDER
	var sellFoodVal = economicGui.get_node("foodLabel/sellSlider").get_value()
	var sellFoodCost = floor(sellFoodVal*map.countries[activeCountry].getSellFoodCost())
	var buyFoodVal = economicGui.get_node("foodLabel/buySlider").get_value()
	var buyFoodCost = floor(buyFoodVal*map.countries[activeCountry].getBuyFoodCost())
	economicGui.get_node("foodLabel/sellSlider/value").set_text(str(sellFoodVal)+" ("+str(sellFoodCost)+"$)")
	economicGui.get_node("foodLabel/buySlider/value").set_text(str(buyFoodVal)+" ("+str(buyFoodCost)+"$)")
	#### WARRIOR SLIDER
	var sellScientistVal = economicGui.get_node("scientistsLabel/sellSlider").get_value()
	var sellScientistCost = floor(sellScientistVal*map.countries[activeCountry].getSellScientistCost())
	var buyScientistVal = economicGui.get_node("scientistsLabel/buySlider").get_value()
	var buyScientistCost = floor(buyScientistVal*map.countries[activeCountry].getBuyScientistCost())
	economicGui.get_node("scientistsLabel/sellSlider/value").set_text(str(sellScientistVal)+" ("+str(sellScientistCost)+"$)")
	economicGui.get_node("scientistsLabel/buySlider/value").set_text(str(buyScientistVal)+" ("+str(buyScientistCost)+"$)")



func attackInThread(obj):
	var flag = false
	for i in range(150):
		flag = flag || map.expanseTerritory(activeCountry,obj)
	if (flag):
		map.updateVision(activeCountry)
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
	get_node("PopupPanel").popup_centered()


func changeActiveMenu( button ):
	get_node("gui").hide()
	get_node("science").hide()
	if (button == 0):
		get_node("gui").show()
	elif (button == 1):
		get_node("science").show()


func _on_minButton_pressed(arg):
	var scientistsCount = scienceGui.get_node("research"+str(arg)+"/scientistsCount")
	scientistsCount.set_value(0)


func _on_maxButton_pressed(arg):
	var scientistsCount = scienceGui.get_node("research"+str(arg)+"/scientistsCount")
	scientistsCount.set_value(map.countries[activeCountry].researchs[arg-1].getMaxValue())


func _on_yearButton_pressed(arg):
	var scientistsCount = scienceGui.get_node("research"+str(arg)+"/scientistsCount")
	scientistsCount.set_value(map.countries[activeCountry].researchs[arg-1].getOneYearValue())


func _on_scientistsCount_value_changed( value, arg ):
	if (map.countries[activeCountry].researchs[arg-1].scientistsCount == value):
		return
	map.countries[activeCountry].researchs[arg-1].scientistsCount = value
	updateScientistsGui()


func _on_saveButton_pressed():
	map.saveGame("save")


func _on_loadButton_pressed():
	map = get_node("map")
	map.loadGame("save")
	activeCountry = 0
	updateGui()
	set_process(true)
