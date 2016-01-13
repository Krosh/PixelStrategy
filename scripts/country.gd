# PEOPLES
var peons = 0
var scientists = 0
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

func sellScientists(value):
	var v = min(value,scientists)
	scientists -= v
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
