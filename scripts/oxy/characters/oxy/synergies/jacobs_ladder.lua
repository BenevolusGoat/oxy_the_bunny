local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyJacobsLadder(_, npc, pos, tearFlags, source, damage, player)
	Mod.Game:ChainLightning(pos, damage / 2, tearFlags, player)
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyJacobsLadder, TearFlags.TEAR_JACOBS)