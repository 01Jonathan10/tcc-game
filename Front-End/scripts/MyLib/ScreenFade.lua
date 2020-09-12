require ('Class_Fade')

function MyLib.FadeToColor(Time, Variables, Values, Type, Color, Mirror)
	if Mirror == nil then Mirror = true end
	local Color = Color or {0,0,0,1}
	local Type = Type or "fill"
	local Values = Values or {}
	local Variables = Variables or {}
	MyLib.FadeClass.create(Time, Variables, Values, Type, Color, Mirror)	
end

function MyLib.FadeImg(Time, Variables, Values, InOut, Img, X, Y)
	MyLib.FadeClass.create(Time, Variables, Values, "Img", Img, Inout, X, Y)	
end

function MyLib.DrawFades()
	for _, fade in pairs(MyLib.Fades) do
		fade:draw()
	end
	
	love.graphics.setColor(1,1,1,1)
end

function MyLib.ApplyFades(dt)
	for _, fade in pairs(MyLib.Fades) do
		fade:update(dt)
	end
end
