local Mod = OxyTheBunny

local ZIT_CHANCE = 1 / 3

---@param player EntityPlayer
local function largeZit(_, player)
	if Mod.Item.CHAINSAW:CanUseChainsaw(player)
		and Mod:IsShooting(player)
		and player:HasCollectible(CollectibleType.COLLECTIBLE_LARGE_ZIT)
		and Mod.Game:GetFrameCount() % 30 == 0
	then
		local rng = Mod.GENERIC_RNG
		if rng:RandomFloat() < ZIT_CHANCE then
			local dir = Mod:GetAttackDirection(player, false, true)
			player:DoZitEffect(dir)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, largeZit)