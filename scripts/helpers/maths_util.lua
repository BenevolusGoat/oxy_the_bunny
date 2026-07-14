local Mod = OxyTheBunny

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

---@param rng RNG
---@function
function OxyTheBunny:RandomNormal(rng)
	local radius = math.sqrt(math.max(0, -2.0 * math.log(1e-6 + rng:RandomFloat())))
	local angle = rng:RandomFloat() * 2.0 * math.pi
	return Vector(math.cos(angle), math.sin(angle)) * radius
end

---Exists so that random will never have 0 for a seed, which would otherwise crash the game
function OxyTheBunny:Random()
	return math.max(Random(), 1)
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
	return num % 1 >= 0.5 and math.ceil(num) or math.floor(num)
end

---@function
function OxyTheBunny:RandomFloatRange(range)
	return Mod.GENERIC_RNG:RandomFloat() * (range or 1.0)
end

---@param direction Direction
---@return Vector
---@function
function OxyTheBunny:DirectionToVector(direction)
	direction = direction == -1 and Direction.DOWN or direction
	return Vector(-1, 0):Rotated(90 * direction)
end

---Takes two 2d vectors and checks them to see if they are equal
---@param vec1 Vector
---@param vec2 Vector
function OxyTheBunny:VectorsAreEqual(vec1, vec2)
	return vec1.X == vec2.X
		and vec1.Y == vec2.Y
end

---@param color Color
---@param alpha number
function OxyTheBunny:ColorChangeAlpha(color, alpha)
	color.A = alpha
	return color
end

---@param Range integer range visualised
---@return integer
function OxyTheBunny:CalculateRange(Range)
	return (Range * 2.5) / 100
end

---@param startPoint Vector
---@param controlPoint Vector
---@param endPoint Vector
---@param t number @Must be in range [0, 1]
---@return Vector
function OxyTheBunny:QuadraticBezier(startPoint, controlPoint, endPoint, t)
	return (1 - t) ^ 2 * startPoint + 2 * (1 - t) * t * controlPoint + t ^ 2 * endPoint
end

---@param rng RNG
---@param lower? integer
---@param upper? integer
function OxyTheBunny:RandomNum(rng, lower, upper)
	if upper then
		return rng:RandomInt((upper - lower) + 1) + lower
	elseif lower then
		return rng:RandomInt(lower) + 1
	else
		return rng:RandomFloat()
	end
end

---@param vec Vector
---@return Direction
function OxyTheBunny:GetRoundedDirection(vec)
	if vec.X == 0 and vec.Y == 0 then
		return Direction.DOWN
	end
	local angle = vec:Normalized():GetAngleDegrees()
	if angle < 0 then
		angle = 360 + angle
	end
	local degrees = {
		0,
		90,
		180,
		270,
		360
	}
	local closestAngle
	local closestSubtraction
	for _, degree in ipairs(degrees) do
		if not closestAngle or math.abs(angle - degree) < closestSubtraction then
			closestSubtraction = math.abs(angle - degree)
			closestAngle = degree
		end
	end
	if closestAngle == 360 then
		closestAngle = 0
	end
	local dirAngles = {
		[0] = Direction.RIGHT,
		[90] = Direction.DOWN,
		[180] = Direction.LEFT,
		[270] = Direction.UP,
	}

	return dirAngles[closestAngle]
end
