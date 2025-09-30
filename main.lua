function love.load()
	Ship = { x = 200, y = 200, w = 40, h = 40, speed = 200 }
	Bullets = {}
	Rocks = {}
	Coins = {}
	Score = 0
end

function love.update(dt)
	if math.random() < 0.02 then
		table.insert(Rocks, { x = math.random(0, 800), y = 600, w = 40, h = 40 })
	end
	if math.random() < 0.01 then
		table.insert(Coins, { x = math.random(0, 800), y = 600, w = 20, h = 20 })
	end

	for _, r in ipairs(Rocks) do
		r.y = r.y - 200 * dt
	end
	for _, c in ipairs(Coins) do
		c.y = c.y - 200 * dt
	end

	for _, b in ipairs(Bullets) do
		b.y = b.y + 400 * dt
	end

	for i, c in ipairs(Coins) do
		if CheckCollision(Ship, c) then
			Score = Score + 1
			table.remove(Coins, i)
		end
	end

	for _, r in ipairs(Rocks) do
		if CheckCollision(Ship, r) then
			love.event.quit("restart")
		end

		for j, b in ipairs(Bullets) do
			if CheckCollision(r, b) then
				table.remove(Rocks, j)
				table.remove(Bullets, j)
				break
			end
		end
	end
end

-- checking colisions
function CheckCollision(a, b)
	return a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
end

function love.draw()
	love.graphics.rectangle("fill", Ship.x, Ship.y, Ship.w, Ship.h)
	for _, r in ipairs(Rocks) do
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
	if key == "up" then
		Ship.y = Ship.y - 50
	end
	if key == "down" then
		Ship.y = Ship.y + 50
	end
	if key == "space" then
		table.insert(Bullets, { x = Ship.x + Ship.w, y = Ship.y + Ship.h / 2, w = 10, h = 5 })
		Score = Score - 1
	end
end
