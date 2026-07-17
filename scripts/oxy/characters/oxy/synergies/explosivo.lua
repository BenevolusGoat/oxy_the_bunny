local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyExplosivo(_, npc, pos, tearFlags, source, damage, player)
	local tear = Mod.Spawn.Tear(TearVariant.BLUE, pos, nil, tearFlags, player)
	tear:FireSplitTear(pos, Vector.Zero, 1, 1, TearVariant.EXPLOSIVO, SplitTearType.STICKY)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyExplosivo, TearFlags.TEAR_STICKY)