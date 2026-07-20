local Mod = OxyTheBunny

---@param grid GridEntity
---@param chainsaw EntityEffect
local function sulfuricAcidPreHitRock(_, grid, gridIndex, chainsaw)
	local hasAcid = Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_ACID)
	if grid:ToRock() and hasAcid and grid.State ~= 2 then
		return true
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, sulfuricAcidPreHitRock)

---@param grid GridEntity
---@param chainsaw EntityEffect
local function sulfuricAcidPostHitRock(_, grid, gridIndex, chainsaw)
	if grid:ToRock() then
		grid:Destroy()
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, sulfuricAcidPostHitRock)