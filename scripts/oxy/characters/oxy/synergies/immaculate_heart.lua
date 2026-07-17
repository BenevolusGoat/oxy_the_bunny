local Mod = OxyTheBunny

local IMMACULATE_HEART_CHANCE = 0.25

---@param fireDir Vector
---@param fireAmount integer
---@param player EntityPlayer
local function immaculateHeart(_, fireDir, fireAmount, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_IMMACULATE_HEART)
		and fireAmount > 0
		and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IMMACULATE_HEART):RandomFloat() <= IMMACULATE_HEART_CHANCE
	then
		local velocity = Mod:AddTearVelocity(fireDir, player.ShotSpeed * 10)
		local tear = player:FireTear(player.Position, velocity, false, true, false, player, 1)
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_ORBIT_ADVANCED)
		tear.Color = Color(1.5, 2.0, 2.0, 1)
		tear.FallingSpeed = -5.25 + (player.ShotSpeed * 1.5)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, immaculateHeart)