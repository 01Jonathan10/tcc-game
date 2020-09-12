-- 1 = Head
-- 2 = Arm_1
-- 3 = Arm_2
-- 4 = Body
-- 5 = Leg_1
-- 6 = Leg_b_1
-- 7 = Feet_1
-- 8 = Leg_b_2
-- 9 = Feet_2
-- 10= Leg_2

return{
	{
		id = 1,
		x1 = 200,	x2=195,
		y1 = 50,	y2=45,
	},
	{
		id = 2,
		x1 = 387,	x2=382,
		y1 = 310,	y2=303,
		ox = 137,
		oy = 114,
		r2 = 2*math.pi*(-0.01),
	},
	{
		id = 3,
		x1 = 410,	x2=407,
		y1 = 387,	y2=375,
		ox = 148,
		oy = 102,
		r2 = 2*math.pi*(-0.01),
	},
	{
		x1 = 200,	x2=195,
		y1 = 210,	y2=200,
		sx1 = 1,
		sx2 = 1,
		sy1 = 1,
		sy2 = 1.05,
		id = 4,
	},
	{
		id = 5,
		x1 = 385,	x2=380,
		y1 = 443,	y2=443,
		ox = 150,
		oy = 88,
		r1 = 2*math.pi*(0.005),
		r2 = 2*math.pi*(-0.005),
	},
	{
		id = 10,
		x1 = 335,	x2=328,
		y1 = 455,	y2=455,
		sx1 = 1,
		ox = 150,
		oy = 88,
		r1 = 2*math.pi*(0.05),
		r2 = 2*math.pi*(0.045),
	},
	{
		id = 2,
		x1 = 290,	x2=290,
		y1 = 308,	y2=298,
		ox = 137,
		oy = 114,
		sx1 = -1,
		r2 = 2*math.pi*(0.01),
	},
	{
		id = 11,
		x1 = 270,	x2=264,
		y1 = 381,	y2=376,
		ox = 148,
		oy = 102,
		sx1 = -1,
		r2 = 2*math.pi*(0.01),
	},
	{
		id = 7,
		x1 = 312,	x2=310,
		y1 = 635,	y2=630,
		ox = 160,
		oy = 140,
		r2 = 2*math.pi*(-0.02),
	},
	{
		id = 6,
		x1 = 316,	x2=310,
		y1 = 555,	y2=550,
		ox = 154,
		oy = 104,
		r2 = 2*math.pi*(-0.01),
	},
	{
		id = 9,
		x1 = 440,	x2=440,
		y1 = 640,	y2=638,
		ox = 160,
		oy = 140,
		sy2 = 1.05,
	},
	{
		id = 8,
		x1 = 386,	x2=385,
		y1 = 540,	y2=538,
		ox = 120,
		oy = 110,
		r2 = 2*math.pi*(-0.01),
	},
	body = 4,
}