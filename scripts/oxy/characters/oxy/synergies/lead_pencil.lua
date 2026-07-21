local Mod = OxyTheBunny
local PENCIL_SHOT_THRESHOLD = 15

---@param fireDir Vector
---@param fireAmount integer
---@param player EntityPlayer
---@param numFired integer
local function leadPencil(_, fireDir, fireAmount, player, numFired)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LEAD_PENCIL)
		and fireAmount > 0
	then
		if (numFired % PENCIL_SHOT_THRESHOLD) + fireAmount >= PENCIL_SHOT_THRESHOLD then
			for _ = 1, 12 do
				local angledDir = fireDir:Rotated(Mod:RandomNum(-5, 5))
				local velocity = Mod:AddTearVelocity(angledDir,
					player.ShotSpeed * (Mod:RandomNum(7, 13) + Mod:RandomNum(Mod.GENERIC_RNG)), player)
				local tear = Mod.Spawn.Tear(TearVariant.BLOOD, player.Position, velocity, nil, player)
				tear.FallingSpeed = Mod:RandomNum(-12, 2) - Mod:RandomNum(Mod.GENERIC_RNG)
				tear.FallingAcceleration = 0.5
				local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, -1, player)
				local scale = tearParams.TearScale
				local scaleOffset = Mod:RandomNum(-1, 3) + Mod:RandomNum(Mod.GENERIC_RNG)
				tear.Scale = scale + (scaleOffset * 0.1)
				tear:ResetSpriteScale(true)
			end
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, leadPencil)
