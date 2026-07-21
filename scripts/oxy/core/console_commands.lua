local Mod = OxyTheBunny

--#region Achievement commands

local nameToMark = {
	MomsHeart = CompletionType.MOMS_HEART,
	Isaac = CompletionType.ISAAC,
	Satan = CompletionType.SATAN,
	BossRush = CompletionType.BOSS_RUSH,
	BlueBaby = CompletionType.BLUE_BABY,
	Lamb = CompletionType.LAMB,
	MegaSatan = CompletionType.MEGA_SATAN,
	UltraGreed = CompletionType.ULTRA_GREED,
	Hush = CompletionType.HUSH,
	Delirium = CompletionType.DELIRIUM,
	Mother = CompletionType.MOTHER,
	Beast = CompletionType.BEAST,
}

local function manageAchievements(shouldUnlock)
	local startAch = Mod.Character.OXY.ACHIEVEMENT
	local endAch = Mod.Item.SPECTER.ACHIEVEMENT
	local persistGameData = Isaac.GetPersistentGameData()

	for i = startAch, endAch do
		if shouldUnlock then
			persistGameData:TryUnlock(i, true)
		else
			Isaac.ExecuteCommand("lockachievement " .. i)
		end
	end
end

---@param playerType PlayerType
---@param args string
local function setMarkCommand(playerType, args)
	local strStartAll, strEndAll = string.find(args, "All")
	if strStartAll and strEndAll then
		local value = tonumber(string.sub(args, strEndAll + 2))
		if value and value >= 0 and value <= 2 then
			local marks = Isaac.GetCompletionMarks(playerType)
			for name, _ in pairs(marks) do
				if name ~= "PlayerType" then
					if name == "UltraGreedier" and value == 1 then
						marks[name] = 0
					else
						marks[name] = value
					end
				end
			end
			Isaac.SetCompletionMarks(marks)
		end
		return true
	end
	for name, completionType in pairs(nameToMark) do
		local strStart, strEnd = string.find(args, name)
		if strStart and strEnd then
			local value = tonumber(string.sub(args, strEnd + 2))
			if value and value >= 0 and value <= 2 then
				Isaac.SetCompletionMark(playerType, completionType, value)
				return true
			end
		end
	end
	return false
end

--#endregion

--#region Misc commands

--#endregion

--#region Command setup

local rootCommand = "oxy"

---@type {[1]: string, [2]: string}[]
local commands = {
	{ "unlocktainted",     "Unlocks Tainted Oxy" },
	{ "unlockall",         "Unlocks all mod achievements" },
	{ "lockall",           "Locks all mod achievements" },
	{ "setmark",           "Args: <string completiontype> <int value>. Updates a completion mark for Oxy" },
	{ "setmarktainted",    "Args: <string completiontype> <int value>. Updates a completion mark for Tainted Oxy" },
	{ "clearmarks",        "Clears all completion marks on Oxy" },
	{ "clearmarkstainted", "Clears all completion marks on Tainted Oxy" },
	{ "wipesave",          "Clears all completion marks on both Oxys and locks all achievements" },
	{ "chainsawtest",      "Toggle chainsaw stats between 1. Firerate down, and 2. Damage down, tip damage up. Default: 1" },
}

local helpText = {
	["setmark"] =
		"<completiontype>: [All|MomsHeart|Isaac|Satan|BossRush|BlueBaby|Lamb|MegaSatan|UltraGreed|Hush|Delirium|Mother|Beast]\n"
		.. "<value>: [0: Locked|1: Normal|2: Hard]\n"
		.. "Examples:\n"
		.. "(" .. rootCommand .. " setmark MomsHeart 0) will set the Mom's Heart/It Lives completion mark to Locked.\n"
		.. "(" .. rootCommand .. " setmark Beast 1) will set the Beast completion mark to Normal Mode.\n"
		.. "(" .. rootCommand .. " setmark UltraGreed 2) will set the Greed Mode completion mark to Hard/Greedier Mode."
	,
	["setmarktainted"] = "Arguments are identical to setmark's arguments."
}

---@type {[string]: fun(args: string): string|boolean}
local commandFuncs = {
	["unlocktainted"] = function()
		Isaac.GetPersistentGameData():TryUnlock(Mod.Character.OXY_B.ACHIEVEMENT)
		return "Unlocked Tainted Oxy"
	end,
	["unlockall"] = function()
		manageAchievements(true)
		return "All Oxy achievements unlocked"
	end,
	["lockall"] = function()
		manageAchievements(false)
		return "All Oxy achievements locked"
	end,
	["setmark"] = function(args)
		return setMarkCommand(Mod.PlayerType.OXY, args)
	end,
	["setmarktainted"] = function(args)
		return setMarkCommand(Mod.PlayerType.OXY_B, args)
	end,
	["clearmarks"] = function(args)
		Isaac.ClearCompletionMarks(Mod.PlayerType.OXY)
		return true
	end,
	["clearmarkstainted"] = function(args)
		Isaac.ClearCompletionMarks(Mod.PlayerType.OXY_B)
		return true
	end,
	["wipesave"] = function(args)
		Isaac.ClearCompletionMarks(Mod.PlayerType.OXY)
		Isaac.ClearCompletionMarks(Mod.PlayerType.OXY_B)
		manageAchievements(false)
		return "Save successfully wiped!"
	end,
	["chainsawtest"] = function ()
		---@class table
		local CHAINSAW = Mod.Item.CHAINSAW
		CHAINSAW.CHAINSAW_TEST_MODE = not CHAINSAW.CHAINSAW_TEST_MODE
		if Isaac.IsInGame() then
			Mod.Foreach.Player(function (player, index)
				if player:HasCollectible(CHAINSAW.ID) then
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
				end
			end)
		end
		if CHAINSAW.CHAINSAW_TEST_MODE == true then
			return "Firerate: x1. Damage: x0.65. Tip Damage: x3"
		else
			return "Firerate: x0.33. Damage: x0.85. Tip Damage: x2"
		end
	end
}

local description = "The following commands can be accessed by typing \"arachnaMod <command name>\""
for _, commandTable in ipairs(commands) do
	description = description .. "\n  - " .. commandTable[1] .. " - " .. commandTable[2]
	if helpText[commandTable[1]] then
		description = description .. ".\n" .. helpText[commandTable[1]]
	end
end

Console.RegisterCommand(
	rootCommand,
	"Debug commands for the Oxy MOD",
	description,
	true,
	AutocompleteType.CUSTOM
)

Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
	if cmd ~= rootCommand then
		return
	end
	for _, commandTable in ipairs(commands) do
		local strStart, strEnd = string.find(params, commandTable[1])
		if strStart and strEnd then
			local hasArgs = string.sub(params, strEnd + 1, strEnd + 1) == " "
			local command = string.sub(params, strStart, strEnd + 1)

			if hasArgs and command == commandTable[1] .. " "
				or not hasArgs and command == commandTable[1]
			then
				local args = string.len(commandTable[1]) < string.len(params) and
					string.gsub(params, commandTable[1] .. " ", "") or ""
				local returnPrint = commandFuncs[commandTable[1]](args)
				if type(returnPrint) == "string" then
					Mod:Log(returnPrint)
					return
				elseif returnPrint == true then
					Mod:Log("Ran command successfully!")
					return
				else
					Mod:Log("Failed to run command!")
				end
			end
		end
	end
	Mod:Log("Failed to find valid command!")
end)

Mod:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, function(command, params)
	return commands
end, rootCommand)

--#endregion
