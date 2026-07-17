local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyExplosivo(_, npc, pos, tearFlags, source, damage, player)
	local ipecacTear = player:FireTear(pos, Vector.Zero, false, true, false, player, 1)
	ipecacTear:Die() --Immediately explodes and does all the work for me lol
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyExplosivo, TearFlags.TEAR_EXPLOSIVE)