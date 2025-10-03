-- Comments are added to differentiate different parts of my code
-- Love2D becomes crowdy when everything's working (i'm lazy for a more modular approach)
_G.love = require("love")
_G.anim8 = require("libraries.anim8")

GLOBALBGCONST = 1.23

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- COINS PART I'm doin
	--
	--
	--
	_G.coin = {}
	coin.spriteSheet = love.graphics.newImage("coin.png")
	coin.grid = anim8.newGrid(15, 15, coin.spriteSheet:getWidth(), coin.spriteSheet:getHeight())

	coin.animation = anim8.newAnimation(coin.grid("1-8", 1), 0.2)
	--
	--
	--
	--
	--

	DEBUG = false

	-- background repeated scrolling stuff
	Backgrounds = {
		{ img = love.graphics.newImage("pBG/1.png"), speed = 0.2, scroll = 0 },
		{ img = love.graphics.newImage("pBG/2.png"), speed = 0.4, scroll = 0 },
		{ img = love.graphics.newImage("pBG/4.png"), speed = 0.6, scroll = 0 },
	}
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
	HeroProps = {
		x = Herosize,
		y = (WindowDims.y / 2) - (Herosize / 2),
		rotation = 0,
		w = Herosize,
		h = Herosize / 2,
		speed = 250,
	}
	CoinsList = {}
	Bills = {}
	Coins = {}
	Score = 0
	CollectedCoins = 0
	GameSpeed = 300

	Hero = love.graphics.newImage("superhero1.png")
end

BACKSCROLLSPEEDFACTOR = 100

function love.update(dt)
	--
	coin.animation:update(dt)
	--

	if Score < 0 then
		love.event.quit("restart")
	end
	for _, bg in ipairs(Backgrounds) do
		bg.scroll = bg.scroll + BACKSCROLLSPEEDFACTOR * bg.speed * dt
		local bgW = bg.img:getWidth() * GLOBALBGCONST
		if bg.scroll >= bgW then
			bg.scroll = bg.scroll - bgW
		end
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

	for _, b in ipairs(CoinsList) do
		b.x = b.x + 400 * dt
	end

	for i, c in ipairs(Coins) do
		if CheckCollision(HeroProps, c) then
			CollectedCoins = CollectedCoins + 1
			table.remove(Coins, i)
		end
	end

	for i = #Bills, 1, -1 do
		local r = Bills[i]
		if CheckCollision(HeroProps, Bills[i]) then
			table.remove(Bills, i)
			Score = Score - 2
		end
		for j = #CoinsList, 1, -1 do
			local b = CoinsList[j]
			if CheckCollision(r, b) then
				table.remove(Bills, i)
				table.remove(CoinsList, j)
				Score = Score + 1
				break
			end
		end
	end

	for i = #CoinsList, 1, -1 do
		if CoinsList[i].x > WindowDims.x then
			table.remove(CoinsList, i)
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
	for _, bg in ipairs(Backgrounds) do
		local bgWidth = bg.img:getWidth() * GLOBALBGCONST
		love.graphics.draw(bg.img, -bg.scroll, 0, 0, GLOBALBGCONST)
		love.graphics.draw(bg.img, -bg.scroll + bgWidth, 0, 0, GLOBALBGCONST)
	end

	local img = Animation.images[Animation.current]
	local scaleX = HeroProps.w / Hero:getWidth()
	local scaleY = HeroProps.h / Hero:getHeight() * 2
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
		coin.animation:draw(coin.spriteSheet, c.x - 15, c.y - 15, nil, 2)
	end
	for _, b in ipairs(CoinsList) do
		love.graphics.circle("fill", b.x, b.y, b.w / 2)
	end
	love.graphics.print("Score: " .. Score, 10, 10)
	love.graphics.print("Coins: " .. CollectedCoins, 10, 30)

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
		for _, b in ipairs(CoinsList) do
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
		if CollectedCoins > 0 then
			table.insert(CoinsList, { x = HeroProps.x + HeroProps.w / 2, y = HeroProps.y, w = 10, h = 5 })
			CollectedCoins = CollectedCoins - 1
		end
	end
end
