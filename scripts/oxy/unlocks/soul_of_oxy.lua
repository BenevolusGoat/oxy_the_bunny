local Mod = OxyTheBunny

local SOUL_OF_OXY = {}

OxyTheBunny.Pickup.SOUL_OF_OXY = SOUL_OF_OXY

SOUL_OF_OXY.ID = Isaac.GetCardIdByName("Soul of Oxy")

SOUL_OF_OXY.DURATION = 30 * 30 --30 ticks per second * duration

---@param player EntityPlayer
function SOUL_OF_OXY:OnUse(item, rng, player)
	player:AddInnateCollectible(Mod.Item.CHAINSAW.ID, 1, "Soul of Oxy", SOUL_OF_OXY.DURATION)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SOUL_OF_OXY.OnUse)

---@param ent Entity
---@param flags DamageFlag
---@param source EntityRef
function SOUL_OF_OXY:ChainsawCooldownOnHit(ent, amount, flags, source, cooldown)
	local player = ent:ToPlayer()
	if player
		and player:GetInnateCollectibleCount(Mod.Item.CHAINSAW.ID, "Soul of Oxy") > 0
		and not Mod:HasAnyBitFlags(flags, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES)
	then
		player:RemoveInnateCollectible(Mod.Item.CHAINSAW.ID, 1, "Soul of Oxy")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SOUL_OF_OXY.OnTakeDamage, EntityType.ENTITY_PLAYER)