local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyHaemolacria(_, npc, pos, tearFlags, source, damage, player)
	local tear = Mod.Spawn.Tear(TearVariant.BLOOD, pos, nil, tearFlags, player)
	tear:FireSplitTear(pos, Vector.Zero, 1, 1, TearVariant.BLOOD, SplitTearType.BURST)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyHaemolacria, TearFlags.TEAR_BURSTSPLIT)