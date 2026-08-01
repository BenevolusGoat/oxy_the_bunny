local Mod = OxyTheBunny

local COSTUMES = {}

OxyTheBunny.HAIR_COSTUMES = COSTUMES

local ANM2_PATH = "gfx/characters/"
local COSTUME_PATH = "gfx/characters/costumes_"

COSTUMES.ItemHairCostumes = {
	[CollectibleType.COLLECTIBLE_DELIRIOUS] = "costume_510_delirious hair.png",
	[CollectibleType.COLLECTIBLE_INFESTATION_2] = "costume_234_infestation2 hair.png",
	[CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES] = "costume_216_ceremonialrobes_hair.png",
	[CollectibleType.COLLECTIBLE_PYROMANIAC] = "costume_223_pyromaniac hair.png",
	[CollectibleType.COLLECTIBLE_HABIT] = "costume_092_habit hair.png",
	[CollectibleType.COLLECTIBLE_NEPTUNUS] = "costume_044x_neptunus_hair.png",
	[CollectibleType.COLLECTIBLE_MR_MEGA] = "costume_046_mrmega hair.png",
	[CollectibleType.COLLECTIBLE_URANUS] = "costume_043x_uranus_hair.png",
}
COSTUMES.NullHairCostumes = {
	[NullItemID.ID_STATUE] = "costume_210_gnawedleaf_statuehair.png"
}

COSTUMES.CostumeInfo = {
	[Mod.PlayerType.OXY] = {
		CostumeConfig = Mod.ItemConfig:GetNullItem(Isaac.GetCostumeIdByPath(ANM2_PATH .. "character_oxy_extra.anm2")),
		CostumePath = "gfx/characters/costumes/character_01_oxy_hair.png",
		Suffix = "oxy"
	},
	[Mod.PlayerType.OXY_B] = {
		CostumeConfig = Mod.ItemConfig:GetNullItem(Isaac.GetCostumeIdByPath(ANM2_PATH .. "character_oxy_b_extra.anm2")),
		CostumePath = "gfx/characters/costumes/character_01b_oxy_hair.png",
		Suffix = "oxy_b"
	}
}

---@param itemConfig ItemConfigItem
function COSTUMES:HasSpecialHairCostume(itemConfig)
	return (
		(itemConfig:IsCollectible() and COSTUMES.ItemHairCostumes[itemConfig.ID])
		or (itemConfig:IsNull() and COSTUMES.NullHairCostumes[itemConfig.ID])
	)
end

---@param player EntityPlayer
function COSTUMES:GetHairCostumeSprite(player)
	local playerType = player:GetPlayerType()
	local costume_info = COSTUMES.CostumeInfo[playerType]
	if not player:IsItemCostumeVisible(costume_info.CostumeConfig, PlayerSpriteLayer.SPRITE_HEAD0) then return end
	local costumeSpriteDescs = player:GetCostumeSpriteDescs()
	local costumeLayerMap = player:GetCostumeLayerMap()
	local costumeSpriteDescIndex = costumeLayerMap[PlayerSpriteLayer.SPRITE_HEAD0 + 1].costumeIndex
	local sprite = costumeSpriteDescs[costumeSpriteDescIndex + 1]:GetSprite()
	return sprite
end

---@param player EntityPlayer
---@param costumeSpriteDesc? CostumeSpriteDesc @Pass `nil` to reset hair costume to default.
function COSTUMES:TryUpdateHairCostume(player, costumeSpriteDesc)
	local playerType = player:GetPlayerType()
	local costume_info = COSTUMES.CostumeInfo[playerType]
	local sprite = COSTUMES:GetHairCostumeSprite(player)
	if not sprite then return end
	local hairPath = costume_info.CostumePath
	local data = Mod:GetData(player)
	if (not costumeSpriteDesc
		or not COSTUMES:HasSpecialHairCostume(costumeSpriteDesc:GetItemConfig()))
	then
		if data.OXY_HasSpecialHairCostume then
			data.OXY_HasSpecialHairCostume = false
			sprite:ReplaceSpritesheet(0, hairPath, true)
			sprite:ReplaceSpritesheet(1, hairPath, true)
			Mod:DebugLog("Hair costume updated to", hairPath)
		end
		return
	end
	local itemConfig = costumeSpriteDesc:GetItemConfig()
	local headLayer = costumeSpriteDesc:GetSprite():GetLayer("head")
	if not headLayer then return end
	local itemTable = itemConfig:IsNull() and COSTUMES.NullHairCostumes or COSTUMES.ItemHairCostumes
	local hairCostume = itemTable and itemTable[itemConfig.ID]
	if not hairCostume then return end
	local playerConfig = player:GetEntityConfigPlayer()
	local suffix = playerConfig:GetCostumeSuffix()
	local suffixPath = COSTUME_PATH .. suffix .. "/"
	local itemCostumePath = suffixPath .. hairCostume
	sprite:ReplaceSpritesheet(0, itemCostumePath, true)
	sprite:ReplaceSpritesheet(1, itemCostumePath, true)
	Mod:DebugLog("Hair costume updated to", itemCostumePath)
	data.OXY_HasSpecialHairCostume = true
end

---@param itemConfig ItemConfigItem
---@param player EntityPlayer
---@param fromOnAdd boolean @Normally this is just "ItemStateOnly" from MC_POST_PLAYER_ADD_COSTUME, but it doesn't get passed under REMOVE, so its a handy "On Add" detection
function COSTUMES:UpdateCostumesOnAddAndRemove(itemConfig, player, fromOnAdd)
	if not Mod:IsAnyOxy(player)
		or Mod.Game:GetFrameCount() == 0
	then
		return
	end
	local layerMap = player:GetCostumeLayerMap()
	local data = Mod:GetData(player)

	local headCostumeIndex = layerMap[PlayerSpriteLayer.SPRITE_HEAD + 1]
	--All costumes removed. Revert to default
	if headCostumeIndex.costumeIndex == -1 then
		if data.OXY_HasHeadCostume then
			COSTUMES:TryUpdateHairCostume(player)
			data.OXY_HasHeadCostume = false
		end
	--It's a head costume, added or removed. Update to expected costume!
	elseif Sprite(itemConfig.Costume.Anm2Path):GetLayer("head") then
		local costumeDescs = player:GetCostumeSpriteDescs()
		local headSpriteDesc = costumeDescs[headCostumeIndex.costumeIndex + 1]
		COSTUMES:TryUpdateHairCostume(player, headSpriteDesc)
		data.OXY_HasHeadCostume = true
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_COSTUME, COSTUMES.UpdateCostumesOnAddAndRemove)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_REMOVE_COSTUME, COSTUMES.UpdateCostumesOnAddAndRemove)

---@param player EntityPlayer
---@param itemConfigItem ItemConfigItem
function COSTUMES:ShouldRemoveCostume(player, itemConfigItem)
	local sprite = Sprite(itemConfigItem.Costume.Anm2Path)
	local headLayer, bodyLayer = sprite:GetLayer("head"), sprite:GetLayer("body")
	if itemConfigItem:IsNull() and itemConfigItem.ID == player:GetEntityConfigPlayer():GetCostumeID() then return end
	local name = COSTUMES.CostumeInfo[player:GetPlayerType()].Suffix

	if headLayer then
		local spritePathHead = headLayer:GetSpritesheetPath()
		if not spritePathHead:find("costumes_" .. name) then
			return true
		end
	end
	if bodyLayer then
		local spritePathBody = bodyLayer:GetSpritesheetPath()
		if not spritePathBody:find("costumes_" .. name) then
			return true
		end
	end

	return false
end

---@param itemConfigItem ItemConfigItem
---@param player EntityPlayer
function COSTUMES:RemoveIncompatibleCostumes(itemConfigItem, player)
	if Mod:IsAnyOxy(player)
		and not itemConfigItem.Costume.IsFlying --Permit flying costumes
		and COSTUMES:ShouldRemoveCostume(player, itemConfigItem)
	then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_COSTUME, COSTUMES.RemoveIncompatibleCostumes)