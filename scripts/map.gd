extends Sprite

var colors = [Color(1,0,0),Color(0,1,0),Color(0,0,1),Color(0,1,1),Color(1,0,1),Color(1,1,0)]
var points = []
var map = []
var neighbours = null
var borders = []
var countries = []
var width = 200
var height = 200

var BorderColor = Color(0,1,0)

var CountryClass = preload("res://scripts/country.gd")


var imageTexture
var image

var colorCount = 20
var numStartSwap = 20

func initMap():
	randomize()
	colors = []
	borders = []
	countries = []
	map = []
	for i in range(colorCount):
		colors.append(Color(1,0.2+i*0.7/colorCount,0))
		borders.append([])
		countries.append(CountryClass.new())
	self.get_material().set_shader_param("myColor",colors[0])
	

func saveGame(saveName):
	image.save_png("res://saves/"+saveName+"_map.png")
	var file = File.new()
	file.open("res://saves/"+saveName+"_save.sv",file.WRITE)
	# header and main information
	file.store_8(colorCount)
	# every country
	for item in countries:
		item.saveInFile(file)
	file.close()

func loadGame(saveName):
	initMap()
	var maxLength = (width*height)*(width*height)
	imageTexture = ImageTexture.new()
#	imageTexture.set_flags(0)
#	imageTexture.create(256,256,0)
#	imageTexture.set_size_override(Vector2(256,256))
	imageTexture.set_flags(0)
	imageTexture.load("res://saves/"+saveName+"_map.png")
	imageTexture.set_flags(0)
	#imageTexture = get_texture()
	image = imageTexture.get_data()
	
	var file = File.new()
	file.open("res://saves/"+saveName+"_save.sv",file.READ)
	# header and main information
	file.get_8()
	# every country
	for item in countries:
		item.readFromFile(file)
	file.close()
	for item in countries:
		print(item)
	
	var curPos
	var curLength = 0
	var bestLength = maxLength
	var bestColor = -1
	for i in range(width):
		if (i % 50 == 0):
			print(i)
		map.append([])
		for j in range(height):
			bestColor = round((image.get_pixel(i,j).g-0.2)/0.7*colorCount)
			image.put_pixel(i,j,colors[bestColor])
			map[i].append(bestColor)
		#	countries[bestColor].size += 1
#			sizes[bestColor] += 1
#	for n in range(colors.size()):
#		image.put_pixel(points[n].x,points[n].y,Color(0,0,0))
	print("calc neighbours")
	calcNeighbours()
	startCountryNames()
	updateMap()


func startSwap():
	for i in range(colorCount):
		print(i)
		for j in range(i,colorCount):
			for n in range(numStartSwap):
				if (neighbours[i][j]>0):
					expanseTerritory(i,j)
					expanseTerritory(j,i)
				

func startCountryNames():
	var theme = preload("res://guiTheme.thm")
	var font = Font.new()
	font.create_from_fnt("res://font.fnt")
	theme.set_color("font_color","Label",Color(0.2773,0.2109,0.1719,1))
	for i in range(width):
		for j in range(height):
			countries[map[i][j]].center += Vector2(i,j)
	for i in range(colorCount):
		countries[i].center /= countries[i].size
		var label = Label.new()
		label.set_theme(theme)
		label.set_text(countries[i].name)
		label.set_align(HALIGN_CENTER)
		label.set_size(Vector2(300,100))
		get_node("countryNames").add_child(label)
		countries[i].label = label
		countries[i].updateLabel()
	get_node("countryNames").show()


func expanseTerritory(attacker,enemy):
	var needRecalcVisionFlag = false
	if (countries[enemy].size == 0):
		print("captured")
		return
	if (neighbours[attacker][enemy] == 0):
		print("no more links")
		return
	var pos
	var target = null
	#print(str(attacker)+" -" +str(enemy))
#	for item in borders[attacker]:
#		print(item)
	#print(borders[attacker].size())
	var i = 0
	#var a = Vector2Array()
	while target == null:
#	№for n in range(borders[attacker].size()):
		i += 1
		if (i > 1000):
			print("limit of tries")
			return
		var n = randi() % borders[attacker].size()
		pos = borders[attacker][n]
#		pos = borders[attacker][n]
	#	print(pos)
		if (pos.x > 0 && map[pos.x-1][pos.y] == enemy):
			target = Vector2(pos.x-1,pos.y)
#			a.push_back(Vector2(pos.x-1,pos.y))
		if (pos.x < width-1 && map[pos.x+1][pos.y] == enemy):
			target = Vector2(pos.x+1,pos.y)
#			a.push_back(Vector2(pos.x+1,pos.y))
		if (pos.y > 0 && map[pos.x][pos.y-1] == enemy):
			target = Vector2(pos.x,pos.y-1)
#			a.push_back(Vector2(pos.x,pos.y-1))
		if (pos.y < height-1 && map[pos.x][pos.y+1] == enemy):
			target = Vector2(pos.x,pos.y+1)
#			a.push_back(Vector2(pos.x,pos.y+1))
	#print(target)
	#   RECALC NEIGHBOUR COUNT
	
	#var target = a.get(randi() % a.size())
	var baseCountry = map[target.x][target.y]
	var anotherCountry
	
	for i in range(-1,2):
		for j in range(-1,2):
			if (abs(i)+abs(j) != 1):
				continue
			var x = target.x + i 
			var y = target.y + j
			if (x >= 0 && y >= 0 && x < width && y<height):
				anotherCountry = map[x][y]
				if (anotherCountry != baseCountry):
					neighbours[baseCountry][anotherCountry] -= 1
					neighbours[anotherCountry][baseCountry] -= 1
					if (neighbours[baseCountry][anotherCountry] == 0):
						needRecalcVisionFlag = true
				else:
					borders[baseCountry].append(Vector2(x,y))
					var color = colors[baseCountry]
					color.r = 0
					image.put_pixel(x,y,color)

#					for i2 in range(-1,2):
#						for j2 in range(-1,2):
#							if (abs(i2)+abs(j2) != 1):
#								continue
#							var x2 = x + i2 
#							var y2 = y + j2
#							if (x2 >= 0 && y2 >= 0 && x2 < width && y2<height):
#								if (map[x2][y2] != map[x][y]):
	

	map[target.x][target.y] = attacker
	
	baseCountry = map[target.x][target.y]
	for i in range(-1,2):
		for j in range(-1,2):
		#	if (abs(i)+abs(j) != 1):
		#		continue
			var x = target.x + i 
			var y = target.y + j
			if (x >= 0 && y >= 0 && x < width && y<height):
				anotherCountry = map[x][y]
				if (anotherCountry != baseCountry):
					if (neighbours[baseCountry][anotherCountry] == 0):
						# TODO:: NEED TO RECALC VISION | DONE
						needRecalcVisionFlag = true
					neighbours[baseCountry][anotherCountry] += 1
					neighbours[anotherCountry][baseCountry] += 1
				else:
					var flag = false
					for i2 in range(-1,2):
						if (flag):
							break
						for j2 in range(-1,2):
							if (abs(i2)+abs(j2) != 1):
								continue
							var x2 = x + i2 
							var y2 = y + j2
							if (x2 >= 0 && y2 >= 0 && x2 < width && y2<height):
								if (map[x2][y2] != map[x][y]):
									flag = true
									break
					if (!flag):
						var v = Vector2(x,y)
						while (borders[baseCountry].find(v)>=0):
							borders[baseCountry].erase(v)
						image.put_pixel(x,y,colors[baseCountry])
	
	borders[attacker].append(target)
	countries[attacker].center *= countries[attacker].size
	countries[attacker].center += target
	countries[attacker].size += 1
	countries[attacker].center /= countries[attacker].size
	while (borders[enemy].find(target)>=0):
		borders[enemy].erase(target)
	countries[enemy].center *= countries[enemy].size
	countries[enemy].center -= target
	countries[enemy].size -= 1
	if (countries[enemy].size > 0):
		countries[enemy].center /= countries[enemy].size
	return needRecalcVisionFlag

func updateMap():
	imageTexture.set_data(image)
	self.set_texture(imageTexture)

func fullUpdateVision(activeCountry):
	for i in range(0,width):
		for j in range(0,height):
			var color = image.get_pixel(i,j)
			if (neighbours[activeCountry][map[i][j]]>0 || map[i][j] == activeCountry):
				color.b = 0
			else:
				color.b = 1
			image.put_pixel(i,j,color)
	for i in range(colorCount):
		if (activeCountry == i || neighbours[i][activeCountry]>0):
			countries[i].label.show()
		else:
			countries[i].label.hide()

func calcNeighbours():
	neighbours = []
	for i in range(colorCount):
		neighbours.append([])
		for j in range(colorCount):
			neighbours[i].append(0)
	for i in range(1,width):
		if (i % 50 == 0):
			print(i)
		for j in range(1,height):
			#TODO ::: TEST ON BORDERS
			if (map[i-1][j] != map[i][j]):
				var v1 = map[i-1][j]
				var v2 = map[i][j]
				neighbours[v1][v2] += 1
				neighbours[v2][v1] += 1
				borders[v1].append(Vector2(i-1,j))
				borders[v2].append(Vector2(i,j))
				var color = colors[v2]
				color.r = 0
				image.put_pixel(i,j,color)
				var color = colors[v1]
				color.r = 0
				image.put_pixel(i-1,j,color)
			#		if (map[i+1][j] != map[i][j]):
	#			var v1 = map[i+1][j]
	#			var v2 = map[i][j]
	#			neighbours[v1][v2] = true
	#			neighbours[v2][v1] = true
			if (map[i][j-1] != map[i][j]):
				var v1 = map[i][j-1]
				var v2 = map[i][j]
				neighbours[v1][v2] += 1
				neighbours[v2][v1] += 1
				borders[v2].append(Vector2(i,j))
				borders[v1].append(Vector2(i,j-1))
				var color = colors[v2]
				color.r = 0
				image.put_pixel(i,j,color)
				var color = colors[v1]
				color.r = 0
				image.put_pixel(i,j-1,color)
	#		if (map[i][j+1] != map[i][j]):
	#			var v1 = map[i][j+1]
	#			var v2 = map[i][j]
	#			neighbours[v1][v2] = true
	#			neighbours[v2][v1] = true
	

func start():
	initMap()
	var maxLength = (width*height)*(width*height)
	imageTexture = ImageTexture.new()
#	imageTexture.set_flags(0)
#	imageTexture.create(256,256,0)
#	imageTexture.set_size_override(Vector2(256,256))
	#imageTexture.set_flags(0)
	imageTexture.load("res://map.png")
#	imageTexture.set_flags(0)
	#imageTexture = get_texture()
	image = imageTexture.get_data()

	for i in range(colors.size()):
		var x = randi() % width
		var y = randi() % height
		points.append(Vector2(x,y))
	
	var curPos
	var curLength = 0
	var bestLength = maxLength
	var bestColor = -1
	for i in range(width):
		if (i % 50 == 0):
			print(i)
		map.append([])
		for j in range(height):
			curPos = Vector2(i,j)
			curLength = 0
			bestLength = maxLength
			bestColor = -1
			for n in range(colors.size()):
				curLength = curPos.distance_squared_to(points[n])
				if (curLength < bestLength || bestColor == -1):
					bestLength = curLength
					bestColor = n
		#	print(bestColor)
			image.put_pixel(i,j,colors[bestColor])
			map[i].append(bestColor)
			countries[bestColor].size += 1
#			sizes[bestColor] += 1
#	for n in range(colors.size()):
#		image.put_pixel(points[n].x,points[n].y,Color(0,0,0))
	print("calc neighbours")
	calcNeighbours()
	print("start swap")
#	startSwap()
	startCountryNames()
	updateMap()



