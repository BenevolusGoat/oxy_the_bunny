local Mod = OxyTheBunny

---@param player EntityPlayer
---@param blindfoldOn boolean
function OxyTheBunny:SetBlindfold(player, blindfoldOn)
	if player:GetEntityConfigPlayer():CanShoot() then
		player:SetCanShoot(not blindfoldOn)
	end
end

---Will attempt to find the player using the attached Entity, EntityRef, or EntityPtr.
---Will return if its a player, the player's familiar, or loop again if it has a SpawnerEntity
---@param ent Entity | EntityRef | EntityPtr
---@param directOnly? boolean @Will not re-call the function if the player can be found through another entity
---@return EntityPlayer?
function OxyTheBunny:TryGetPlayer(ent, directOnly)
	if not ent then return end
	if string.find(getmetatable(ent).__type, "EntityPtr") then
		if ent.Ref then
			return OxyTheBunny:TryGetPlayer(ent.Ref)
		end
	elseif string.find(getmetatable(ent).__type, "EntityRef") then
		if ent.Entity then
			return OxyTheBunny:TryGetPlayer(ent.Entity)
		end
	elseif ent:ToPlayer() then
		return ent:ToPlayer()
	elseif ent:ToFamiliar() and ent:ToFamiliar().Player and not directOnly then
		return ent:ToFamiliar().Player
	elseif ent.SpawnerEntity and not directOnly then
		return OxyTheBunny:TryGetPlayer(ent.SpawnerEntity)
	end
end

-- Returns the actual amount of red hearts the player has, subtracting rotten hearts.
---@param player EntityPlayer
---@param ignoreMods? boolean
---@function
function OxyTheBunny:GetPlayerRealRedHeartsCount(player, ignoreMods)
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use red hearts behind the actual one.
		return CustomHealthAPI.Library.GetHPOfKey(player, "RED_HEART", false, true)
	end

	return player:GetHearts() - player:GetRottenHearts() * 2
end

-- Returns the actual amount of soul hearts the player has, subtracting black hearts.
---@param player EntityPlayer
---@param ignoreMods? boolean
---@function
function OxyTheBunny:GetPlayerRealSoulHeartsCount(player, ignoreMods)
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use soul hearts behind the actual one.
		return CustomHealthAPI.Library.GetHPOfKey(player, "SOUL_HEART", false, false)
	end

	local blackCount = 0
	local soulHearts = player:GetSoulHearts()
	local blackMask = player:GetBlackHearts()

	for i = 1, soulHearts do
		local bit = 2 ^ math.floor((i - 1) / 2)
		if blackMask | bit == blackMask then
			blackCount = blackCount + 1
		end
	end

	return soulHearts - blackCount
end

-- Returns the actual amount of black hearts the player has.
---@param player EntityPlayer
---@param ignoreMods? boolean
---@function
function OxyTheBunny:GetPlayerRealBlackHeartsCount(player, ignoreMods)
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use black hearts behind the actual one (?
		return CustomHealthAPI.Library.GetHPOfKey(player, "BLACK_HEART", false, false)
	end

	local blackCount = 0
	local soulHearts = player:GetSoulHearts()
	local blackMask = player:GetBlackHearts()

	for i = 1, soulHearts do
		local bit = 2 ^ math.floor((i - 1) / 2)
		if blackMask | bit == blackMask then
			blackCount = blackCount + 1
		end
	end

	return blackCount
end

---@param player EntityPlayer
---@param item CollectibleType
---@param includePocket2? boolean
---@return ActiveSlot[]
---Returns a list of all active slots that contain given item.
---@function
function OxyTheBunny:GetActiveItemSlots(player, item, includePocket2)
	local out = {}
	for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
		if player:GetActiveItem(slot) == item then
			if slot ~= ActiveSlot.SLOT_POCKET2 or includePocket2 then
				table.insert(out, slot)
			end
		end
	end
	return out
end

---@param player EntityPlayer
---@return boolean
function OxyTheBunny:IsJudasBirthrightActive(player)
	local playerType = player:GetPlayerType()
	return (playerType == PlayerType.PLAYER_JUDAS or playerType == PlayerType.PLAYER_BLACKJUDAS) and
		player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param player EntityPlayer
---@param item CollectibleType
---@param slot ActiveSlot
---@param charge? integer
---@param replaceItem? CollectibleType
---@function
function OxyTheBunny:SetActiveItem(player, item, slot, charge, replaceItem)
	charge = charge or Mod.itemconfig:GetCollectible(item).MaxCharges

	if replaceItem then
		player:RemoveCollectible(replaceItem, true, slot)
	end

	if slot == ActiveSlot.SLOT_POCKET or slot == ActiveSlot.SLOT_POCKET2 then
		player:SetPocketActiveItem(item, slot)
		player:SetActiveCharge(charge, slot)
	elseif slot == ActiveSlot.SLOT_PRIMARY or slot == ActiveSlot.SLOT_SECONDARY then
		player:AddCollectible(item, charge, false, slot)
	else
		error("Unknown active slot")
	end
end

--[[
--- Returns true if the player has space for an active item, false if he doesn't have space
---@param player EntityPlayer
---@return boolean
function OxyTheBunny:HasSpaceForActive(player)
	return not ((player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG))
		or not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0
		and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
end

---@param player EntityPlayer
---@param pickup EntityPickup
---@return boolean
function OxyTheBunny:CanAffordPrice(player, pickup)
	if pickup.Price == 0
	or pickup.Price == PickupPrice.PRICE_FREE then
		return true
	elseif pickup.Price > 0 then
		return player:GetNumCoins() >= pickup.Price
	else
		if Mod:IsAnyLost(player) then
			return true
		end

		if pickup.Price == PickupPrice.PRICE_ONE_HEART then
			return player:GetMaxHearts() >= 2
		elseif pickup.Price == PickupPrice.PRICE_TWO_HEARTS then
			return player:GetMaxHearts() >= 4
		elseif pickup.Price == PickupPrice.PRICE_THREE_SOULHEARTS then
			return player:GetSoulHearts() >= 6
		elseif pickup.Price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS then
			return (player:GetMaxHearts() >= 2 and player:GetSoulHearts() >= 4) or player:GetMaxHearts() >= 6
		elseif pickup.Price == PickupPrice.PRICE_SOUL then
			return player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL)
		end
	end

	-- Try to check using custom price functions
	local canAfford = Mod.SHOP_ITEMS:CanAffordPickup(player, pickup)
	if canAfford ~= nil then
		return canAfford
	end

	return true -- unknown price, assume true
end

---checks if the player is dying, returns true if true, false if not
---@param player EntityPlayer
---@return boolean
---@function
function OxyTheBunny:IsPlayerDying(player)
	return player:GetSprite():GetAnimation():sub(- #"Death") == "Death" --does their current animation end with "Death"?
end

---@param player EntityPlayer
---@function
function OxyTheBunny:IsUrnOfSoulsActive(player)
	local weapon = player:GetActiveWeaponEntity()
	return weapon
		and weapon.Type == EntityType.ENTITY_EFFECT
		and weapon.Variant == EffectVariant.URN_OF_SOULS
end

---@param player EntityPlayer
function OxyTheBunny:IsNotchedAxeActive(player)
	local weapon = player:GetActiveWeaponEntity()
	return weapon
		and weapon.Type == EntityType.ENTITY_KNIFE
		and weapon.Variant == 9 -- No enum for knife variants (without RGON)
end ]]

---@param itemId CollectibleType
function OxyTheBunny:GetMaxCharges(itemId)
	return Mod.itemconfig:GetCollectible(itemId).MaxCharges
end

--#endregion

--[[ ---@param player EntityPlayer
function OxyTheBunny:GetPrimaryWeaponType(player)
	if not REPENTOGON then return end
	local weapon = player:GetWeapon(1)
	if weapon then return weapon:GetWeaponType() end
end ]]


--- Gives the player's luck accounting for teardrop charm
---@param player EntityPlayer
---@return integer
function OxyTheBunny:GetTearModifierLuck(player)
	local luck = player.Luck
	if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
		luck = luck + (player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM) * 4)
	end
	return luck
end

--[[ ---@param player EntityPlayer
---@param filterFunc fun(val: any, key?: integer): boolean @Filters what collectibles are removed
function OxyTheBunny:EmptyInventory(player, filterFunc)
	local itemlist = Mod:FilterList(OxyTheBunny:GetChronologicalInventory(player), filterFunc)
	inverseiforeach(itemlist, function(itemID)
		player:RemoveCollectible(itemID)
	end)

	player:AddKeys(-player:GetNumKeys())
	player:AddBombs(-player:GetNumBombs())
	player:AddCoins(-player:GetNumCoins())
	player:RemoveGoldenBomb()
	player:RemoveGoldenKey()
	for i = 1, player:GetMaxTrinkets() do
		if player:GetTrinket(i - 1) ~= 0 then
			player:TryRemoveTrinket(player:GetTrinket(i - 1))
		end
	end
	for i = 0, 3 do
		player:DropPocketItem(i, Vector.Zero)
	end
end ]]

---Returns true if the player has enough charge to use the active item in the specified slot
---@param player EntityPlayer
---@param slot ActiveSlot
function OxyTheBunny:CanUseActive(player, slot)
	return player:GetActiveCharge(slot) + player:GetBloodCharge() + player:GetSoulCharge() >= player:GetActiveMinUsableCharge(slot)
end

--[[ ---Returns true if given active is in player's "main" slot (SLOT_PRIMARY or SLOT_POCKET for pocket actives)
---Accounts for player having pills/cards in pocket slots
---@param player EntityPlayer
---@param item CollectibleType
---@param isPocketSlot boolean
function OxyTheBunny:IsActiveInMainSlot(player, item, isPocketSlot)
	if isPocketSlot then
		local pocketItem = player:GetPocketItem(PillCardSlot.PRIMARY)
		return player:GetActiveItem(ActiveSlot.SLOT_POCKET) == item
			and pocketItem:GetType() == PocketItemType.ACTIVE_ITEM
			and (pocketItem:GetSlot() - 1) == ActiveSlot.SLOT_POCKET
	else
		return player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == item
	end
end

---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
function OxyTheBunny:DropCollectibleFromButter(player, flags, slot)
	if player:HasTrinket(TrinketType.TRINKET_BUTTER)
		and Mod:HasBitFlags(flags, UseFlag.USE_OWNED)
		and not Mod:HasBitFlags(flags, UseFlag.USE_MIMIC)
		and (slot == ActiveSlot.SLOT_PRIMARY or slot == ActiveSlot.SLOT_SECONDARY)
	then
		Scheduler.Schedule(1, function()
			local activeItem = player:GetActiveItem(slot)
			local isGolden = Mod:HasGoldenItem(activeItem, player, slot)
			player:DropCollectible(activeItem)
			Mod.Foreach.Pickup(function (pickup, index)
				if pickup.FrameCount == 0
					and pickup.SubType == activeItem
					and isGolden
				then
					Mod.Pickup.GOLDEN_ITEM:TurnPedestalGold(pickup)
					return true
				end
			end, PickupVariant.PICKUP_COLLECTIBLE, nil, {Inverse = true})
		end)
	end
end ]]

local colorToSuffix = {
	[SkinColor.SKIN_PINK] = "",
	[SkinColor.SKIN_WHITE] = "_white",
	[SkinColor.SKIN_BLACK] = "_black",
	[SkinColor.SKIN_BLUE] = "_blue",
	[SkinColor.SKIN_RED] = "_red",
	[SkinColor.SKIN_GREEN] = "_green",
	[SkinColor.SKIN_GREY] = "_grey",
	[SkinColor.SKIN_SHADOW] = "_shadow",
}

---@param player EntityPlayer
---@param isBody? boolean @default: `false`.
function OxyTheBunny:GetPlayerSkinColorSuffix(player, isBody)
	local color
	if isBody then
		color = player:GetBodyColor()
	else
		color = player:GetHeadColor()
	end
	if color == player:GetEntityConfigPlayer():GetSkinColor() then
		return ""
	else
		return Mod:GetSkinColorSuffix(color)
	end
end

---@param color SkinColor
function OxyTheBunny:GetSkinColorSuffix(color)
	return colorToSuffix[color]
end

---@param player EntityPlayer
---@param spriteLayer PlayerSpriteLayer
function OxyTheBunny:TryGetCostumeDesc(player, spriteLayer)
	local costumeSpriteDescs = player:GetCostumeSpriteDescs()
	local costumeLayerMap = player:GetCostumeLayerMap()
	local costumeSpriteDescIndex = costumeLayerMap[spriteLayer + 1].costumeIndex
	return costumeSpriteDescs[costumeSpriteDescIndex + 1]
end

---@param player EntityPlayer
---@param flags UseFlag
function OxyTheBunny:CanSpawnWisp(player, flags)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
		and (not Mod:HasBitFlags(flags, UseFlag.USE_NOANIM) or Mod:HasBitFlags(flags, UseFlag.USE_ALLOWWISPSPAWN))
end

---@param player EntityPlayer
---@param item CollectibleType
function OxyTheBunny:HasBlockedCollectible(player, item)
	return player:HasCollectible(item, true) and not player:HasCurseMistEffect()
end

---@param player EntityPlayer
---@param item CollectibleType
function OxyTheBunny:GetBlockedCollectibleNum(player, item)
	if player:HasCurseMistEffect() then
		return 0
	end
	return player:GetCollectibleNum(item, true)
end

---@param player EntityPlayer
---@param trinket TrinketType
function OxyTheBunny:HasBlockedTrinket(player, trinket)
	return player:HasTrinket(trinket, true) and not player:HasCurseMistEffect()
end

---@param direction Vector
---@param shotSpeed number
---@param player? EntityPlayer
function OxyTheBunny:AddTearVelocity(direction, shotSpeed, player)
	local newDirection = direction:Resized(shotSpeed)

	if player then
		newDirection = newDirection + player:GetTearMovementInheritance(newDirection)
	end
	return newDirection
end