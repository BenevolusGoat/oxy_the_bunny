local Mod = OxyTheBunny

---@param chainsaw EntityEffect
---@param pos Vector
---@param tearFlags TearFlags
local function applyPop(_, chainsaw, tearFlags, pos)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	local velDir = (pos - chainsaw.Position):Normalized()
	local vel = velDir:Resized(player.ShotSpeed * Mod:RandomNum(5, 7)):Rotated(Mod:RandomNum(-30, 30))
	local tear = Mod.Spawn.Tear(TearVariant.BLUE, pos, vel, tearFlags, player)
	tear:FireSplitTear(pos, vel, 1, 1, TearVariant.EYE, SplitTearType.POP)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_ON_ARC_PEAK, applyPop, TearFlags.TEAR_POP)
