--#region Variables

local Mod = OxyTheBunny

local LITTLE_OXY = {}

OxyTheBunny.Item.LITTLE_OXY = LITTLE_OXY

LITTLE_OXY.ID = Isaac.GetItemIdByName("Little Oxy")
LITTLE_OXY.FAMILIAR = Isaac.GetEntityVariantByName("Little Oxy")
LITTLE_OXY.FIRE_COOLDOWN = 22 --Sister Maggy's is 22
LITTLE_OXY.CHARM_CHANCE = 0.25
LITTLE_OXY.SHOTSPEED = 10

---@param tear EntityTear
function LITTLE_OXY:FireTear(tear)
	local familiar = tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar()
	if not familiar then return end
	local rng = familiar:GetDropRNG()
	local roll = rng:RandomFloat()

	if roll < LITTLE_OXY.CHARM_CHANCE then
		tear:AddTearFlags(TearFlags.TEAR_CHARM)
		tear:GetSprite().Color = Mod.Character.OXY.CHARM_COLOR
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, LITTLE_OXY.FireTear, LITTLE_OXY.FAMILIAR)

---@param familiar EntityFamiliar
function LITTLE_OXY:OnFamiliarUpdate(familiar)
	familiar:Shoot()
	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LITTLE_OXY.OnFamiliarUpdate, LITTLE_OXY.FAMILIAR)

--#endregion

--#region Familiar setup

---@param familiar EntityFamiliar
function LITTLE_OXY:MakeFollower(familiar)
	familiar:AddToFollowers()
	familiar:GetSprite():Play("FloatDown")
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LITTLE_OXY.MakeFollower, LITTLE_OXY.FAMILIAR)

---@param player EntityPlayer
function LITTLE_OXY:HandleCache(player)
	local num = player:GetCollectibleNum(LITTLE_OXY.ID) +
		player:GetEffects():GetCollectibleEffectNum(LITTLE_OXY.ID)
	local rng = RNG(Mod:Random())

	player:CheckFamiliar(LITTLE_OXY.FAMILIAR, num, rng, Mod.ItemConfig:GetCollectible(LITTLE_OXY.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LITTLE_OXY.HandleCache, CacheFlag.CACHE_FAMILIARS)

Mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, function()
	return FollowerPriority.SHOOTER
end, LITTLE_OXY.FAMILIAR)

--#endregion