local Mod = OxyTheBunny

local BUNNY_EARS = {}

OxyTheBunny.Item.BUNNY_EARS = BUNNY_EARS

BUNNY_EARS.ID = Isaac.GetItemIdByName("Bunny Ears")

---@param ent Entity
---@param amount integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function BUNNY_EARS:OnTakeDamage(ent, amount, flags, source, countdown)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(BUNNY_EARS.ID) and not Mod.Room():IsClear() then
		player:AddCollectibleEffect(BUNNY_EARS.ID, true)
		Mod.Room():SetBrokenWatchState(1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, BUNNY_EARS.OnTakeDamage, EntityType.ENTITY_PLAYER)