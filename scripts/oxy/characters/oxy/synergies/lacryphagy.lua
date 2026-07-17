local Mod = OxyTheBunny

---@param chainsaw EntityEffect
---@param pos Vector
---@param tearFlags TearFlags
local function applyLacryphagy(_, chainsaw, tearFlags, pos)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	local velDir = (pos - chainsaw.Position):Normalized()
	local vel = velDir:Resized(player.ShotSpeed * 5)
	local tear = Mod.Spawn.Tear(TearVariant.BLUE, pos, vel, tearFlags, player)
	tear:FireSplitTear(pos, vel, 1, 1, TearVariant.HUNGRY, SplitTearType.ABSORB)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_ON_ARC_PEAK, applyLacryphagy, TearFlags.TEAR_ABSORB)