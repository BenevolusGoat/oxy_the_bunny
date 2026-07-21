local Mod = OxyTheBunny
local min = math.min

---@param fireDir Vector
---@param fireAmount integer
---@param player EntityPlayer
local function momsWig(_, fireDir, fireAmount, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_WIG) and fireAmount > 0 then
		--Thanks Nine for this because I'm dumb at math
		local luckChance = min(1, 0.5 + 0.95 * (1 / 2) ^ (10 - player.Luck))
		local rng = Mod.GENERIC_RNG
		local numSpiders = player:GetNumBlueSpiders()

		if numSpiders < 5 and rng:RandomFloat() <= luckChance then
			local target = player.Position + Vector(-50, 50):Rotated(Mod:RandomNum(360))
			player:ThrowBlueSpider(player.Position, target)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, momsWig)
