var parentCountry
var name = "Research"
var level = 1
var scientistsCount = 10
var curValue = 60
var endValue = 100

func endResearch():
	print(name+" is researched")
	level += 1
	curValue -= endValue
	endValue = 100 * level

func nextTurn():
	curValue += scientistsCount
	if (curValue >= endValue):
		 endResearch()

func getMaxValue():
	return parentCountry.getFreeScientists() + scientistsCount

func getOneYearValue():
	return min(getMaxValue(), endValue-curValue)

func getNeedTurn():
	return ceil((endValue-curValue)/scientistsCount)