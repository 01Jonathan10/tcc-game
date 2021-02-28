QuestsMenu = Menu:new()
QuestsMenu.__index = QuestsMenu

function QuestsMenu:setup()
    self.submenu = Constants.EnumSubmenu.MISSIONS
    self.selection = nil
    self.mouseover = nil
    self.mouseover_diff = nil
    self.mouseover_go = nil
    self.diff_select = nil
    self.quest_list = {}
    self.total_quests = #self.quest_list

    self.loading = true

    API .get_quests():success(function(response)
        local each
        for _, each in ipairs(response) do
            table.insert(self.quest_list, Quest:new(each))
        end
        self.total_quests = #self.quest_list
    end):after(function()
        self.loading = nil
    end)

    self.sprites = {
        bg_img = love.graphics.newImage("assets/menus/MenuQuests.png"),
    }

    self.buttons = {
        {
            x = 700, y = 655, w = 200, h = 30, text = { { 0, 0, 0, 1 }, ("Go"):translate() },
            text_size = 1.4, click= function() if self.diff_select then self:go_to_quest() end end
        },
        {
            x = 340, y = 460, w = 100, h = 40, text = { { 0, 0, 0, 1 }, ("Easy"):translate() },
            click= function() if self.selection then self.diff_select = 1 end end
        },
        {
            x = 340, y = 520, w = 100, h = 40, text = { { 0, 0, 0, 1 }, ("Medium"):translate() },
            click= function() if self.selection then self.diff_select = 2 end end
        },
        {
            x = 340, y = 580, w = 100, h = 40, text = { { 0, 0, 0, 1 }, ("Hard"):translate() },
            click= function() if self.selection then self.diff_select = 3 end end
        }
    }

    View.setLineWidth(3)
end

function QuestsMenu:show()
    local index, quest

    View.draw(self.sprites.bg_img, 0, 0, 0, 2 / 3)

    View.printf(("Quests"):translate(), 0, 10, 1829, "center", 0, 35 / 50)
    View.printf(("Energy"):translate() .. ": " .. GameController.player.energy .. "/100", 0, 90, 3200, "center", 0, 2 / 5)

    if self.selection then
        self:show_quest()
    else
        View.printf(("Select a quest in the list"):translate(), 320, 400, 2400, "center", 0, 2 / 5)
    end

    for index, quest in ipairs(self.quest_list) do
        View.print({ { 0, 0, 0 }, "- " .. quest.name }, 30, 160 + 40 * (index - 1), 0, 15 / 50)
    end

    if self.diff_select then
        self:draw_btn(self.buttons[1])
    end

    if self.selection then
        self:draw_btn(self.buttons[2])
        self:draw_btn(self.buttons[3])
        self:draw_btn(self.buttons[4])
    end
end

function QuestsMenu:click(x, y, k)
    if self.disabled then
        return
    end

    if k == 2 then
        MyLib.FadeToColor(0.25, { function()
            MainMenu:new()
        end })
    else
        if x <= 320 and y > 150 and y <= 150 + 40 * self.total_quests then
            local index = math.ceil((y - 150) / 40)
            self.selection = self.quest_list[index]
            self.diff_select = nil
        end
    end
end

function QuestsMenu:go_to_quest()
    self.disabled = true
    self.loading = true

    API.enter_quest(self.selection, self.diff_select):success(function(response)
        MyLib.FadeToColor(0.25, { function()
            GameController.player:unload_model()
            GameController.start_quest(response.quest, response.diff, response.actions)
        end })
    end):fail(function(data)
        self.disabled = nil
        self.loading = nil
        API.error(data)
    end)
end

function QuestsMenu:show_quest()
    View.printf(self.selection.name:translate(), 320, 150, 2400, "center", 0, 2 / 5)
    View.printf(self.selection.description:translate(), 340, 220, 3000, "left", 0, 15 / 50)

    View.printf(("Difficulties"):translate(), 340, 400, 1200, "center", 0, 2 / 5)

    View.print(("Easy"):translate(), 340, 470, 0, 15 / 50)
    if self.selection.cleared[Constants.EnumDiff.EASY] then
        View.print(("Cleared"):translate(), 520, 470, 0, 15 / 50)
    end

    View.print(("Medium"):translate(), 340, 530, 0, 15 / 50)
    if self.selection.cleared[Constants.EnumDiff.MEDIUM] then
        View.print(("Cleared"):translate(), 520, 530, 0, 15 / 50)
    end

    View.print(("Hard"):translate(), 340, 590, 0, 15 / 50)
    if self.selection.cleared[Constants.EnumDiff.HARD] then
        View.print(("Cleared"):translate(), 520, 590, 0, 15 / 50)
    end

    if self.diff_select then
        local rewards = self.selection:rewards(self.diff_select)
        View.printf(("Rewards"):translate(), 800, 400, 1200, "center", 0, 2 / 5)

        Item.draw_currency(820, 440, 75, 'gold')
        Item.draw_currency(1050, 440, 75, 'xp')

        View.print(rewards.gold.." Gold", 900, 470, 0, 0.3)
        View.print(rewards.xp.." Experience", 1130, 470, 0, 0.3)

        if not self.selection.cleared[self.diff_select] then
            View.printf(("First Clear Rewards"):translate(), 800, 520, 1200, "center", 0, 2 / 5)

            Item.draw_currency(820, 560, 75, 'gold')
            Item.draw_currency(1050, 560, 75, 'xp')

            View.print(3*rewards.gold.." Gold", 900, 590, 0, 0.3)
            View.print(3*rewards.xp.." Experience", 1130, 590, 0, 0.3)
        end

        View.printf(("Energy Cost"):translate() .. ": " .. self.selection.energy[self.diff_select], 320, 690, 3200, "center", 0, 15 / 50)
    end
end