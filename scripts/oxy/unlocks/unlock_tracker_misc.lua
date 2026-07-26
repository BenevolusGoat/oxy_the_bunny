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
	if achievement == Mod.Character.OXY_B.ACHIEVEMENT
		and not Mod.PersistGameData:Unlocked(Mod.Item.SPECTER.ACHIEVEMENT)
	then
		Mod.PersistGameData:TryUnlock(Mod.Item.SPECTER.ACHIEVEMENT)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, onAchievementUnlock)
