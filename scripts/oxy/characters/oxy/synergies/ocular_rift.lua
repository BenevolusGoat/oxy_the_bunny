local Mod = OxyTheBunny

---@param chainsaw EntityEffect
---@param pos Vector
---@param tearFlags TearFlags
local function applyOcularRift(_, chainsaw, tearFlags, pos)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	local rift = Mod.Spawn.Effect(EffectVariant.RIFT, 0, pos, nil, player)
	rift:SetTimeout(60)
	rift.CollisionDamage = chainsaw.CollisionDamage / 2
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_ON_ARC_PEAK, applyOcularRift, TearFlags.TEAR_RIFT)