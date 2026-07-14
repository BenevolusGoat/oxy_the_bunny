local Mod = OxyTheBunny

OxyTheBunny.TECHNICAL_ITEMS = Mod:Set({
	CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE,
	CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE,
	CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
})

---@param itemID CollectibleType
---@return boolean
function OxyTheBunny:IsTechnicalPassive(itemID)
	return OxyTheBunny.TECHNICAL_ITEMS[itemID] ~= nil
end

---Returns a dictionary of all passive items and how any of the item the player has.
---@param player EntityPlayer
---@return {[CollectibleType]: integer}
function OxyTheBunny:GetPassiveItemDict(player)
	local ret = player:GetCollectiblesList()
	for itemID = #ret, 1, -1 do
		local numItem = ret[itemID]
		local item = Mod.ItemConfig:GetCollectible(itemID)
		if not item
			or item.Type == ItemType.ITEM_ACTIVE
			or numItem == 0
			or Mod:IsTechnicalPassive(itemID)
		then
			ret[itemID] = nil
		end
	end

	return ret
end

---Returns a dictionary of all items and how any of the item the player has.
---@param player EntityPlayer
---@return {[CollectibleType]: integer}
---@function
function OxyTheBunny:GetItemDict(player)
	local ret = player:GetCollectiblesList()
	for itemID = #ret, 1, -1 do
		local numItem = ret[itemID]
		if numItem == 0 then
			ret[itemID] = nil
		end
	end

	return ret
end

---Returns true if the item is a quest item, Tainted Forgtten's Recall, or Tainted ???'s Hold
---@param itemId CollectibleType
---@function
function OxyTheBunny:IsQuestItem(itemId)
	local config = Mod.ItemConfig
	local itemCfg = config:GetCollectible(itemId)

	return itemCfg and itemCfg:HasTags(ItemConfig.TAG_QUEST)
	or itemId == CollectibleType.COLLECTIBLE_RECALL
	or itemId == CollectibleType.COLLECTIBLE_HOLD
end

-- A set of items that give nothing but an HP up
OxyTheBunny.BASIC_HP_UPS = Mod:Set({
	CollectibleType.COLLECTIBLE_HEART,
	CollectibleType.COLLECTIBLE_SNACK,
	CollectibleType.COLLECTIBLE_BREAKFAST,
	CollectibleType.COLLECTIBLE_DESSERT,
	CollectibleType.COLLECTIBLE_DINNER,
	CollectibleType.COLLECTIBLE_LUNCH,
	CollectibleType.COLLECTIBLE_ROTTEN_MEAT,
	CollectibleType.COLLECTIBLE_MIDNIGHT_SNACK,
	CollectibleType.COLLECTIBLE_SUPPER,
	CollectibleType.COLLECTIBLE_MAGIC_SCAB,
	CollectibleType.COLLECTIBLE_CRACK_JACKS,
	CollectibleType.COLLECTIBLE_STEM_CELLS,
})

-- Get every item that gives nothing but an HP up
---@param item CollectibleType
---@function
function OxyTheBunny:IsBasicHpUp(item)
	return OxyTheBunny.BASIC_HP_UPS[item] ~= nil
end

---Returns true if item with given id is an active item
---@param id CollectibleType
---@return boolean
---@function
function OxyTheBunny:IsActiveItem(id)
	local config = Mod.ItemConfig
	local cfg = config:GetCollectible(id)
	return cfg and cfg.Type == ItemType.ITEM_ACTIVE
end

---Returns the Quality of the Collectible
---@param ID CollectibleType
---@return integer
---@function
function OxyTheBunny:GetItemQuality(ID)
	return Mod.ItemConfig:GetCollectible(ID).Quality
end

---@param id Card
---@return string
---@function
function OxyTheBunny:GetCardName(id)
	return Mod:TryGetTranslatedString(StringTableCategory.POCKET_ITEMS, Mod.ItemConfig:GetCard(id).Name)
end

---@param id PillEffect
---@return string
---@function
function OxyTheBunny:GetPillEffectName(id)
	return Mod:TryGetTranslatedString(StringTableCategory.POCKET_ITEMS, Mod.ItemConfig:GetPillEffect(id).Name)
end

---@param id CollectibleType
---@return string
---@function
function OxyTheBunny:GetCollectibleName(id)
	return Mod:TryGetTranslatedString(StringTableCategory.ITEMS, Mod.ItemConfig:GetCollectible(id).Name)
end

---@param id TrinketType
---@return string
function OxyTheBunny:GetTrinketName(id)
	return Mod:TryGetTranslatedString(StringTableCategory.ITEMS, Mod.ItemConfig:GetTrinket(id).Name)
end

---@type fun(player: EntityPlayer)[]
local voidOutcomes = {
	function (player)
		player:SetSpeedModifier(player:GetSpeedModifier() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		Mod:DebugLog("Void: Rolled +0.2 speed")
	end,
	function (player)
		player:SetFireDelayModifier(player:GetFireDelayModifier() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		Mod:DebugLog("Void: Rolled +0.5 fire delay")
	end,
	function (player)
		player:SetDamageModifier(player:GetDamageModifier() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		Mod:DebugLog("Void: Rolled +1 damage")
	end,
	function (player)
		player:SetTearRangeModifier(player:GetTearRangeModifier() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		Mod:DebugLog("Void: Rolled +2.5 range")
	end,
	function (player)
		player:SetShotSpeedModifier(player:GetShotSpeedModifier() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		Mod:DebugLog("Void: Rolled +2 shot speed")
	end,
	function (player)
		player:SetLuckModifier(player:GetLuckModifier() + 1)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		Mod:DebugLog("Void: Rolled +1 luck")
	end,
}

---@param player EntityPlayer
---@param rng? RNG
---@param count integer? @default: `2`
function OxyTheBunny:GrantVoidStats(player, rng, count)
	--Void grants 2 random stats but not the same ones. For non-active goldens, grant another 2 random.
	local indexRolls = { 1,2,3,4,5,6 }
	rng = rng or player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_VOID)
	count = count or 2
	for _ = 1, count do
		local roll = rng:RandomInt(#indexRolls) + 1
		voidOutcomes[indexRolls[roll]](player)
		table.remove(indexRolls, roll)
	end
	player:EvaluateItems()
end