local Mod = OxyTheBunny

local rocks = Mod:Set({
	GridEntityType.GRID_ROCK,
	GridEntityType.GRID_ROCKB,
	GridEntityType.GRID_ROCKT,
	GridEntityType.GRID_ROCK_BOMB,
	GridEntityType.GRID_ROCK_ALT,
	GridEntityType.GRID_ROCK_SS,
	GridEntityType.GRID_ROCK_SPIKED,
	GridEntityType.GRID_ROCK_ALT2,
	GridEntityType.GRID_ROCK_GOLD,
})

---@param grid GridEntity
---@param chainsaw EntityEffect
local function terraPreHitRock(_, grid, gridIndex, chainsaw)
	local shouldBreakRock = Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_ROCK)
		and chainsaw.CollisionDamage * 0.1 > Mod.GENERIC_RNG:RandomFloat()
	if shouldBreakRock and grid.State ~= 2 and rocks[grid:GetType()] then
		return true
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, terraPreHitRock)

---@param grid GridEntity
---@param chainsaw EntityEffect
local function terraPostHitRock(_, grid, gridIndex, chainsaw)
	if rocks[grid:GetType()] then
		grid:Destroy()
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, terraPostHitRock)
