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
var name = "COUNTRY"
var label = null

func getAgroCoef():
	return 2.0

func getFoodCost():
	return 3.0

func getBuyFoodCost():
	return getFoodCost() * 2

func getMaxGrow():
	return min(food,ceil(size/10)-grow)

func getMaxFoodBuyCount():
	return floor(money/getBuyFoodCost())


func sellFood(value):
	var v = min(value,food)
	food -= v
	money += floor(v * getFoodCost())


func buyFood(value):
	var v = min(value,getMaxFoodBuyCount())
	food += v
	print(v)
	money -= floor(v*getBuyFoodCost())

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
