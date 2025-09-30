function love.load()
	ship = { x = 200, y = 200, w = 40, h = 40, speed = 200 }
	bullets = {}
	rocks = {}
	coins = {}
	Score = 0
end

function love.update(dt)
	if math.random() < 0.02 then
		table.insert(rocks, { x = math.random(0, 800), y = 600, w = 40, h = 40 })
	end
	if math.random() < 0.01 then
		table.insert(coins, { x = math.random(0, 800), y = 600, w = 20, h = 20 })
	end

	for _, r in ipairs(rocks) do
		r.y = r.y - 200 * dt
	end
	for _, c in ipairs(coins) do
		c.y = c.y - 200 * dt
	end

	for _, b in ipairs(bullets) do
		b.y = b.y + 400 * dt
	end

	for i, c in ipairs(coins) do
		if CheckCollision(ship, c) then
			Score = Score + 1
			table.remove(coins, i)
		end
	end

	for _, r in ipairs(rocks) do
		if CheckCollision(ship, r) then
			love.event.quit("restart")
		end

		for j, b in ipairs(bullets) do
			if CheckCollision(r, b) then
				table.remove(rocks, j)
				table.remove(bullets, j)
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
	love.graphics.rectangle("fill", ship.x, ship.y, ship.w, ship.h)
	for _, r in ipairs(rocks) do
		love.graphics.rectangle("line", r.x, r.y, r.w, r.h)
	end
	for _, c in ipairs(coins) do
		love.graphics.circle("fill", c.x, c.y, c.w / 2)
	end
	for _, b in ipairs(bullets) do
		love.graphics.circle("fill", b.x, b.y, b.w / 2)
	end
	love.graphics.print("Score: " .. Score, 10, 10)
end

function love.keypressed(key)
	if key == "up" then
		ship.y = ship.y - 50
	end
	if key == "down" then
		ship.y = ship.y + 50
	end
	if key == "space" then
		table.insert(bullets, { x = ship.x + ship.w, y = ship.y + ship.h / 2, w = 10, h = 5 })
		Score = Score - 1
	end
end
