function love.load()
	DEBUG = true

	love.graphics.setDefaultFilter("nearest", "nearest")

	-- background repeated scrolling stuff
	Background = love.graphics.newImage("pBG/4.png")
	BGScrollProgress = 0

	-- all of these shit here is for the animation of the player to work
	Animation = {
		images = {
			love.graphics.newImage("superhero1.png"),
			love.graphics.newImage("superhero2.png"),
		},
		current = 1,
		timer = 0,
		delay = 0.1,
	}

	WindowDims = { x = 600, y = 400 }
	Herosize = 50
	love.window.setMode(WindowDims.x, WindowDims.y)
	HeroProps =
		{ x = Herosize, y = (WindowDims.y / 2) - (Herosize / 2), rotation = 0, w = Herosize, h = Herosize, speed = 250 }
	Bullets = {}
	Bills = {}
	Coins = {}
	Score = 0
	GameSpeed = 300

	Hero = love.graphics.newImage("superhero1.png")
end

BACKSCROLLSPEEDFACTOR = 100

function love.update(dt)
	BGScrollProgress = BGScrollProgress + BACKSCROLLSPEEDFACTOR * dt
	local bgWidth = Background:getWidth() * 1.25
	if BGScrollProgress >= bgWidth then
		BGScrollProgress = BGScrollProgress - bgWidth
	end

	Animation.timer = Animation.timer + dt
	if Animation.timer >= Animation.delay then
		Animation.timer = Animation.timer - Animation.delay
		Animation.current = Animation.current % #Animation.images + 1
	end

	local isChanging = false
	local moveDir = 0

	if math.random() < 0.02 then
		table.insert(Bills, { x = WindowDims.x + 20, y = math.random(20, WindowDims.y - 20), w = 40, h = 40 })
	end
	if math.random() < 0.01 then
		table.insert(Coins, { x = WindowDims.x + 10, y = math.random(10, WindowDims.y - 10), w = 20, h = 20 })
	end

	for _, bill in ipairs(Bills) do
		bill.x = bill.x - GameSpeed * dt
	end
	for _, c in ipairs(Coins) do
		c.x = c.x - GameSpeed * dt
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

	local a_left = a.x - a.w / 2
	local a_right = a.x + a.w / 2
	local a_top = a.y - a.h / 2
	local a_bottom = a.y + a.h / 2

	local b_left = b.x - b.w / 2
	local b_right = b.x + b.w / 2
	local b_top = b.y - b.h / 2
	local b_bottom = b.y + b.h / 2

	return a_right > b_left and a_left < b_right and a_bottom > b_top and a_top < b_bottom
end

-- DRAW FN IS HERE VVV
function love.draw()
	local bgWidth = Background:getWidth()
	love.graphics.draw(Background, -BGScrollProgress, 0, 0, 1.25, 1.25)
	love.graphics.draw(Background, -BGScrollProgress + (bgWidth * 1.25), 0, 0, 1.25, 1.25)

	local img = Animation.images[Animation.current]
	local scaleX = HeroProps.w / Hero:getWidth()
	local scaleY = HeroProps.h / Hero:getHeight()
	love.graphics.draw(
		img,
		HeroProps.x,
		HeroProps.y,
		HeroProps.rotation,
		scaleX,
		scaleY,
		Hero:getWidth() / 2,
		Hero:getHeight() / 2
	)

	for _, r in ipairs(Bills) do
		love.graphics.rectangle("line", r.x - r.w / 2, r.y - r.h / 2, r.w, r.h)
	end
	for _, c in ipairs(Coins) do
		love.graphics.circle("fill", c.x, c.y, c.w / 2)
	end
	for _, b in ipairs(Bullets) do
		love.graphics.circle("fill", b.x, b.y, b.w / 2)
	end
	love.graphics.print("Score: " .. Score, 10, 10)

	--
	--
	--
	--
	--
	--
	--
	--
	--
	-- everything for debug things
	if DEBUG then
		love.graphics.setColor(1, 0, 0, 0.5)
		love.graphics.rectangle(
			"line",
			HeroProps.x - HeroProps.w / 2,
			HeroProps.y - HeroProps.h / 2,
			HeroProps.w,
			HeroProps.h
		)
		for _, r in ipairs(Bills) do
			love.graphics.rectangle("line", r.x - r.w / 2, r.y - r.h / 2, r.w, r.h)
		end
		for _, b in ipairs(Bullets) do
			love.graphics.rectangle("line", b.x - b.w / 2, b.y - b.h / 2, b.w, b.h)
		end
		for _, c in ipairs(Coins) do
			love.graphics.circle("line", c.x, c.y, c.w / 2)
		end
		love.graphics.setColor(1, 1, 1, 1)
	end
	--
	--
	--
	--
	--
	--
end

function love.keypressed(key)
	if key == "space" then
		table.insert(Bullets, { x = HeroProps.x + HeroProps.w / 2, y = HeroProps.y, w = 10, h = 5 })
		Score = Score - 1
	end
end
