local _, Oken = ...

function Oken:Round(val, decimal)
	if decimal then
		return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(val+0.5)
	end
end

function Oken:ShortenNumber(value, decimal)
	if not value then return end
	if(value > 999999999) then return self:Round(value/1000000000, decimal), "B" end
	if(value > 999999) then return self:Round(value/1000000, decimal), "M" end
	if(value > 999) then return self:Round(value/1000, decimal), "k" end
	return value, ""
end

function Oken:FormatNumber(value, decimal, pattern)
	if not value then return end
	return (pattern or "%s%s"):format(self:ShortenNumber(value, decimal))
end

function Oken:GetClassColor(unit, components)
	local target_class = select(2, UnitClass(unit))
	if target_class then
		if components then
			local color = RAID_CLASS_COLORS[target_class]
			return color.r, color.g, color.b, 1
		else
			return RAID_CLASS_COLORS[target_class].colorStr
		end
	else
		if components then
			return 1, 1, 1, 1
		else
			return "ffffffff"
		end
	end
end

local icn_string = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:%s|t"
function Oken:Icon(index, align)
	if not index then return "" end
	return icn_string:format(index, align or "0")
end

function Oken:Wrap(str, length)
	local wrapped = ""
	while true do
		local a, b = str:match("(" .. ("."):rep(length) .. ")(.*)")
		if a then
			wrapped = wrapped .. a .. "\n"
			str = b
		else
			wrapped = wrapped .. str
			break
		end
	end
	return wrapped
end

function Oken:ColorGradient(perc,...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end
