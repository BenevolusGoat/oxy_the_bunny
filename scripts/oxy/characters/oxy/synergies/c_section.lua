local Mod = OxyTheBunny

--Chance runs every frame the chainsaw is active
local FETUS_CHANCE = 1 / 30

---@param player EntityPlayer \
---@param tear EntityTear \
local function addFlags(player, tear)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS_SWORD
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS_KNIFE
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS_TECHX
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS_TECH
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS_BRIMSTONE
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS_BOMBER
	end

	tear.TearFlags = tear.TearFlags | TearFlags.TEAR_FETUS | TearFlags.TEAR_SPECTRAL
end

---@param chainsaw EntityEffect
local function applyFetus(_, chainsaw)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then return end
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_C_SECTION)
	if rng:RandomFloat() < FETUS_CHANCE then
		local velDir = Mod:GetAttackDirection(player, true, true)
		local vel = Mod:AddTearVelocity(velDir, player.ShotSpeed * Mod:RandomNum(10, 12), player)
		vel = vel:Rotated(Mod:RandomNum(-30, 30))
		local tear = player:FireTear(player.Position, vel, false, false, true, player, 0.75)
		tear.Scale = 1.25
		tear:ChangeVariant(TearVariant.FETUS)
		addFlags(player, tear)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_UPDATE, applyFetus)
