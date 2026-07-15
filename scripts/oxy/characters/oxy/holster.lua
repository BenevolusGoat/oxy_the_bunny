local Mod = OxyTheBunny

local HOLSTER = {}

OxyTheBunny.Item.HOLSTER = HOLSTER

HOLSTER.ID = Isaac.GetItemIdByName("Holster")
HOLSTER.CLEARS_NEEDED = 3

---@param rng RNG
---@param player EntityPlayer
function HOLSTER:ToggleChainsawOnUse(_, rng, player)
	local item = Mod.Item.CHAINSAW.ID
	local hasOxySaw = player:GetInnateCollectibleCount(item, "Oxy") > 0
	if hasOxySaw then
		player:RemoveInnateCollectible(item, 1, "Oxy")
	else
		player:AddInnateCollectible(item, 1, "Oxy")
	end
	player:AnimateCollectible(HOLSTER.ID, "HideItem")
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, HOLSTER.ToggleChainsawOnUse, HOLSTER.ID)

---@param ent Entity
---@param flags DamageFlag
---@param source EntityRef
function HOLSTER:ChainsawCooldownOnHit(ent, amount, flags, source, cooldown)
	local player = ent:ToPlayer()
	if player
		and player:GetActiveItem(ActiveSlot.SLOT_POCKET) == HOLSTER.ID
		and not Mod:HasAnyBitFlags(flags, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES)
	then
		Mod:RunSave(player).ChainsawDisabled = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, HOLSTER.ChainsawCooldownOnHit, EntityType.ENTITY_PLAYER)


---@param player EntityPlayer
function HOLSTER:UpdateHolsterCharge(item, player, var, charge)
	local player_run_save = Mod:TryGetRunSave(player)
	if player_run_save and player_run_save.ChainsawDisabled then
		return HOLSTER.CLEARS_NEEDED
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, HOLSTER.UpdateHolsterCharge, HOLSTER.ID)

---@param player EntityPlayer
function HOLSTER:RoomClear(player)
	local player_run_save = Mod:TryGetRunSave(player)
	if player_run_save
		and player_run_save.ChainsawDisabled
		and player:GetActiveItem(ActiveSlot.SLOT_POCKET) == HOLSTER.ID
	then
		player:AddActiveCharge(1, ActiveSlot.SLOT_POCKET, true, false, true)
		if player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == HOLSTER.CLEARS_NEEDED then
			player_run_save.ChainsawDisabled = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, HOLSTER.RoomClear)

---@param player EntityPlayer
function HOLSTER:EnableChainsawOnMaxCharge(player)
	local player_run_save = Mod:TryGetRunSave(player)
	if player_run_save
		and player_run_save.ChainsawDisabled
		and player:GetActiveItem(ActiveSlot.SLOT_POCKET) == HOLSTER.ID
		and player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == HOLSTER.CLEARS_NEEDED
	then
		player_run_save.ChainsawDisabled = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, HOLSTER.EnableChainsawOnMaxCharge)