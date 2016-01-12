# PEOPLES
var peons = 0
var warriors = 0
var scientist = 0
# RESOURCES
var money = 0
var food = 0
var grow = 0
var size = 0
# DRAW VARS
var center = Vector2(0,0)
var name = "Country"
var label = null

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

func getBuyWarriorCost():
	return 100

func getSellWarriorCost():
	return getBuyWarriorCost()/2

func getMaxWarriorBuyCount():
	return floor(money/getBuyWarriorCost())

func sellFood(value):
	var v = min(value,food)
	food -= v
	money += floor(v * getSellFoodCost())

func buyFood(value):
	var v = min(value,getMaxFoodBuyCount())
	food += v
	money -= floor(v*getBuyFoodCost())

func sellWarriors(value):
	var v = min(value,warriors)
	warriors -= v
	money += floor(v * getSellWarriorCost())

func buyWarriors(value):
	var v = min(value,getMaxWarriorBuyCount())
	warriors += v
	money -= floor(v*getBuyWarriorCost())

func growFood(value):
	var v = min(value,food)
	food -= v
	grow += v

func startGame():
	food = 200
	peons = 150
	money = 100

func nextTurn():
	food += ceil(grow * getAgroCoef())
	grow = 0

func updateLabel():
	if (label != null):
		if (size == 0):
			label.hide()
		label.set_pos(center-Vector2(150,0))
