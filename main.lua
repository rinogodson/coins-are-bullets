-- Comments are added to differentiate different parts of my code
-- Love2D becomes crowdy when everything's working (i'm lazy for a more modular approach)
_G.love = require("love")
_G.anim8 = require("libraries.anim8")

GLOBALBGCONST = 1.23

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	_G.jersey = love.graphics.newFont("Jersey.ttf", 32)
	_G.small_jersey = love.graphics.newFont("Jersey.ttf", 18)
	love.graphics.setFont(jersey)

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
	-- BILLS PART I'm doin
	--
	--
	_G.bill = {}
	bill.spriteSheet = love.graphics.newImage("bills.png")
	bill.grid = anim8.newGrid(19, 20, bill.spriteSheet:getWidth(), bill.spriteSheet:getHeight())
	bill.animation = anim8.newAnimation(bill.grid("1-2", 1), 0.1)
	--
	--
	--
	--

	DEBUG = false

	GameState = "splash"

	-- background repeated scrolling stuff
	Backgrounds = {
		{ img = love.graphics.newImage("pBG/1.png"), speed = 0.2, scroll = 0 },
		{ img = love.graphics.newImage("pBG/2.png"), speed = 0.4, scroll = 0 },
		{ img = love.graphics.newImage("pBG/4.png"), speed = 0.6, scroll = 0 },
	}
	BGScrollProgress = 0

	SplashImage = love.graphics.newImage("title.png")

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
	Aura = 0
	CollectedCoins = 0
	GameSpeed = 300
	Score = {}
	Score.val = 0
	Score.timer = 0

	Hero = love.graphics.newImage("superhero1.png")

	-- all the things for the ears
	_G.gamesound = love.audio.newSource("sounds/gamesong.wav", "static")
	gamesound:setVolume(0.5)
	gamesound:setLooping(true)
	_G.gamesoundinfo = {}
	gamesoundinfo.delay = 2
	gamesoundinfo.timer = 0
	gamesoundinfo.waiting = false

	_G.startsound = love.audio.newSource("sounds/start.wav", "static")
	startsound:setVolume(0.6)

	_G.coinSound = love.audio.newSource("sounds/coin.wav", "static")

	_G.gameoversound = love.audio.newSource("sounds/explosion.wav", "static")
	_G.auralosingsound = love.audio.newSource("sounds/hurt.wav", "static")
	_G.billPayment = love.audio.newSource("sounds/jump.wav", "static")
	_G.upanddownsound = love.audio.newSource("sounds/upanddown.wav", "static")

	upanddownsound:setVolume(0.5)

	ShowHelp = false
	HelpCont = {
		width = 500,
		height = 300,
		pad = 20,
		bg = { 0, 0, 0, 0.9 },
		text = [[ Game:
  You're the superhero of your life!
  You earn, spend, gain, or lose...
  In this game, you need to collect Coins and use them as bullets against the Bills coming at you (you basically pay the bills).
  When you pay a bill, you gain 1 Aura Point, and when you crash into a bill, you lose 3 Aura Points.
  THE GOAL OF THE GAME IS: Don't let your Aura Points go negative.
  Your score is determined by how long you survive.

Controls:
  <space> : shoot / start or restart
  <UP/DOWN> : dodge the bills ]],
	}
end

BACKSCROLLSPEEDFACTOR = 100

function love.update(dt)
	if GameState == "splash" then
	--
	elseif GameState == "gameover" then
	--
	else
		if gamesoundinfo.waiting then
			gamesoundinfo.timer = gamesoundinfo.timer + dt
			if gamesoundinfo.timer >= gamesoundinfo.delay then
				startsound:stop()
				gamesound:play()
				gamesoundinfo.waiting = false
			end
		end
		--
		coin.animation:update(dt)
		bill.animation:update(dt)
		--
		--
		Score.timer = Score.timer + dt
		if Score.timer >= 1 then
			Score.val = Score.val + 1
			Score.timer = Score.timer - 1
		end

		if Aura < 0 then
			gameoversound:play()
			GameState = "gameover"
			Aura = 0
			Coins = {}
			Bills = {}
			CoinsList = {}
			Backgrounds[1].scroll = 0
			Backgrounds[2].scroll = 0
			Backgrounds[3].scroll = 0
			gamesound:stop()
			gamesoundinfo.waiting = false
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
			b.x = b.x + 300 * dt
		end

		for i, c in ipairs(Coins) do
			if CheckCollision(HeroProps, c) then
				CollectedCoins = CollectedCoins + 1
				coinSound:play()
				table.remove(Coins, i)
			end
		end

		for i = #Bills, 1, -1 do
			local r = Bills[i]
			if CheckCollision(HeroProps, Bills[i]) then
				table.remove(Bills, i)
				auralosingsound:play()
				Aura = Aura - 3
			end
			for j = #CoinsList, 1, -1 do
				local b = CoinsList[j]
				if CheckCollision(r, b) then
					billPayment:play()
					table.remove(Bills, i)
					table.remove(CoinsList, j)
					Aura = Aura + 1
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
	if GameState == "splash" then
		for _, bg in ipairs(Backgrounds) do
			love.graphics.draw(bg.img, 1, 0, 0, GLOBALBGCONST)
		end

		love.graphics.draw(SplashImage, 10, 10, 0, 0.6)

		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.printf(
			[[PRESS SPACE TO PLAY
    How to play the game? Press H]],
			0,
			WindowDims.y - 100,
			WindowDims.x,
			"center"
		)
		love.graphics.setColor(1, 1, 1, 1)
	--
	elseif GameState == "gameover" then
		for _, bg in ipairs(Backgrounds) do
			love.graphics.draw(bg.img, 1, 0, 0, GLOBALBGCONST)
		end

		love.graphics.setColor(0, 0, 0)
		love.graphics.printf("YOU ARE BANKRUPT! GAME OVER", 0, WindowDims.y / 3, WindowDims.x, "center")
		love.graphics.printf("Score: " .. Score.val, 0, (WindowDims.y / 2) + 30, WindowDims.x, "center")
		love.graphics.setColor(1, 1, 1, 1)
	--
	else
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
			bill.animation:draw(bill.spriteSheet, r.x - 15, r.y - 15, nil, 2)
		end
		for _, c in ipairs(Coins) do
			coin.animation:draw(coin.spriteSheet, c.x - 15, c.y - 15, nil, 2)
		end

		for _, b in ipairs(CoinsList) do
			coin.animation:draw(coin.spriteSheet, b.x - 2, b.y - 2, nil, 1)
		end
		love.graphics.print("Aura: " .. Aura, 10, 10)
		love.graphics.print("Coins: " .. CollectedCoins, 10, 30)
		love.graphics.printf("Score: " .. Score.val, 0, 10, WindowDims.x - 20, "right")

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
	end

	----------
	---
	if ShowHelp then
		love.graphics.setFont(small_jersey)
		love.graphics.setColor(HelpCont.bg)
		love.graphics.rectangle(
			"fill",
			(WindowDims.x / 2) - (HelpCont.width / 2),
			(WindowDims.y / 2) - (HelpCont.height / 2),
			HelpCont.width,
			HelpCont.height,
			5,
			5
		)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(
			HelpCont.text,
			((WindowDims.x / 2) - (HelpCont.width / 2)) + HelpCont.pad,
			((WindowDims.y / 2) - (HelpCont.height / 2)) + HelpCont.pad,
			HelpCont.width - 2 * HelpCont.pad
		)
		love.graphics.setFont(jersey)
	end
	-------
end

function love.keypressed(key)
	if key == "up" or key == "down" then
		upanddownsound:play()
	end
	if key == "h" then
		ShowHelp = not ShowHelp
	end
	if GameState == "splash" then
		if key == "space" then
			GameState = "playing"
			startsound:play()
			gamesoundinfo.timer = 0
			gamesoundinfo.waiting = true
		end
	elseif GameState == "gameover" then
		if key == "space" then
			Score.val = 0
			Score.timer = 0

			startsound:play()
			GameState = "playing"
			gamesoundinfo.timer = 0
			gamesoundinfo.waiting = true
		end
	else
		if key == "space" then
			if CollectedCoins > 0 then
				table.insert(CoinsList, { x = HeroProps.x + HeroProps.w / 2, y = HeroProps.y, w = 10, h = 5 })
				CollectedCoins = CollectedCoins - 1
			end
		end
	end
end
