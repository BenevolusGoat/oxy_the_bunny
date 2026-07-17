local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyCricketsBody(_, npc, pos, tearFlags, source, damage, player)
	local tear = player:FireTear(pos, Vector.Zero, false, true, false, source, 1)
	tear:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
	local startingVec = RandomVector():Resized(10)
	for i = 0, 3 do
		tear:FireSplitTear(pos, startingVec:Rotated(i * 90), 0.5, 0.6, tear.Variant, SplitTearType.QUAD)
	end
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyCricketsBody, TearFlags.TEAR_QUADSPLIT)