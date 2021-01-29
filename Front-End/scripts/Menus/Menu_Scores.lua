ScoresMenu = Menu:new()
ScoresMenu.__index = ScoresMenu

function ScoresMenu:setup()
	self.submenu = Constants.EnumSubmenu.SCORES
	self.semesters = {}
	self.loading = true

	API.load_scores():success(function(response)
		self.semesters = response
		for idx, semester in ipairs(self.semesters) do
			semester.expanded = false
			semester.idx = idx
			for _, subject in ipairs(semester.subjects) do
				subject.expanded = false
				for _, score in ipairs(subject.scores) do
					score.is_score = true
				end
			end
		end

		self.total_elements = #self.semesters

		self:reload_buttons()

	end):after(function()
		self.loading = nil
	end)

	self.sprites = {
		bg_img = love.graphics.newImage("assets/menus/MenuScores.png"),
	}

end

function ScoresMenu:reload_buttons()
	local idx = 1
	self.buttons = {}
	for _, semester in ipairs(self.semesters) do
		semester.idx = idx
		self:add_button(semester)
		idx = idx + 1
		if semester.expanded then
			for _, subject in ipairs(semester.subjects) do
				subject.idx = idx
				self:add_button(subject)
				idx = idx + 1
				if subject.expanded then
					for _, score in ipairs(subject.scores) do
						score.idx = idx
						self:add_button(score)
						idx = idx + 1
					end
				end
			end
		end
	end

	if self.selected_score then
		table.insert(self.buttons, self:confirm_claim_btn())
	end
end

function ScoresMenu:confirm_claim_btn()
	return {
		x = 980,y = 580, w = 180, h = 50, text={{0,0,0,1}, ("Claim"):translate()},
		click = function() self:claim_score() end, text_size = 1.7
	}
end

function ScoresMenu:add_button(node)
	if node.is_score then
		node.btn = self:claim_score_btn(node)
	elseif node.expanded then
		node.btn = self:close_node_btn(node)
	else
		node.btn = self:expand_node_btn(node)
	end
	table.insert(self.buttons, node.btn)
end

function ScoresMenu:close_node_btn(node)
	return {
		x = 20,y = 135 + #self.buttons*30, r = 10, text_size=5, form="circle", text={{0,0,0,1}, "-"},
		click = function() self:close_node(node) end
	}
end

function ScoresMenu:expand_node_btn(node)
	return {
		x = 20,y = 135 + #self.buttons*30, r = 10, text_size=5, form="circle", text={{0,0,0,1}, "+"},
		click = function() self:expand_node(node) end
	}
end

function ScoresMenu:claim_score_btn(score)
	if score.claimed then
		return {
			x = 750,y = 122 + #self.buttons*30, w = 80, h = 25, text={{0,0,0,1}, ("Claimed"):translate()},
			text_size = 1.7, disabled = true
		}
	else
		return {
			x = 750,y = 122 + #self.buttons*30, w = 80, h = 25, text={{0,0,0,1}, ("Claim"):translate()},
			click = function() self:select_score(score) end, text_size = 1.7
		}
	end
end

function ScoresMenu:select_score(score)
	self.selected_score = score
	self:reload_buttons()
end

function ScoresMenu:close_node(node)
	node.expanded = false
	self.total_elements = self.total_elements - #(node.subjects or node.scores)
	self:reload_buttons()
end

function ScoresMenu:expand_node(node)
	node.expanded = true
	self.total_elements = self.total_elements + #(node.subjects or node.scores)
	self:reload_buttons()
end

function ScoresMenu:show()
	View.draw(self.sprites.bg_img, 0, 0, 0, 2/3)

	View.printf(("Scores"):translate(), 0, 10, 1829, "center", 0, 35/50)

	local level, x, y

	y = 120
	x = 60

	for _, semester in ipairs(self.semesters) do
		level = 0
		self:show_object(semester, x, y, level)
		y = y + 30
		if semester.expanded then
			for _, subject in ipairs(semester.subjects) do
				level = 1
				self:show_object(subject, x, y, level)
				y = y + 30
				if subject.expanded then
					for _, score in ipairs(subject.scores) do
						level = 2
						self:show_object(score, x, y, level)
						y = y + 30
					end
				end
			end
		end
	end

	if self.selected_score then
		self:show_selected()
	end

	self:draw_buttons()
end

function ScoresMenu:show_selected()
	local score = self.selected_score
	View.printf(score.name, 870, 160, 810, "center", 0, 0.5)
	View.printf(score.score.."/"..score.max, 870, 220, 810, "center", 0, 0.5)

	View.setColor(Item.rarities[3])
	View.draw(Item.border_img, 995, 300, 0, 1.5)
	View.setColor(1,1,1)
	View.draw(Item.currency.diamond, 995, 300, 0, 0.3)

	View.printf("x"..score.score*5, 870, 470, 810, "center", 0, 0.5)
end

function ScoresMenu:show_object(object, x, y, level)
	local label = object.name
	local idx = 1

	if object.scores then
		label = label.." - "..self:show_subject_total_score(object)
	end

	View.print(label, x + 100*level + 10, y, 0, 0.5)

	if object.is_score then
		View.printf(object.score.."/"..object.max, x, y, 1350, "right", 0, 0.5)
	end

	if level > 0 then
		View.line(x + 100*level, y + 15, x + 100*level - 30, y + 15, x + 100*level - 30, y)
		idx = 1
	end
end

function ScoresMenu:show_subject_total_score(subject)
	local total, max = 0, 0
	for _, score in ipairs(subject.scores) do
		total = total + score.score
		max = max + score.max
	end
	return total.."/"..max
end

function ScoresMenu:draw_score(score,x,y)
	View.print(score.name..": "..score.score.."/"..score.max, x+80, y+15, 0, 2/5)
		
	View.setColor(0,1,0.2)
	View.arc("fill", x+25, y+25, 25, 0, 2*math.pi*score.score/score.max)
	View.setColor(0,0,0)
	View.circle("fill", x+25, y+25, 20)
	View.setColor(1,1,1)
end

function ScoresMenu:claim_score()
	if not self.selected_score then return end
	API.claim_score(self.selected_score):success(function()
		self.selected_score.claimed = true
		GameController.player:gain_currency("diamonds", self.selected_score.score*5)
	end):after(function()
		self.loading = nil
		self.selected_score = nil
		self:reload_buttons()
	end)
end

function ScoresMenu:click(x,y,k)
	if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	end
end
