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


---@param player EntityPlayer
---@param tearParams TearParams
function OXY_B:FearEffect(player, tearParams)
	tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_FEAR)
	return tearParams
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, OXY_B.FearEffect, Mod.PlayerType.OXY_B)
