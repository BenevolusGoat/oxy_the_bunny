local Mod = OxyTheBunny

---@param fireDir Vector
---@param fireAmount integer
---@param player EntityPlayer
local function isaacsTears(_, fireDir, fireAmount, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ISAACS_TEARS) and fireAmount > 0 then
		local slots = Mod:GetActiveItemSlots(player, CollectibleType.COLLECTIBLE_ISAACS_TEARS)

		for _, slot in ipairs(slots) do
			player:AddActiveCharge(fireAmount, slot, true, false, true)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, isaacsTears)
