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
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)
	tear:FireSplitTear(pos, Vector(10 * player.ShotSpeed, 0):Rotated(rng:RandomInt(360)), 0.5, 1, tear.Variant, SplitTearType.BONE)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyCricketsBody, TearFlags.TEAR_BONE)