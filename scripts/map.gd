extends Sprite

var borderPixels = [] #[WHO][WITH][X][Y]

var colors = [Color(1,0,0),Color(0,1,0),Color(0,0,1),Color(0,1,1),Color(1,0,1),Color(1,1,0)]
var points = []
var map = []
var neighbours = null
var countries = []
var sizes = []
var width = 200
var height = 200

var numStartSwap = 10

var imageTexture
var image

var colorCount = 10

var activeCountry

var rightMousePressed = false
var leftMousePressed = false

func startSwapTerritory():
	var pos
	for i in range(colorCount):
		for j in range(colorCount):
			if (neighbours[i][j]):
				var target = null
				var attacker = i
				var enemy = j
				for k in range(numStartSwap):
					var i = 0
					if (countries[j].size() < 5):
						return
					var delta = 10
					var q = delta*delta/2
					var n = 0
					var flag = false
					if (target != null):
				#		print(target)
						while n<q && !flag:
							n +=1
							pos = target + Vector2(randi() % (delta*2)-delta,randi() % (delta*2)-delta)
							if (pos.x < 0):
								pos.x = 0
							if (pos.y < 0):
								pos.y = 0
							if (pos.x>=width):
								pos.x = width-1
							if (pos.y>=height):
								pos.y = height-1
							if (map[pos.x][pos.y] != attacker):
								continue
							if (pos.x > 0 && map[pos.x-1][pos.y] == enemy):
								target = Vector2(pos.x-1,pos.y)
								flag = true
							if (pos.x < width-1 && map[pos.x+1][pos.y] == enemy):
								target = Vector2(pos.x+1,pos.y)
								flag = true
							if (pos.y > 0 && map[pos.x][pos.y-1] == enemy):
								target = Vector2(pos.x,pos.y-1)
								flag = true
							if (pos.y < height-1 && map[pos.x][pos.y+1] == enemy):
								target = Vector2(pos.x,pos.y+1)
								flag = true
						if (!flag):
							print("asdasd")
					while (target == null && !flag):
						var n = randi() % countries[attacker].size()
						pos = countries[attacker][n]
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
					map[target.x][target.y] = attacker
					countries[attacker].append(target)
					countries[enemy].erase(target)
					image.put_pixel(target.x,target.y,colors[attacker])


func expanseTerritory(attacker,enemy):
	if (sizes[enemy] == 0):
		print("captured")
		return
	if (neighbours[attacker][enemy] == 0):
		print("no more links")
		return
	var pos
	var target = null
	#print(str(attacker)+" -" +str(enemy))
#	for item in countries[attacker]:
#		print(item)
	#print(countries[attacker].size())
	var i = 0
	while (target == null):
#		i += 1
#		if (i > 1000):
#			return
		var n = randi() % countries[attacker].size()
		pos = countries[attacker][n]
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
					countries[baseCountry].append(Vector2(x,y))
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
			if (abs(i)+abs(j) != 1):
				continue
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
						while (countries[baseCountry].find(v)>=0):
							countries[baseCountry].erase(v)
	
	countries[attacker].append(target)
	sizes[attacker] += 1
	while (countries[enemy].find(target)>=0):
		countries[enemy].erase(target)
	sizes[enemy] -= 1
	image.put_pixel(target.x,target.y,colors[attacker])
	#for i in range(width):
	#	for j in range(height):
	#		image.put_pixel(i,j,colors[map[i][j]])
	#for item in countries[attacker]:
	#	image.put_pixel(item.x,item.y,Color(1,0,0))
		

func updateMap():
	imageTexture.set_data(image)
	self.set_texture(imageTexture)

func calcNeighbours():
	if (neighbours == null):
		neighbours = []
		for i in range(colorCount):
			neighbours.append([])
			for j in range(colorCount):
				neighbours[i].append(0)
	for i in range(1,width-1):
		for j in range(1,height-1):
			#TODO ::: TEST ON BORDERS
			if (map[i-1][j] != map[i][j]):
				var v1 = map[i-1][j]
				var v2 = map[i][j]
				neighbours[v1][v2] += 1
				neighbours[v2][v1] += 1
				countries[v1].append(Vector2(i-1,j))
				countries[v2].append(Vector2(i,j))
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
				countries[v2].append(Vector2(i,j))
				countries[v1].append(Vector2(i,j-1))
	#		if (map[i][j+1] != map[i][j]):
	#			var v1 = map[i][j+1]
	#			var v2 = map[i][j]
	#			neighbours[v1][v2] = true
	#			neighbours[v2][v1] = true
	

func _ready():
	randomize()
	colors = []
	countries = []
	sizes = []
	for i in range(colorCount):
		colors.append(Color(randf(),randf(),randf()))
		countries.append([])
		sizes.append(0)
	var maxLength = (width*height)*(width*height)
	imageTexture = ImageTexture.new()
	imageTexture.load("res://map.png")
	image = imageTexture.get_data()
	for i in range(colors.size()):
		var x = randi() % width
		var y = randi() % height
		points.append(Vector2(x,y))
	for i in range(width):
		map.append([])
		for j in range(height):
			var curPos = Vector2(i,j)
			var curLength = 0
			var bestLength = maxLength
			var bestColor = -1
			for n in range(colors.size()):
				curLength = curPos.distance_squared_to(points[n])
				if (curLength < bestLength):
					bestLength = curLength
					bestColor = n
			image.put_pixel(i,j,colors[bestColor])
			map[i].append(bestColor)
			sizes[bestColor] += 1
#	for n in range(colors.size()):
#		image.put_pixel(points[n].x,points[n].y,Color(0,0,0))
	calcNeighbours()
#	startSwapTerritory()
	updateMap()
	set_process(true)


func _process(delta):
	var mousePos = get_local_mouse_pos()+Vector2(width/2,height/2)
	if (Input.is_mouse_button_pressed(1)):
		leftMousePressed = true
	else:
		if (leftMousePressed):
			#OnClick
			if (mousePos.x>=0 && mousePos.x<width && mousePos.y>=0 && mousePos.y<height):
				var cursorCountry = map[mousePos.x][mousePos.y]
				print(cursorCountry)
				if (neighbours[activeCountry][cursorCountry]>0):
					for i in range(150):
						expanseTerritory(activeCountry,cursorCountry)
					updateMap()
#					calcNeighbours()
		leftMousePressed = false
	if (Input.is_mouse_button_pressed(2)):
		rightMousePressed = true
	else:
		if (rightMousePressed):
			#OnRightClick
			activeCountry = map[mousePos.x][mousePos.y]
		rightMousePressed = false
