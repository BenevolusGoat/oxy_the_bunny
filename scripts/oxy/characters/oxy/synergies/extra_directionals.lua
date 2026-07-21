local Mod = OxyTheBunny

---@param player EntityPlayer
---@param multiShotParams MultiShotParams
local function extraDirections(_, player, multiShotParams)
	local directions = {}
	if multiShotParams:IsShootingSideways() then
		for i = 1, 2 do
			local rotationOffset = i == 1 and 90 or -90
			Mod.Insert(directions, rotationOffset)
		end
	end
	if multiShotParams:IsShootingBackwards() then
		local rotationOffset = 180
		Mod.Insert(directions, rotationOffset)
	end
	if multiShotParams:GetNumRandomDirTears() > 0 then
		for _ = 1, multiShotParams:GetNumRandomDirTears() do
			local rotationOffset = Mod:RandomNum(360)
			Mod.Insert(directions, rotationOffset)
		end
	end
	return directions
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_GET_EXTRA_SAWS, extraDirections)