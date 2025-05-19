--Full credit to Epiphany for this easy and flexible EID system

--luacheck: no max line length
-- Markdown guide https://github.com/wofsauge/External-Item-Descriptions/wiki
local Mod = OxyTheBunny
local OXY_EID = {}

OxyTheBunny.EID_Support = OXY_EID

if not EID then
	return
end

local Item = Mod.Item

---@param entity Entity
---@return EntityPlayer
function OXY_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
	if not entity then return EID.player end

	if EID.ClosestPlayerTo then
		return EID:ClosestPlayerTo(entity)
	else
		return EID.player
	end
end

--#region Icons

local player_icons = Sprite("gfx/ui/eid_oxy_players_icon.anm2", true)

local offsetX, offsetY = 2, 1

EID:addIcon("Oxy", "Oxy", 0, 18, 12, offsetX, offsetY, player_icons)
EID:addIcon("OxyB", "OxyB", 0, 18, 12, offsetX, offsetY, player_icons)

-- Assign Player Icons for Birthright
EID.InlineIcons["Player" .. Mod.PlayerType.OXY] = EID.InlineIcons["Oxy"]
EID.InlineIcons["Player" .. Mod.PlayerType.OXY_B] = EID.InlineIcons["OxyB"]

--#endregion

--#region Helper functions

---@function
function OXY_EID:GetTranslatedString(strTable)
	local lang = EID.getLanguage() or "en_us"
	local desc = strTable[lang] or strTable["en_us"] -- default to english description if there's no translation

	if desc == '' then                            --Default to english if the corresponding translation doesn't exist and is blank
		desc = strTable["en_us"];
	end

	return desc
end

--#endregion

--#region Changing mod's name and indicator for EID

EID._currentMod = "Oxy"
EID:setModIndicatorName("Oxy")
local CustomSprite = Sprite()
CustomSprite:Load("gfx/ui/eid_fr_mod_icon.anm2", true)
EID:addIcon("Oxy ModIcon", "Main", 0, 8, 8, 6, 6, CustomSprite)
EID:setModIndicatorIcon("Oxy ModIcon")

--#endregion

--#region Dynamic Descriptions functions

local function containsFunction(tbl)
	for _, v in pairs(tbl) do
		if type(v) == "function" then
			return true
		end
	end
	return false
end

local DynamicDescriptions = {
	[EntityType.ENTITY_PICKUP] = {
		[PickupVariant.PICKUP_COLLECTIBLE] = {},
		[PickupVariant.PICKUP_TAROTCARD] = {},
	}
}

local DD = {} ---@class DynamicDescriptions

---@param descTab table
---@return {Func: fun(descObj: table): (string), AppendToEnd: boolean}
function DD:CreateCallback(descTab, appendToEnd)
	return {
		Func = function(descObj)
			return table.concat(
				Mod:Map(
					descTab,
					function(val)
						if type(val) == "function" then
							local ret = val(descObj)
							if type(ret) == "table" then
								return table.concat(ret, "")
							elseif type(ret) == "string" then
								return ret
							else
								return ""
							end
						end

						return val or ""
					end
				),
				""
			)
		end,
		AppendToEnd = appendToEnd or false
	}
end

---@param modFunc { Func: function } | fun(descObj: table): string
---@param type integer
---@param variant integer
---@param subtype integer
---@param language string
function DD:SetCallback(modFunc, type, variant, subtype, language)
	if not DynamicDescriptions[type] then
		DynamicDescriptions[type] = {}
	end

	if not DynamicDescriptions[type][variant] then
		DynamicDescriptions[type][variant] = {}
	end

	if not DynamicDescriptions[type][variant][subtype] then
		DynamicDescriptions[type][variant][subtype] = {}
	end

	if not DynamicDescriptions[type][variant][subtype][language] then
		DynamicDescriptions[type][variant][subtype][language] = modFunc
	else
		error("Description modifier already exists for " .. type .. " " .. variant .. " " .. subtype .. " " .. language,
			2)
	end
end

---@param type integer
---@param variant integer
---@param subtype integer
---@param language string
---@return {Func: fun(descObj: table): (string?), AppendToEnd: boolean}?
function DD:GetCallback(type, variant, subtype, language)
	if not DynamicDescriptions[type] then
		return nil
	end

	if not DynamicDescriptions[type][variant] then
		return nil
	end

	if not DynamicDescriptions[type][variant][subtype] then
		return nil
	end

	if not DynamicDescriptions[type][variant][subtype][language] then
		return DynamicDescriptions[type][variant][subtype]
			["en_us"] -- fallback to english if no translation is available
	end

	return DynamicDescriptions[type][variant][subtype][language]
end

-- concat all subsequent string elements of a dynamic description
-- into one string so we have to concat less stuff at runtime
--
-- this is very much a micro optimization but at worst it does nothing
---@param desc (string | function)[] | function
---@return (string | function)[]
function DD:MakeMinimizedDescription(desc)
	if type(desc) == "function" then
		return { desc }
	end

	local out = {}
	local builder = {}

	for _, strOrFunc in ipairs(desc) do
		if type(strOrFunc) == "string" then
			builder[#builder + 1] = strOrFunc
		elseif type(strOrFunc) == "function" then
			out[#out + 1] = table.concat(builder, "")
			builder = {}
			out[#out + 1] = strOrFunc
		end
	end

	out[#out + 1] = table.concat(builder, "")

	return out
end

---@param desc (string | function)[] | function
---@return boolean
function DD:IsValidDescription(desc)
	if type(desc) == "function" then
		return true
	elseif type(desc) == "table" then
		for _, val in ipairs(desc) do
			if type(val) ~= "string" and type(val) ~= "function" then
				return false
			end
		end
	end

	return true
end

OXY_EID.DynamicDescriptions = DD

--#endregion

---@param player EntityPlayer
---@param trinketId TrinketType
function OXY_EID:TrinketMulti(player, trinketId)
	local multi = 1
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
		multi = multi + 1
	end
	if Mod:HasBitFlags(trinketId, TrinketType.TRINKET_GOLDEN_FLAG) then
		multi = multi + 1
	end

	return multi
end

---@param multiplier integer
---@param ... string
function OXY_EID:TrinketMultiStr(multiplier, ...)
	return ({ ... })[multiplier] or ""
end

local function trinketMulti(player, trinketId)
	return OXY_EID:TrinketMulti(player, trinketId)
end

local function trinketMultiStr(multiplier, ...)
	return OXY_EID:TrinketMultiStr(multiplier, ...)
end

-- OK means the language's description has been made
-- ! means the description needs to be updated
-- X means the description hasn't been done yet

local EID_Collectibles -- this allows modifier functions defined inside this table to index it without causing an error
EID_Collectibles = {
	[Item.ALTERNATE_REALITY.ID] = {
		en_us = {
			Name = "Alternate Reality",
			Description = {
				"Sends Isaac to a completely random stage with a random stage variant",
				"#Includes any floor from The Basement to The Void, including the alt path"
			}
		},
		ru = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		},
		spa = {
			Name = "PlaceholderName",
			Description = {
				"PlaceholderDesc"
			}
		}
	},
}

EID_Collectibles[Item.POLARITY_SHIFT.ID_2] = EID_Collectibles[Item.POLARITY_SHIFT.ID_1]

for id, collectibleDescData in pairs(EID_Collectibles) do
	for language, descData in pairs(collectibleDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not containsFunction(minimized) and not collectibleDescData._AppendToEnd then
			EID:addCollectible(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla items that already have one
			if not EID.descriptions[language].collectibles[id] then
				EID:addCollectible(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE, id, language)
		end

		::continue::
	end
end

local EID_Characters
EID_Characters = {
	[Mod.PlayerType.OXY] = {
		en_us = {
			Name = "Oxy",
			Description = {
				"???"
			}
		}
	},
	[Mod.PlayerType.OXY_B] = {
		en_us = {
			Name = "Tainted Oxy",
			Description = {
				"???"
			}
		}
	},
}

local EID_Birthrights
EID_Birthrights = {
	[Mod.PlayerType.OXY] = {
		en_us = {
			Name = "Oxy",
			Description = {
				"???"
			}
		}
	},
	[Mod.PlayerType.OXY_B] = {
		en_us = {
			Name = "Tainted Oxy",
			Description = {
				"???"
			}
		}
	},
}

for playerId, brDescData in pairs(EID_Birthrights) do
	for lang, descData in pairs(brDescData) do
		if not DD:IsValidDescription(descData.Description) or containsFunction(descData.Description) then
			Mod:Log("Invalid birthright description for " .. descData.Name, "Language: " .. lang)
		else
			EID:addBirthright(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
end

for playerId, charDescData in pairs(EID_Characters) do
	for lang, descData in pairs(charDescData) do
		if not DD:IsValidDescription(descData.Description) or containsFunction(descData.Description) then
			Mod:Log("Invalid character description for " .. descData.Name, "Language: " .. lang)
		else
			EID:addCharacterInfo(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
end

EID:addDescriptionModifier(
	"OxyTheBunny Dynamic Description Manager",
	-- condition
	---@param descObj EID_DescObj
	function(descObj)
		local subtype = descObj.ObjSubType
		if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
			subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
		elseif descObj.ObjVariant == PickupVariant.PICKUP_PILL then
			subtype = Mod.Game:GetItemPool():GetPillEffect(subtype, OXY_EID:ClosestPlayerTo(descObj.Entity))
		end

		return DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us") ~= nil
	end,
	-- modifier
	function(descObj)
		local subtype = descObj.ObjSubType
		if descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
			subtype = Mod:RemoveBitFlags(subtype, TrinketType.TRINKET_GOLDEN_FLAG)
		elseif descObj.ObjVariant == PickupVariant.PICKUP_PILL then
			subtype = Mod.Game:GetItemPool():GetPillEffect(subtype, OXY_EID:ClosestPlayerTo(descObj.Entity))
		end

		local callback = DD:GetCallback(descObj.ObjType, descObj.ObjVariant, subtype, EID.getLanguage() or "en_us")
		local descString = callback.Func(descObj) ---@diagnostic disable-line: need-check-nil

		if callback.AppendToEnd then ---@diagnostic disable-line: need-check-nil
			descObj.Description = descObj.Description .. descString
		else
			descObj.Description = descString .. descObj.Description
		end

		return descObj
	end
)

EID._currentMod = "OxyTheBunny_reserved" -- to prevent other mods overriding Furtherance mod items
