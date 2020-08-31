HelpMenu = Menu:new()
HelpMenu.__index = HelpMenu

function HelpMenu:setup()
	self.submenu = Constants.EnumSubmenu.HELP
	self.bg_img = love.graphics.newImage("assets/Main.png")
	self.selection = nil
end

function HelpMenu:show()

end

function HelpMenu:update(dt)
	self.selection = nil
	local col, lin = nil, nil
	local mx, my = Utils.convert_coords(love.mouse.getPosition())
	
	if (mx>=1400 and mx<=1580) then col = 0 end
	if (mx>=1670 and mx<=1850) then col = 1 end
	
	if (my>=150 and my<=330) then lin = 0 end
	if (my>=380 and my<=560) then lin = 1 end
	if (my>=610 and my<=790) then lin = 2 end
	if (my>=840 and my<=1020) then lin = 3 end
	
	if lin and col then self.selection = 4*col + lin end	
end

function HelpMenu:mousepressed(x,y,k)
	 if self.selection then
		MyLib.FadeToColor(0.25, {function() 
			self.menu_list[self.selection+1]:new()
		end})
	 end
	 
	 if k == 2 then
		MyLib.FadeToColor(0.25, {function() 
			MainMenu:new()
		end})
	 end
end
