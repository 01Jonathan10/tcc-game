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
		y1 = 80,	y2=75,
	},
	{
		id = 2,
		x1 = 387,	x2=382,
		y1 = 340,	y2=333,
		ox = 137,
		oy = 114,
		r1 = 2*math.pi*(-0.09),
		r2 = 2*math.pi*(-0.10),
	},
	{
		id = 3,
		x1 = 450,	x2=447,
		y1 = 397,	y2=385,
		ox = 148,
		oy = 102,
		r1 = 2*math.pi*(-0.05),
		r2 = 2*math.pi*(-0.06),
	},
	{
		id = -1,
		x1 = 480,	x2=482,
		y1 = 580,	y2=567,
		sx1 = 0.7,
		sy1 = 0.7,
		r1 = 2*math.pi*(-0.33),
		r2 = 2*math.pi*(-0.34),
		ox = 250,
		oy = 400,
	},
	{
		x1 = 200,	x2=195,
		y1 = 240,	y2=230,
		sy2 = 1.05,
		id = 4,
	},
	{
		id = 5,
		x1 = 385,	x2=380,
		y1 = 473,	y2=473,
		ox = 150,
		oy = 88,
		r1 = 2*math.pi*(-0.05),
		r2 = 2*math.pi*(-0.055),
	},
	{
		id = 10,
		x1 = 335,	x2=328,
		y1 = 485,	y2=485,
		ox = 150,
		oy = 88,
		r1 = 2*math.pi*(0.15),
		r2 = 2*math.pi*(0.160),
	},
	{
		id = 2,
		x1 = 290,	x2=290,
		y1 = 338,	y2=328,
		ox = 137,
		oy = 114,
		sx1 = -1,
		r2 = 2*math.pi*(0.01),
	},
	{
		id = 11,
		x1 = 270,	x2=264,
		y1 = 411,	y2=406,
		ox = 148,
		oy = 102,
		sx1 = -1,
		r1 = 2*math.pi*(0.11),
		r2 = 2*math.pi*(0.12),
	},
	{
		id = 7,
		x1 = 232,	x2=230,
		y1 = 635,	y2=630,
		ox = 160,
		oy = 140,
		r2 = 2*math.pi*(-0.02),
	},
	{
		id = 6,
		x1 = 256,	x2=250,
		y1 = 565,	y2=560,
		ox = 154,
		oy = 104,
		r1 = 2*math.pi*(0.05),
		r2 = 2*math.pi*(0.045),
	},
	{
		id = 9,
		x1 = 480,	x2=480,
		y1 = 640,	y2=640,
		ox = 160,
		oy = 140,
	},
	{
		id = 8,
		x1 = 406,	x2=405,
		y1 = 550,	y2=552,
		ox = 120,
		oy = 110,
		r1 = 2*math.pi*(-0.05),
		r2 = 2*math.pi*(-0.06),
	},
	{
		id = -1,
		x1 = 200,	x2=192,
		y1 = 573,	y2=566,
		sx1 = 0.7,
		sy1 = 0.7,
		r1 = 2*math.pi*(-0.09),
		r2 = 2*math.pi*(-0.08),
		ox = 250,
		oy = 400,
	},
	body = 5,
}