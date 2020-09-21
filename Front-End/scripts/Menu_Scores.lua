ScoresMenu = Menu:new()
ScoresMenu.__index = ScoresMenu

function ScoresMenu:setup()
	self.submenu = Constants.EnumSubmenu.SCORES
	self.scores = {unclaimed={}, claimed={}}
	
	self.loading = true
	API.load_scores()
	Promise:new():success(function(response) 
		self.scores = response
		self:refresh_buttons()
	end):after(function() 
		MyLib.skip_frame = true
		self.loading = nil
	end)
end

function ScoresMenu:refresh_buttons()
	self.buttons = {}
	
	local idx, score, x, y
	for idx, score in ipairs(self.scores.unclaimed) do
		y = math.ceil(idx/2)*80 + 70
		
		table.insert(self.buttons, {
			x = 540,y = y, w = 80, h = 30, text={{0,0,0,1}, ("Claim"):translate()},
			click = function() self:claim_score(score) end
		})
	end
end

function ScoresMenu:show()
	View.printf(("Scores"):translate(), 0, 15, 1829, "center", 0, 35/50)
	
	View.printf(("Unclaimed"):translate(), 0, 85, 1280, "center", 0, 1/2)
	View.printf(("Claimed"):translate(), 640, 85, 1280, "center", 0, 1/2)
	
	View.line(0, 70, 1280, 70)
	View.line(640, 70, 640, 720)
	
	local idx, score, x, y
	
	for idx, score in ipairs(self.scores.unclaimed) do
		y = math.ceil(idx/2)*80 + 60
		x = 20
				
		self:draw_score(score,x,y)
	end
	
	for idx, score in ipairs(self.scores.claimed) do
		y = math.ceil(idx/2)*80 + 60
		x = 660
		
		self:draw_score(score,x,y)
	end
	
	self:draw_buttons()
end

function ScoresMenu:draw_score(score,x,y)
	View.print(score.name..": "..score.score.."/"..score.max, x+80, y+15, 0, 2/5)
		
	View.setColor(0,1,0.2)
	View.arc("fill", x+25, y+25, 25, 0, 2*math.pi*score.score/score.max)
	View.setColor(0,0,0)
	View.circle("fill", x+25, y+25, 20)
	View.setColor(1,1,1)
end

function ScoresMenu:claim_score(score)
	API.claim_score(score)
	Promise:new():after(function(response) 
		API.load_scores()
		Promise:new():success(function(response) 
			self.scores = response
			self:refresh_buttons()
		end):after(function() 
			self.loading = nil
		end)
	end)
end

function ScoresMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	end
end
