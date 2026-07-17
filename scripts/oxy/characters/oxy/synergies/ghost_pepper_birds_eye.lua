---@class ModReference
local Mod = OxyTheBunny

---@param player EntityPlayer
function Mod:TryTriggerFireGhostPepperOrBirdsEye(player)
	local hasBirdsEye = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE)
	local hasGhostPepper = player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
	local hasBoth = hasBirdsEye and hasGhostPepper

	if hasBirdsEye
		or hasGhostPepper
	then
		local rng = hasBirdsEye and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BIRDS_EYE) or
			player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
		local fireToShoot = hasBirdsEye and EffectVariant.RED_CANDLE_FLAME or EffectVariant.BLUE_FLAME
		if hasBoth then
			if rng:RandomInt(2) == 1 then
				fireToShoot = EffectVariant.BLUE_FLAME
			end
		end
		local baseChance = hasBoth and 8 or 12
		local procRate = baseChance - player.Luck
		if procRate < 0 then procRate = 1 end
		local luckChance = 1 / procRate
		local luckCap = baseChance == 8 and 7 or 10

		luckChance = math.abs(player.Luck) <= luckCap and luckChance or 1 / (baseChance - luckCap)

		if rng:RandomFloat() <= luckChance then
			return fireToShoot
		end
	end
end

---@param chainsaw EntityEffect
---@param tearFlags TearFlags
---@param pos Vector
local function ghostPepperBirdsEye(_, chainsaw, tearFlags, pos)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	local fireToShoot = Mod:TryTriggerFireGhostPepperOrBirdsEye(player)
	if fireToShoot then
		local velDir = (pos - chainsaw.Position):Normalized()
		local vel = Mod:AddTearVelocity(velDir, player.ShotSpeed * 13.3, player)
		local fire = Mod.Spawn.Effect(fireToShoot, 0, player.Position, vel, player)
		if fireToShoot == EffectVariant.BLUE_FLAME then
			fire.CollisionDamage = player.Damage * 6
			fire:SetTimeout(60)
			fire.LifeSpan = 60
		elseif fireToShoot == EffectVariant.RED_CANDLE_FLAME then
			fire.CollisionDamage = player.Damage * 4
			fire:SetTimeout(300)
			fire.LifeSpan = 300
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_ON_ARC_PEAK, ghostPepperBirdsEye)
