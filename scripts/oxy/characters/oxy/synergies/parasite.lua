local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyParasite(_, npc, pos, tearFlags, source, damage, player)
	local tear = player:FireTear(pos, Vector.Zero, false, true, false, source, 1)
	tear:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
	local velDir = (npc.Position - pos):Normalized()
	local startingVec = velDir:Resized(10)
	tear:FireSplitTear(pos, startingVec, 0.5, 0.6, tear.Variant, SplitTearType.PARASITE)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyParasite, TearFlags.TEAR_SPLIT)