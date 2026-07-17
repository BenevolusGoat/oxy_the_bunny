local Mod = OxyTheBunny

local OXY = {}

OxyTheBunny.Character.OXY = OXY

OXY.CHARM_COLOR = Color(1, 0, 1, 1, 0.196078)

Mod.Include("scripts.oxy.characters.oxy.holster")
Mod.Include("scripts.oxy.characters.oxy.chainsaw")
Mod.Include("scripts.oxy.characters.oxy.synergy_loader")

---@param player EntityPlayer
function OXY:IsOxy(player)
	return player:GetPlayerType() == Mod.PlayerType.OXY
end

---@param player EntityPlayer
function OXY:OxyHasBirthright(player)
	return OXY:IsOxy(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param player EntityPlayer
---@param tearParams TearParams
function OXY:CharmChance(player, tearParams)
	if not Mod.Item.CHAINSAW:CanUseChainsaw(player) then
		local chance = 1 / math.max(1, 10 - (player.Luck / 3 ) )
		local roll = player:GetCollectibleRNG(Mod.Item.HOLSTER.ID):RandomFloat()
		if roll < chance then
			tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_CHARM)
			tearParams.TearColor = OXY.CHARM_COLOR
			return tearParams
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, OXY.CharmChance, Mod.PlayerType.OXY)
