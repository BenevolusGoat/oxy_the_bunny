local Mod = OxyTheBunny

---@param player EntityPlayer
local function momsKnife(_, player)
	if player:HasWeaponType(WeaponType.WEAPON_KNIFE) then
		return "gfx/effects/weapon_chainsaw_momsknife.png"
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_GET_SKIN, momsKnife)