Tutorial = {}
Tutorial.__index = Tutorial

function Tutorial:new()
	local images = {}
	for i=1,6 do
		images[i] = love.graphics.newImage("assets/tutorial/"..i..".png")
	end
	return setmetatable({step = 1, images = images}, Tutorial)
end

function Tutorial:draw()
	View.draw(self.images[self.step], 0, 0, 0, 2 / 3)
	View.setColor(0,0,0,0.3)
	View.rectangle('fill', 0, 0, 1280, 720)
	View.setColor(1,1,1)
	View.print("TUTORIAL: Click anywhere to continue", 50, 20, 0, 20 / 50)
end

function Tutorial:click()
	if not self.images[self.step + 1] then
		GameController.go_to_menu()
	else
		self.step = self.step + 1
	end
end
