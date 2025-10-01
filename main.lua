function love.load()
	WindowDims = { x = 600, y = 400 }
	Shipsize = 40
	love.window.setMode(WindowDims.x, WindowDims.y)
	HeroProps =
		{ x = Shipsize, y = (WindowDims.y / 2) - (Shipsize / 2), rotation = 0, w = Shipsize, h = Shipsize, speed = 200 }
	Bullets = {}
	Bills = {}
	Coins = {}
	Score = 0

	Hero = love.graphics.newImage("superhero1.png")
end

function love.update(dt)
	local isChanging = false
	local moveDir = 0

	if math.random() < 0.02 then
		table.insert(Bills, { x = WindowDims.x, y = math.random(0, WindowDims.y - 40), w = 40, h = 40 })
	end
	if math.random() < 0.01 then
		table.insert(Coins, { x = WindowDims.x, y = math.random(0, WindowDims.y - 20), w = 20, h = 20 })
	end

	for _, r in ipairs(Bills) do
		r.x = r.x - 200 * dt
	end
	for _, c in ipairs(Coins) do
		c.x = c.x - 200 * dt
	end

	for _, b in ipairs(Bullets) do
		b.x = b.x + 400 * dt
	end

	for i, c in ipairs(Coins) do
		if CheckCollision(HeroProps, c) then
			Score = Score + 1
			table.remove(Coins, i)
		end
	end

	for i = #Bills, 1, -1 do
		local r = Bills[i]
		if CheckCollision(HeroProps, Bills[i]) then
			love.event.quit("restart")
		end
		for j = #Bullets, 1, -1 do
			local b = Bullets[j]
			if CheckCollision(r, b) then
				table.remove(Bills, i)
				table.remove(Bullets, j)
				break
			end
		end
	end

	for i = #Bullets, 1, -1 do
		if Bullets[i].x > WindowDims.x then
			table.remove(Bullets, i)
		end
	end

	if love.keyboard.isDown("up") then
		HeroProps.y = HeroProps.y - HeroProps.speed * dt
		isChanging = true
		moveDir = -1
	end

	if love.keyboard.isDown("down") then
		HeroProps.y = HeroProps.y + HeroProps.speed * dt
		isChanging = true
		moveDir = 1
	end

	if isChanging then
		HeroProps.rotation = (math.pi / 4) * moveDir
	else
		HeroProps.rotation = 0
	end
end

-- checking colisions
function CheckCollision(a, b)
	if not (a and b and a.x and a.y and a.w and a.h and b.x and b.y and b.w and b.h) then
		return false
	end
	return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

-- DRAW FN IS HERE VVV
function love.draw()
	local scaleX = HeroProps.w / Hero:getWidth()
	local scaleY = HeroProps.h / Hero:getHeight()
	love.graphics.draw(
		Hero,
		HeroProps.x,
		HeroProps.y,
		HeroProps.rotation,
		scaleX,
		scaleY,
		Hero:getWidth() / 2,
		Hero:getHeight() / 2
	)

	for _, r in ipairs(Bills) do
		love.graphics.rectangle("line", r.x, r.y, r.w, r.h)
	end
	for _, c in ipairs(Coins) do
		love.graphics.circle("fill", c.x, c.y, c.w / 2)
	end
	for _, b in ipairs(Bullets) do
		love.graphics.circle("fill", b.x, b.y, b.w / 2)
	end
	love.graphics.print("Score: " .. Score, 10, 10)
end

function love.keypressed(key)
	if key == "space" then
		table.insert(Bullets, { x = HeroProps.x + HeroProps.w, y = HeroProps.y + HeroProps.h / 2, w = 10, h = 5 })
		Score = Score - 1
	end
end
