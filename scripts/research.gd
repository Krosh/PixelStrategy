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

func saveInFile(file):
	var tempDict = inst2dict(self)
	file.store_line("research")
	file.store_line("name:"+name)
	for item in tempDict:
		if (typeof(tempDict[item]) == TYPE_INT):
			file.store_line(item+":"+str(tempDict[item]))

func readFromFile(file):
	var curString = file.get_line()
	var mas
	while (curString != "research" && curString != "end"):
		mas = curString.split(":")
		self[mas[0]] = mas[1]
		curString = file.get_line()
		