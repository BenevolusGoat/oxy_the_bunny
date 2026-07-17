local Mod = OxyTheBunny
local GREED_SHOT_THRESHOLD = 20

---@param fireDir Vector
---@param fireAmount integer
---@param player EntityPlayer
---@param numFired integer
local function eyeOfGreed(_, fireDir, fireAmount, player, numFired)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_GREED)
		and fireAmount > 0
	then
		if (numFired % GREED_SHOT_THRESHOLD) + fireAmount >= GREED_SHOT_THRESHOLD then
			local dmgMult = player:GetNumCoins() > 0 and 1.5 or 1
			local velocity = Mod:AddTearVelocity(fireDir, player.ShotSpeed * 10, player)
			local flags = player.TearFlags
			if player:GetNumCoins() > 0 then
				flags = Mod:AddBitFlags(flags, TearFlags.TEAR_COIN_DROP | TearFlags.TEAR_MIDAS)
				player:AddCoins(-1)
			end
			local tear = Mod.Spawn.Tear(TearVariant.COIN, player.Position, velocity, flags, player)
			tear.CollisionDamage = (player.Damage * dmgMult) + 10
			tear.FallingSpeed = -5.25 + (player.ShotSpeed * 1.5)
			Mod.SFXMan:Play(SoundEffect.SOUND_CASH_REGISTER)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, eyeOfGreed)