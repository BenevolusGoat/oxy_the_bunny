local Mod = OxyTheBunny
local floor = math.floor
local ceil = math.ceil
local max = math.max

---@param first number
---@param second number
---@param percent number
---@function
function OxyTheBunny:Lerp(first, second, percent)
	return (first + (second - first) * percent)
end

---@param vec1 Vector
---@param vec2 Vector
---@param percent number
---@function
function OxyTheBunny:VecLerp(vec1, vec2, percent)
	return vec1 * (1 - percent) + vec2 * percent
end

---@param value number
---@param min number
---@param max number
---@function
function OxyTheBunny:Clamp(value, min, max)
	-- this is actually faster than math.min(math.max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

---Exists so that random will never have 0 for a seed, which would otherwise crash the game
function OxyTheBunny:Random()
	return max(Random(), 1)
end

---@param percent number
---@param maxvalue number
---@function
function OxyTheBunny:GetPercent(percent, maxvalue)
	if tonumber(percent) and tonumber(maxvalue) then
		return (maxvalue * percent) / 100
	end
	return false
end

---@param num number
---@function
function OxyTheBunny.Round(num)
	return num % 1 >= 0.5 and ceil(num) or floor(num)
end

---@param direction Direction
---@return Vector
---@function
function OxyTheBunny:DirectionToVector(direction)
	direction = direction == -1 and Direction.DOWN or direction
	return Vector(-1, 0):Rotated(90 * direction)
end

---@param vec Vector
function OxyTheBunny:VectorToDirection(vec)
	local angle = vec:GetAngleDegrees()
	if angle < 0 then
		angle = 360 + angle
	end
	return (floor((angle + 45) / 90) - 2) % 4
end

---Takes two 2d vectors and checks them to see if they are equal
---@param vec1 Vector
---@param vec2 Vector
function OxyTheBunny:VectorsAreEqual(vec1, vec2)
	return vec1.X == vec2.X
		and vec1.Y == vec2.Y
end

---@param Range integer range visualised
---@return integer
function OxyTheBunny:CalculateRange(Range)
	return (Range * 2.5) / 100
end

---@param lower? integer
---@param upper? integer
function OxyTheBunny:RandomNum(lower, upper)
	if upper then
		return Mod.GENERIC_RNG:RandomInt((upper - lower) + 1) + lower
	elseif lower then
		return Mod.GENERIC_RNG:RandomInt(lower) + 1
	else
		return Mod.GENERIC_RNG:RandomFloat()
	end
end