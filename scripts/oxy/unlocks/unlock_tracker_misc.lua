local Mod = OxyTheBunny

local ACHIEVEMENT_START = Mod.Character.OXY.ACHIEVEMENT
local ACHIEVEMENT_END = Mod.ACHIEVEMENT_COMPLETION - 1

local function onAchievementUnlock(_, achievement)
	if not Mod.PersistGameData:Unlocked(Mod.ACHIEVEMENT_COMPLETION) then
		for ach = ACHIEVEMENT_START, ACHIEVEMENT_END do
			if not Mod.PersistGameData:Unlocked(ach) then
				return
			end
		end

		Mod.PersistGameData:TryUnlock(Mod.ACHIEVEMENT_COMPLETION)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, onAchievementUnlock)

OxyTheBunny.SHARP_TAG = "oxysharp"
local SHARP_ITEMS = {
	CollectibleType.COLLECTIBLE_CUPIDS_ARROW,
	CollectibleType.COLLECTIBLE_THE_NAIL,
	CollectibleType.COLLECTIBLE_MOMS_KNIFE,
	CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER,
	CollectibleType.COLLECTIBLE_SMB_SUPER_FAN,
	CollectibleType.COLLECTIBLE_SHARP_PLUG,
	CollectibleType.COLLECTIBLE_GUILLOTINE,
	CollectibleType.COLLECTIBLE_DEATHS_TOUCH,
	CollectibleType.COLLECTIBLE_8_INCH_NAILS,
	CollectibleType.COLLECTIBLE_BETRAYAL,
	CollectibleType.COLLECTIBLE_SPEAR_OF_DESTINY,
	CollectibleType.COLLECTIBLE_APPLE,
	CollectibleType.COLLECTIBLE_BACKSTABBER,
	CollectibleType.COLLECTIBLE_MOMS_RAZOR,
	CollectibleType.COLLECTIBLE_IT_HURTS,
	CollectibleType.COLLECTIBLE_BLOOD_OATH,
	CollectibleType.COLLECTIBLE_SPIRIT_SWORD,
	CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL,
	CollectibleType.COLLECTIBLE_SANGUINE_BOND,
	CollectibleType.COLLECTIBLE_SAFETY_PIN,
	-- Spun / Drug items. Pointy!
	CollectibleType.COLLECTIBLE_ADRENALINE,
	CollectibleType.COLLECTIBLE_EUTHANASIA,
	CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT,
	CollectibleType.COLLECTIBLE_GROWTH_HORMONES,
	CollectibleType.COLLECTIBLE_ROID_RAGE,
	CollectibleType.COLLECTIBLE_SPEED_BALL,
	CollectibleType.COLLECTIBLE_SPEED_BALL,
	CollectibleType.COLLECTIBLE_SYNTHOIL,
	CollectibleType.COLLECTIBLE_VIRUS
}

for _, item in ipairs(SHARP_ITEMS) do
	Mod.ItemConfig:GetCollectible(item):AddCustomTag(Mod.SHARP_TAG)
end

local function hasSharpTag(item)
	return Mod.ItemConfig:GetCollectible(item):HasCustomTag(Mod.SHARP_TAG)
end

local function onSharpCollectibleAdd(_, item, charge, firstTime, slot, varData, player)
	if hasSharpTag(item) then
		local player_run_save = Mod:RunSave(player)
		player_run_save.SharpItems = (player_run_save.SharpItems or 0) + 1
		if player_run_save.SharpItems == 3 --[[ and not Mod.PersistGameData:Unlocked(Mod.Character.OXY.ACHIEVEMENT) ]] then
			Mod.HUD:ShowItemText("Oxy Unlock", "You WOULD have unlocked Oxy by now!")
			--[[ Mod.PersistGameData:Unlock(Mod.Character.OXY.ACHIEVEMENT) ]]
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, onSharpCollectibleAdd)

local function onSharpCollectibleRemove(_, player, item, removeFromForm, wispOrInnate)
	if hasSharpTag(item) then
		local player_run_save = Mod:RunSave(player)
		player_run_save.SharpItems = math.max(0, (player_run_save.SharpItems or 0) - 1)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, onSharpCollectibleRemove)
