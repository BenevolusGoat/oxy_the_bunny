local Mod = OxyTheBunny

---@param player EntityPlayer
local function technology(_, player)
	if player:HasWeaponType(WeaponType.WEAPON_LASER) then
		return "gfx/effects/weapon_chainsaw_tech.png"
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_GET_SKIN, technology)

---@param player EntityPlayer
local function techRing(_, _, _, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then

	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, techRing)