local Mod = OxyTheBunny

local OXY_B = {}

OxyTheBunny.Character.OXY_B = OXY_B

---@param player EntityPlayer
function OXY_B:IsOxyB(player)
	return player:GetPlayerType() == Mod.PlayerType.OXY_B
end

---@param player EntityPlayer
function OXY_B:OxyBHasBirthright(player)
	return OXY_B:IsOxyB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

Mod.Include("scripts.oxy.characters.oxy_b.specter")
