Utils = {}

function Utils.mergeTables(FirstTable, SecondTable)
	for k,v in pairs(SecondTable) do FirstTable[k] = v end
end

function Utils.inheritsFrom( baseClass )
    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    return new_class
end

function Utils.PrintTb(tb)
	if not tb then print ("nil") return end
	print ("{")
	for key, value in pairs(tb) do
		print ("\t"..key.." : "..tostring(value))
	end
	print ("}")
end

function Utils.PrintTbRec(tb, depth)
	local depth = depth or 0
	local pref = "\t"
	for i=1,depth do
		pref = pref.."\t"
	end
	
	if not tb then print ("nil") return end
	print (pref:sub(1,-2).."{")
	for key, value in pairs(tb) do	
		if type(value) == "table" then
			print (pref..key.." :")
			Utils.PrintTbRec(value, depth + 1)
		else
			print (pref..key.." : "..tostring(value))
		end
	end
	print (pref:sub(1,-2).."}")
end

function Utils.table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
		elseif type(k) == "number" then
			result = result.."["..k.."]".."="
        end

        if type(v) == "table" then
            result = result..Utils.table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        elseif type(v) == "number" then
			result = result..v
		elseif type(v) == "userdata" then
			result = result.."\"Image\""
		else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    if result ~= "{" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

function Utils.table_to_json(tbl)
    return Json.encode(tbl)
end

function string:translate()
	return self
end

function string:split(separator, isRegex, nMax)
	local separator = separator or " "
	local isRegex = isRegex or false
	local nMax = nMax or -1

    local aRecord = {}

    if self:len() > 0 then
		local isPlain = not isRegex

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(separator, nStart, isPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(separator, nStart, isPlain)
			nMax = nMax-1
        end
        aRecord[nField] = self:sub(nStart)
    end

   return aRecord
end

function string:remove_last()
	local c
	local new_text, new_str = {}, ""
	for c in self:gmatch(".[\128-\191]*") do
		table.insert(new_text, c)
	end
	table.remove(new_text, #new_text)
	for _,c in ipairs(new_text) do new_str = new_str..c end
	return new_str
end

function Utils.convert_coords(x,y)
	local Sx, Sy, _ = love.window.getMode()
	return x*1280/Sx, y*720/Sy
end

function Utils.shine_img()
	local canvas = love.graphics.newCanvas(250,250)
	love.graphics.setCanvas(canvas)
	love.graphics.push()
	love.graphics.origin()
	
	love.graphics.setColor(1,1,1,1/100)
	for i=1,250 do
		View.circle("fill",125,125,i/2)
	end
	love.graphics.setColor(1,1,1,1)
	
	love.graphics.setCanvas()
	love.graphics.pop()
	return love.graphics.newImage(canvas:newImageData())
end

function Utils.sig(value)
	if value == 0 or value == 1 then return value end
	return (math.sin(math.pi * (value-0.5)) + 1)/2
end

function Utils.draw_loading(timer)
	View.setColor(0,0,0,0.3)
	View.rectangle("fill",0,0,1280,720)
	local angle, alpha, alpha_angle
	View.setLineWidth(1)
	
	for i=0,15 do
		angle = 2*math.pi*i/16
		alpha_angle = (angle+timer*2)
		alpha = math.sin(alpha_angle)
		if math.floor((alpha_angle*2)/math.pi)%2 == 0 then alpha = 0 end
		View.setColor(1,1,1,alpha)
		View.circle("line", 640+35*math.sin(angle), 360-35*math.cos(angle), 5)
	end
	
	View.setColor(1,1,1,1)
end

function Utils.shallowcopy(orig)
    local copy, orig_value, orig_key
    copy = {}
    for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
    end
    return copy
end