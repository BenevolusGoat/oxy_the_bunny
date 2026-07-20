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
local function sulfuricAcidPreHitRock(_, grid, gridIndex, chainsaw)
	local hasAcid = Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_ACID)
	if hasAcid and grid.State ~= 2 and rocks[grid:GetType()] then
		return true
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, sulfuricAcidPreHitRock)

---@param grid GridEntity
---@param chainsaw EntityEffect
local function sulfuricAcidPostHitRock(_, grid, gridIndex, chainsaw)
	if rocks[grid:GetType()] then
		grid:Destroy()
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, sulfuricAcidPostHitRock)