local Mod = OxyTheBunny

local OXY = {}

OxyTheBunny.Character.OXY = OXY

---@param player EntityPlayer
function OXY:IsOxy(player)
	return player:GetPlayerType() == Mod.PlayerType.OXY
end

---@param player EntityPlayer
function OXY:OxyHasBirthright(player)
	return OXY:IsOxy(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

Mod.Include("scripts.oxy.characters.oxy.chainsaw")