---@class ModReference
_G.OxyTheBunny = RegisterMod("Oxy the Bunny", 1)
local Mod = OxyTheBunny

OxyTheBunny.Version = "INDEV"

OxyTheBunny.SaveManager = include("scripts.tools.save_manager")
OxyTheBunny.SaveManager.Init(OxyTheBunny)
OxyTheBunny.Game = Game()
OxyTheBunny.ItemConfig = Isaac.GetItemConfig()
OxyTheBunny.SFXMan = SFXManager()
OxyTheBunny.MusicMan = MusicManager()
OxyTheBunny.HUD = OxyTheBunny.Game:GetHUD()
OxyTheBunny.Room = function() return OxyTheBunny.Game:GetRoom() end
OxyTheBunny.Level = function() return OxyTheBunny.Game:GetLevel() end
OxyTheBunny.PersistGameData = Isaac.GetPersistentGameData()
OxyTheBunny.Font = {
	Terminus = Font(),
	Tempest = Font(),
	Meat10 = Font(),
	Meat16 = Font()
}
OxyTheBunny.Font.Terminus:Load("font/terminus.fnt")
OxyTheBunny.Font.Tempest:Load("font/pftempestasevencondensed.fnt")
OxyTheBunny.Font.Meat10:Load("font/teammeatfont10.fnt")
OxyTheBunny.Font.Meat16:Load("font/teammeatfont16bold.fnt")

OxyTheBunny.GENERIC_RNG = RNG()

OxyTheBunny:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seed = OxyTheBunny.Game:GetSeeds():GetStartSeed()
	OxyTheBunny.GENERIC_RNG:SetSeed(seed)
end)

OxyTheBunny.RANGE_BASE_MULT = 40

include("scripts.helpers.extra_enums")

---@type table[]
local getData = {}

---Slightly faster than calling GetData, a micromanagement at best
---
---However GetData() is wiped on POST_ENTITY_REMOVE, so this also helps retain the data until after entity removal
---@param ent Entity
---@return table
function OxyTheBunny:GetData(ent)
	if not ent then return {} end
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	if not data then
		local newData = {}
		getData[ptrHash] = newData
		data = newData
	end
	return data
end

---@param ent Entity
---@return table?
function OxyTheBunny:TryGetData(ent)
	local ptrHash = GetPtrHash(ent)
	local data = getData[ptrHash]
	return data
end

OxyTheBunny:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE, function(_, ent)
	getData[GetPtrHash(ent)] = nil
end)

OxyTheBunny.FileLoadError = false
OxyTheBunny.InvalidPathError = false

---Mimics include() but with a pcall safety wrapper and appropriate error codes if any are found
---
---VSCode users: Go to Settings > Lua > Runtime:Special and link OxyTheBunny.Include to require, just like you would regular include!
function OxyTheBunny.Include(path)
	Isaac.DebugString("[OxyTheBunny] Loading " .. path)
	local wasLoaded, result = pcall(include, path)
	local errMsg = ""
	local foundError = false
	if not wasLoaded then
		OxyTheBunny.FileLoadError = true
		foundError = true
		errMsg = 'Error in path "' .. path .. '":\n' .. result .. '\n'
	elseif result and type(result) == "string" and string.find(result, "no file '") then
		foundError = true
		OxyTheBunny.InvalidPathError = true
		errMsg = 'Unable to locate file in path "' .. path .. '"\n'
	end
	if foundError then
		OxyTheBunny:Log(errMsg)
	end
	return result
end

function OxyTheBunny.LoopInclude(tab, path)
	for _, fileName in pairs(tab) do
		OxyTheBunny.Include(path .. "." .. fileName)
	end
end

OxyTheBunny.Core = {}
OxyTheBunny.Item = {}
OxyTheBunny.Character = {}
include("flags")

local helpers = {
	"table_functions",
	"saving_system",
	"bitmask_helper",
	"maths_util",
	"misc_util",
	"players_util",
	"familiars_util",
	"string_util",
	"stats_util",
	"tears_util",
	"proximity",
	"npc_util",
	"rooms_helper",
	"pickups_helper",
}

local tools = {
	"debug_tools",
	"hud_helper",
	"status_effect_library",
	"save_manager",
	"pickups_tools"
}

local core = {
	"custom_callbacks"
}

local config = {
	"settings_enum",
	"settings_helper",
	"settings_setup",
	"mcm_setup",
}

OxyTheBunny.Spawn = include("scripts.helpers.spawn")
OxyTheBunny.Foreach = include("scripts.helpers.for_each")

Mod.LoopInclude(helpers, "scripts.helpers")
Dump = include("scripts.helpers.everything_function")
InputHelper = include("scripts.helpers.vendor.inputhelper")
Mod.LoopInclude(tools, "scripts.tools")
Mod.LoopInclude(core, "scripts.oxy.core")
Mod.LoopInclude(config, "scripts.oxy.config")

OxyTheBunny.TearModifier = include("scripts.oxy.core.tear_modifiers")

OxyTheBunny.PlayerType = {
	OXY = Isaac.GetPlayerTypeByName("Oxy", false),
	OXY_B = Isaac.GetPlayerTypeByName("Oxy", true)
}

local characters = {
	"oxy.oxy",
	"oxy_b.oxy_b",
	"tainted_unlock"
}

Mod.LoopInclude(characters, "scripts.oxy.characters")

function OxyTheBunny:RunIDCheck()
	local foundBadID = false
	for _, subTable in pairs(OxyTheBunny) do
		if type(subTable) == "table" then
			for name, itemTable in pairs(subTable) do
				if type(itemTable) == "table" and itemTable.ID and itemTable.ID == -1 then
					print(name, itemTable.ID)
					foundBadID = true
				end
 			end
		end
	end
	if not foundBadID then
		print("No -1 IDs found!")
	end
end

--!End of file

--Mod.Include("scripts.compatibility.patches.eid_support")
Mod.Include("scripts.compatibility.patches_loader")

if Mod.FileLoadError then
	Mod:Log("Mod failed to load! Report this to a coder in the dev server!")
elseif Mod.InvalidPathError then
	Mod:Log("One or more files were unable to be loaded. Report this to a coder in the dev server!")
else
	Mod:Log("v" .. Mod.Version .. " successfully loaded!")
end

OxyTheBunny.Include = nil
OxyTheBunny.LoopInclude = nil