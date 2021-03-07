Constants = {
	PICKER_RADIUS = 35,
	CAMERA_SPEED = 400,
	STATUS_OK = 200,
}

Constants.EnumGender = {
	F = "F",
	M = "M",
}

Constants.EnumBodyPart = {
	HEAD = 1,
	ARM_1 = 2,
	ARM_2_1 = 3,
	BODY = 4,
	LEG_1 = 5,
	LEG_B_1 = 6,
	FEET_1 = 7,
	LEG_B_2 = 8,
	FEET_2 = 9,
	LEG_2 = 10,
	ARM_2_2 = 11,
}

Constants.EnumTrait = {
	HAIR = "hair",
	EYES = "eyes",
	SKIN = "skin",
}

Constants.EnumPhase = {
	IDLE = 0,
	MOVEMENT = 1,
	ACTION = 2,
}

Constants.EnumObjType = {
	PLAYER = 1,
	ENEMY = 2,
	OBSTACLE = 3,
}

Constants.EnumClass = {
	MAGE = 1,
	KNIGHT = 2,
	THIEF = 3,
}

Constants.EnumGameState = {
	MENU = 0,
	QUEST = 1,
	LOGIN = 2,
	CREATION = 3,
	TUTORIAL = 4,
}
	
Constants.EnumSubmenu = {
	MAIN 	= 0,
	ITEMS 	= 1,
	SCORES 	= 2,
	MISSIONS= 3,
	SKILL 	= 4,
	SHOP 	= 5,
	TASKS 	= 6,
	HELP 	= 7,
	OPTIONS = 8,
}

Constants.ItemCategory = {
	WEAPON = 1,
	HEAD = 2,
	ARMOR = 3,
	ACC = 4,
	ACC_2 = 5,
}

Constants.WpnCategory = {
	NONE = 0,
	SWORD = 1,
	DAGGERS = 2,
	BOW = 3,
	SPEAR = 4,
	STAFF = 5,
	BOOK = 6,
}

Constants.EnumHatType = {
	NONE = nil,
	HAT = 1,
	HELM = 2,
}

Constants.EnumDiff = {
	EASY = 1,
	MEDIUM = 2,
	HARD = 3,
}

Constants.DmgType = {
	PHY = 1,
	MAG = 2,
}

Constants.EnumAnimation = {
	ATTACK = 1,
}

Constants.FONT_8BIT = love.graphics.newFont("assets/fonts/8-bit-limit/8bitlim.ttf", 80, "light")
Constants.FONT_FRIVOLITY = love.graphics.newFont("assets/fonts/aka-frivolity/akaFrivolity.ttf", 80, "light")
Constants.FONT_ROTH = love.graphics.newFont("assets/fonts/rothenburg-decorative/Rothenburg Decorative.ttf", 80, "light")
Constants.FONT_DUMBLEDOR = love.graphics.newFont("assets/fonts/dumbledor-1/dum1.ttf", 80, "light")
Constants.FONT_LUCID = love.graphics.newFont("assets/fonts/lucid-type/lucid.ttf", 80, "light")
Constants.FONT = love.graphics.newFont(50)
