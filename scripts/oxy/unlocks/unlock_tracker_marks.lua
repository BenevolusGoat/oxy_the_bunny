local Mod = OxyTheBunny

---@param playerType PlayerType
---@param completionType CompletionType
function OxyTheBunny:GetAchievement(playerType, completionType)
	local entityConfigPlayer = EntityConfig.GetPlayer(playerType)
	if not entityConfigPlayer then return end
	local completionTable = Mod.PlayerTypeToCompletionTable[playerType]
	if entityConfigPlayer:IsTainted() then
		if (
				completionType == CompletionType.ISAAC
				or completionType == CompletionType.SATAN
				or completionType == CompletionType.LAMB
				or completionType == CompletionType.BLUE_BABY
			)
			and Isaac.AllTaintedCompletion(playerType, TaintedMarksGroup.POLAROID_NEGATIVE) > 0
		then
			return completionTable[CompletionType.TAINTED_GROUP2]
		elseif (completionType == CompletionType.BOSS_RUSH or completionType == CompletionType.HUSH)
			and Isaac.AllTaintedCompletion(playerType, TaintedMarksGroup.SOULSTONE) > 0
		then
			return completionTable[CompletionType.TAINTED_GROUP1]
		elseif completionTable[completionType] then
			return completionTable[completionType]
		end
	elseif completionTable[completionType] then
		return completionTable[completionType]
	end
end

---@param playerType PlayerType
---@param completionType CompletionType
---@return boolean @Returns if unlock was successful.
function OxyTheBunny:TryUnlockCompletionMark(playerType, completionType)
	if Mod.Game:AchievementUnlocksDisallowed() then return false end
	local achievement = Mod:GetAchievement(playerType, completionType)
	if achievement then
		local persistGameData = Isaac.GetPersistentGameData()
		local result = persistGameData:TryUnlock(achievement)

		local completionTable = Mod.PlayerTypeToCompletionTable[playerType]
		if Isaac.AllMarksFilled(playerType) == 2 and completionTable[Mod.CompletionType.ALL] then
			persistGameData:TryUnlock(completionTable[Mod.CompletionType.ALL])
		end
		return result
	end
	return false
end

---@param completionType CompletionType
local function onCompletionEvent(_, completionType)
	if Mod.Game:AchievementUnlocksDisallowed() then return end
	Mod.Foreach.Player(function(player, index)
		local playerType = player:GetPlayerType()
		if not player.Parent and Mod.PlayerTypeToCompletionTable[playerType] then
			Mod:TryUnlockCompletionMark(playerType, completionType)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, onCompletionEvent)
