# PEOPLES
var peons = 0
var warriors = 0
var scientist = 0
# RESOURCES
var money = 0
var food = 0
var grow = 0
var size = 0

func getAgroCoef():
	return 2.0

func getFoodCost():
	return 3.0

func getMaxGrow():
	return ceil(min(food,size/10))

func sellFood(value):
	var v = min(value,food)
	food -= v
	money += v * getFoodCost()

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