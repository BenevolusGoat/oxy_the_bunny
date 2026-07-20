local Mod = OxyTheBunny

---@param grid GridEntity
---@param chainsaw EntityEffect
local function terraPreHitRock(_, grid, gridIndex, chainsaw)
	local shouldBreakRock = Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_ROCK)
		and chainsaw.CollisionDamage * 0.1 > Mod.GENERIC_RNG:RandomFloat()
	if grid:ToRock() and shouldBreakRock and grid.State ~= 2 then
		return true
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, terraPreHitRock)

---@param grid GridEntity
---@param chainsaw EntityEffect
local function terraPostHitRock(_, grid, gridIndex, chainsaw)
	if grid:ToRock() then
		grid:Destroy()
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, terraPostHitRock)
