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
OxyTheBunny.Item.LITTLE_OXY.ACHIEVEMENT = achievement("Little Oxy")
OxyTheBunny.Item.SLEEPYHEAD.ACHIEVEMENT = achievement("Sleepyhead")
OxyTheBunny.Item.BODYSUIT.ACHIEVEMENT = achievement("Bodysuit")
OxyTheBunny.Item.BUNNY_EARS.ACHIEVEMENT = achievement("Bunny Ears")
OxyTheBunny.Item.MUTUS_LIBER.ACHIEVEMENT = achievement("Mutus Liber")
OxyTheBunny.Trinket.TUFT_OF_FUR.ACHIEVEMENT = achievement("Tuft of Fur")
--[[ Mega Satan Unlock Here ]]
--[[ Greed Mode Unlock Here ]]
OxyTheBunny.Item.COUNTERPART.ACHIEVEMENT = achievement("The Counterpart")
OxyTheBunny.Trinket.FOUR_LEAF_CLOVER.ACHIEVEMENT = achievement("Four Leaf Clover")
OxyTheBunny.Item.CHAINSAW.ACHIEVEMENT = achievement("Chainsaw")
--[[ Mother Unlock Here ]]
OxyTheBunny.Item.SANCTUARY.ACHIEVEMENT = achievement("Sanctuary")
OxyTheBunny.Character.OXY_B.ACHIEVEMENT = achievement("The Inhabited")

OxyTheBunny.CompletionMarkToAchievement.OXY = {
	[CompletionType.MOMS_HEART] = Mod.Item.LITTLE_OXY.ACHIEVEMENT,
	[CompletionType.ISAAC] = Mod.Item.SLEEPYHEAD.ACHIEVEMENT,
	[CompletionType.SATAN] = Mod.Item.BODYSUIT.ACHIEVEMENT,
	[CompletionType.BOSS_RUSH] = Mod.Item.BUNNY_EARS.ACHIEVEMENT,
	[CompletionType.BLUE_BABY] = Mod.Item.MUTUS_LIBER.ACHIEVEMENT,
	[CompletionType.LAMB] = Mod.Trinket.TUFT_OF_FUR.ACHIEVEMENT,
	--[CompletionType.MEGA_SATAN] = Mod.Item.MECHANICAL_EYE.ACHIEVEMENT,
	--[CompletionType.ULTRA_GREED] = Mod.Trinket.INFESTED_PENNY.ACHIEVEMENT,
	[CompletionType.HUSH] = Mod.Item.COUNTERPART.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Trinket.FOUR_LEAF_CLOVER.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.CHAINSAW.ACHIEVEMENT,
	--[CompletionType.MOTHER] = Mod.Item.YARN_HEART.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.SANCTUARY.ACHIEVEMENT,
	[CompletionType.TAINTED] = Mod.Character.OXY_B.ACHIEVEMENT
}
OxyTheBunny.PlayerTypeToCompletionTable[Mod.PlayerType.OXY] = Mod.CompletionMarkToAchievement.OXY

--#endregion

--#region Tainted Oxy

OxyTheBunny.Card.SOUL_OF_OXY.ACHIEVEMENT = achievement("Soul of Oxy")
OxyTheBunny.Trinket.PASSAGE.ACHIEVEMENT = achievement("Passage")
OxyTheBunny.Card.STEEL_CARD.ACHIEVEMENT = achievement("Steel Card")
--[[ Greed Mode Unlock Here ]]
OxyTheBunny.Item.MANIFEST.ACHIEVEMENT = achievement("Manifest")
OxyTheBunny.Trinket.WHITE_PETAL.ACHIEVEMENT = achievement("White Petal")
OxyTheBunny.Item.RED_KEYCHAIN.ACHIEVEMENT = achievement("Red Keychain")

OxyTheBunny.CompletionMarkToAchievement.OXY_B = {
	[CompletionType.MEGA_SATAN] = Mod.Card.STEEL_CARD.ACHIEVEMENT,
	--[CompletionType.ULTRA_GREEDIER] = Mod.Card.MERGED_CARD.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.MANIFEST.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Trinket.WHITE_PETAL.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.RED_KEYCHAIN.ACHIEVEMENT,
	[CompletionType.TAINTED_GROUP1] = Mod.Card.SOUL_OF_OXY.ACHIEVEMENT,
	[CompletionType.TAINTED_GROUP2] = Mod.Trinket.PASSAGE.ACHIEVEMENT,
}
OxyTheBunny.PlayerTypeToCompletionTable[Mod.PlayerType.OXY_B] = Mod.CompletionMarkToAchievement.OXY_B

OxyTheBunny.ACHIEVEMENT_COMPLETION = achievement("Oxy Full Completion")

--#endregion
