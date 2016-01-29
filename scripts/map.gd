extends Sprite

var colors = [Color(1,0,0),Color(0,1,0),Color(0,0,1),Color(0,1,1),Color(1,0,1),Color(1,1,0)]
var points = []
var map = []
var neighbours = null
var borders = []
var countries = []
var width = 400
var height = 400

var BorderColor = Color(0,0,0)

var CountryClass = preload("res://scripts/country.gd")

var numStartSwap = 10

var imageTexture
var image

var colorCount = 20

func expanseTerritory(attacker,enemy):
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
	while (target == null):
#		i += 1
#		if (i > 1000):
#			return
		var n = randi() % borders[attacker].size()
		pos = borders[attacker][n]
	#	print(pos)
		if (pos.x > 0 && map[pos.x-1][pos.y] == enemy):
			target = Vector2(pos.x-1,pos.y)
		if (pos.x < width-1 && map[pos.x+1][pos.y] == enemy):
			target = Vector2(pos.x+1,pos.y)
		if (pos.y > 0 && map[pos.x][pos.y-1] == enemy):
			target = Vector2(pos.x,pos.y-1)
		if (pos.y < height-1 && map[pos.x][pos.y+1] == enemy):
			target = Vector2(pos.x,pos.y+1)
	#print(target)
	#   RECALC NEIGHBOUR COUNT

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
				else:
					borders[baseCountry].append(Vector2(x,y))
					image.put_pixel(x,y,BorderColor)

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
	countries[attacker].size += 1
	while (borders[enemy].find(target)>=0):
		borders[enemy].erase(target)
	countries[enemy].size -= 1
#	image.put_pixel(target.x,target.y,colors[attacker])
	#for i in range(width):
	#	for j in range(height):
	#		image.put_pixel(i,j,colors[map[i][j]])
	#for item in borders[attacker]:
	#	image.put_pixel(item.x,item.y,Color(1,0,0))
		

func updateMap():
	imageTexture.set_data(image)
	self.set_texture(imageTexture)

func calcNeighbours():
	neighbours = []
	for i in range(colorCount):
		neighbours.append([])
		for j in range(colorCount):
			neighbours[i].append(0)
	for i in range(1,width-1):
		if (i % 50 == 0):
			print(i)
		for j in range(1,height-1):
			#TODO ::: TEST ON BORDERS
			if (map[i-1][j] != map[i][j]):
				var v1 = map[i-1][j]
				var v2 = map[i][j]
				neighbours[v1][v2] += 1
				neighbours[v2][v1] += 1
				borders[v1].append(Vector2(i-1,j))
				borders[v2].append(Vector2(i,j))
				image.put_pixel(i,j,BorderColor)
				image.put_pixel(i-1,j,BorderColor)
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
				image.put_pixel(i,j,BorderColor)
				image.put_pixel(i,j-1,BorderColor)
	#		if (map[i][j+1] != map[i][j]):
	#			var v1 = map[i][j+1]
	#			var v2 = map[i][j]
	#			neighbours[v1][v2] = true
	#			neighbours[v2][v1] = true
	

func start():
	randomize()
	colors = []
	borders = []
	countries = []
	map = []
	for i in range(colorCount):
		colors.append(Color(1,1,1))
		borders.append([])
		countries.append(CountryClass.new())
	self.get_material().set_shader_param("myColor",colors[0])
	var maxLength = (width*height)*(width*height)
	imageTexture = ImageTexture.new()
#	imageTexture.set_flags(0)
#	imageTexture.create(256,256,0)
#	imageTexture.set_size_override(Vector2(256,256))
	imageTexture.load("res://map.png")
	#imageTexture = get_texture()
	image = imageTexture.get_data()
	print(image.get_width())
	for i in range(colors.size()):
		var x = randi() % width
		var y = randi() % height
		points.append(Vector2(x,y))
	
	for i in range(width):
		if (i % 50 == 0):
			print(i)
		map.append([])
		for j in range(height):
			var curPos = Vector2(i,j)
			var curLength = 0
			var bestLength = maxLength
			var bestColor = -1
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
#	startSwapTerritory()a
	updateMap()



