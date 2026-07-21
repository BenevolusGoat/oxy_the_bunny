local Mod = OxyTheBunny

local function achievement(str)
	return Isaac.GetAchievementIdByName(str)
end

---@alias CompletionTable {[CompletionType|ArachnaCompletionType]: Achievement}

---@type {[string]: CompletionTable}
OxyTheBunny.CompletionMarkToAchievement = {}

---@type {[PlayerType]: CompletionTable}
OxyTheBunny.PlayerTypeToCompletionTable = {}

---@enum ArachnaCompletionType
OxyTheBunny.CompletionType = {
	ALL = 18
}

--#region Oxy

OxyTheBunny.Character.OXY.ACHIEVEMENT = achievement("Oxy")
OxyTheBunny.Item.CHAINSAW.ACHIEVEMENT = achievement("Chainsaw")
OxyTheBunny.Character.OXY_B.ACHIEVEMENT = achievement("The Inhabited")

OxyTheBunny.CompletionMarkToAchievement.OXY = {
	--[CompletionType.MOMS_HEART] = Mod.Pickup.WEB_HEART.ACHIEVEMENT,
	--[CompletionType.ISAAC] = Mod.Item.ARACHNAS_SPOOL.ACHIEVEMENT,
	--[CompletionType.SATAN] = Mod.Item.YARN.ACHIEVEMENT,
	--[CompletionType.BOSS_RUSH] = Mod.Item.GEPTAMERON.ACHIEVEMENT,
	--[CompletionType.BLUE_BABY] = Mod.Trinket.WHITE_STRING.ACHIEVEMENT,
	--[CompletionType.LAMB] = Mod.Item.GLASSES_3D.ACHIEVEMENT,
	--[CompletionType.MEGA_SATAN] = Mod.Item.MECHANICAL_EYE.ACHIEVEMENT,
	--[CompletionType.ULTRA_GREED] = Mod.Trinket.INFESTED_PENNY.ACHIEVEMENT,
	--[CompletionType.HUSH] = Mod.Item.ARACHNIDS_GRIP.ACHIEVEMENT,
	--[CompletionType.ULTRA_GREEDIER] = Mod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.CHAINSAW.ACHIEVEMENT,
	--[CompletionType.MOTHER] = Mod.Item.YARN_HEART.ACHIEVEMENT,
	--[CompletionType.BEAST] = Mod.Item.TESTAMENT.ACHIEVEMENT,
	[CompletionType.TAINTED] = Mod.Character.OXY_B.ACHIEVEMENT,
	--[Mod.CompletionType.ALL] = Mod.Item.LIL_ARACHNA.ACHIEVEMENT
}
OxyTheBunny.PlayerTypeToCompletionTable[Mod.PlayerType.OXY] = Mod.CompletionMarkToAchievement.OXY

--#endregion

--#region Tainted Oxy

OxyTheBunny.Item.SPECTER.ACHIEVEMENT = achievement("Specter")
OxyTheBunny.Item.MANIFEST.ACHIEVEMENT = achievement("Manifest")
OxyTheBunny.Card.SOUL_OF_OXY.ACHIEVEMENT = achievement("Soul of Oxy")
--[[
OxyTheBunny.Trinket.SPINDLE.ACHIEVEMENT = achievement("Spindle")
OxyTheBunny.Slot.SPIDER_BEGGAR.ACHIEVEMENT = achievement("Spider Beggar")
OxyTheBunny.Card.MERGED_CARD.ACHIEVEMENT = achievement("Merged Card")
OxyTheBunny.Item.DIVINE_CLOTH.ACHIEVEMENT = achievement("Divine Cloth")
OxyTheBunny.Item.DADS_NEWSPAPER.ACHIEVEMENT = achievement("Dad's Newspaper")
OxyTheBunny.Item.BEST_BUD_BALL.ACHIEVEMENT = achievement("Best Bud Ball") ]]

OxyTheBunny.CompletionMarkToAchievement.OXY_B = {
	--[CompletionType.MEGA_SATAN] = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT,
	--[CompletionType.ULTRA_GREEDIER] = Mod.Card.MERGED_CARD.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.SPECTER.ACHIEVEMENT,
	--[CompletionType.MOTHER] = Mod.Item.DADS_NEWSPAPER.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.MANIFEST.ACHIEVEMENT,
	[CompletionType.TAINTED_GROUP1] = Mod.Card.SOUL_OF_OXY.ACHIEVEMENT,
	--[CompletionType.TAINTED_GROUP2] = Mod.Trinket.SPINDLE.ACHIEVEMENT,
}
OxyTheBunny.PlayerTypeToCompletionTable[Mod.PlayerType.OXY_B] = Mod.CompletionMarkToAchievement.OXY_B

--#endregion

--#region Entity replacements

--[[ Mod:RegisterReplacementEntity({
	OldType = { EntityType.ENTITY_SLOT },
	OldVariant = { SlotVariant.BEGGAR, SlotVariant.KEY_MASTER },
	NewType = EntityType.ENTITY_SLOT,
	NewVariant = Mod.Slot.SPIDER_BEGGAR.ID,
	ReplacementChance = Mod.Slot.SPIDER_BEGGAR.REPLACEMENT_CHANCE,
	Achievement = Mod.Slot.SPIDER_BEGGAR.ACHIEVEMENT
})

Mod:RegisterReplacementEntity({
	OldType = { EntityType.ENTITY_SHOPKEEPER },
	OldVariant = { 0, 1, 3, 4 }, --Normal/Hanging Keepers and their Special variants
	NewType = EntityType.ENTITY_SHOPKEEPER,
	NewVariant = Mod.Entities.GOLDEN_SHOPKEEPER.ID,
	ReplacementChance = Mod.Entities.GOLDEN_SHOPKEEPER.REPLACEMENT_CHANCE,
	Achievement = Mod.Entities.GOLDEN_SHOPKEEPER.ACHIEVEMENT
})

Mod:RegisterReplacementPickup({
	OldVariant = { PickupVariant.PICKUP_HEART },
	OldSubtype = { HeartSubType.HEART_BLACK, HeartSubType.HEART_BLENDED, HeartSubType.HEART_BONE, HeartSubType.HEART_ROTTEN },
	NewVariant = PickupVariant.PICKUP_HEART,
	NewSubtype = function(rng, subtype)
		if rng:RandomFloat() < Mod.Pickup.WEB_HEART.DOUBLE_REPLACEMENT_CHANCE then
			return Mod.Pickup.WEB_HEART.ID_DOUBLE
		else
			return Mod.Pickup.WEB_HEART.ID
		end
	end,
	ReplacementChance = function()
		local chance = Mod.Pickup.WEB_HEART.REPLACEMENT_CHANCE
		chance = chance + Mod.Trinket.SPINDLE.WEB_HEART_REPLACEMENT_BONUS * PlayerManager.GetTotalTrinketMultiplier(Mod.Trinket.SPINDLE.ID)
		return chance
	end,
	Achievement = Mod.Pickup.WEB_HEART.ACHIEVEMENT
}) ]]

--#endregion
