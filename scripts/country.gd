extends Node

# PEOPLES
var peons = 0
var scientists = 0
# WAR UNITS
var infantry = 0
var cavalry = 0
var artillery = 0
# RESOURCES
var money = 0
var food = 0
var grow = 0
var size = 0
# DRAW VARS
var center = Vector2(0,0)
var name = "Country"
var label = null
# RESEARCH
var researchs = []

func getAgroCoef():
	return 2.0

func getSellFoodCost():
	return 3.0

func getBuyFoodCost():
	return getSellFoodCost() * 2

func getMaxGrow():
	return min(food,ceil(size/10)-grow)

func getMaxFoodBuyCount():
	return floor(money/getBuyFoodCost())

func getBuyScientistCost():
	return 100

func getSellScientistCost():
	return getBuyScientistCost()/2

func getMaxScientistBuyCount():
	return min(floor(money/getBuyScientistCost()),peons)

func getFreeScientists():
	var total = scientists
	for item in researchs:
		total -= item.scientistsCount
	return total

func getScientistFeedValue():
	return 1.0

func sellFood(value):
	var v = min(value,food)
	food -= v
	money += floor(v * getSellFoodCost())

func buyFood(value):
	var v = min(value,getMaxFoodBuyCount())
	food += v
	money -= floor(v*getBuyFoodCost())

func syncronizeScientistsOnResearch():
	# THIS METHOD REMOVE EXCESS SCIENTISTS FROM RESEARCH
	var i = scientists
	for item in researchs:
		item.scientistsCount = min(i,item.scientistsCount)
		i -= item.scientistsCount

func sellScientists(value):
	var v = min(value,scientists)
	scientists -= v
	syncronizeScientistsOnResearch()
	peons += v
	money += floor(v * getSellScientistCost())

func buyScientists(value):
	var v = min(value,getMaxScientistBuyCount())
	scientists += v
	peons -= v
	money -= floor(v*getBuyScientistCost())

func feedScientists():
	var val = min(scientists,floor(food/getScientistFeedValue()))
	if (val < scientists):
		# NO MORE FOOD
		pass
	scientists = val
	syncronizeScientistsOnResearch()
	food -= floor(getScientistFeedValue()*val)

func growFood(value):
	var v = min(value,food)
	food -= v
	grow += v


func startResearchs():
	var researchClass = preload("res://scripts/research.gd")
	var researchCount = 4
	researchs = []
	for i in range(researchCount):
		researchs.append(researchClass.new())
		researchs[i].parentCountry = self

func startGame():
	food = 200
	peons = 150
	scientists = 100
	money = 100
	startResearchs()

func nextTurn():
	food += ceil(grow * getAgroCoef())
	grow = 0
	feedScientists()
	for item in researchs:
		item.nextTurn()

func updateLabel():
	if (label != null):
		if (size == 0):
			label.hide()
		label.set_pos(center-Vector2(150,0))

func saveInFile(file):
	var tempDict = inst2dict(self)
	file.store_line("name:"+name)
	for item in tempDict:
		if (typeof(tempDict[item]) == TYPE_INT):
			file.store_line(item+":"+str(tempDict[item]))
	for item in researchs:
		item.saveInFile(file)
	file.store_line("end")

func readFromFile(file):
	var curString = file.get_line()
	var mas
	while (curString != "research" && curString != "end"):
		mas = curString.split(":")
		self[mas[0]] = mas[1]
		curString = file.get_line()
