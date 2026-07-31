local Mod = OxyTheBunny
local OXY_EID = Mod.EID_Support
local DD = OXY_EID.DynamicDescriptions

local modifiers = {}

local path = "scripts.compatibility.patches.eid.eid_characters.characters_"
local languages = {
	"en_us",
}
local descriptions = {}
for _, language in ipairs(languages) do
	descriptions[language] = Mod.Include(path .. language)(modifiers)
end

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for playerType, data in pairs(desc) do
		allDescData[playerType] = allDescData[playerType] or {}
		if modifiers[playerType] then
			Mod:AddToDictionary(allDescData[playerType], modifiers[playerType])
		end
		allDescData[playerType][lang] = data
	end
end

for playerId, charDescData in pairs(allDescData) do
	for lang, descData in pairs(charDescData) do
		if not DD:IsValidDescription(descData.Description) or DD:ContainsFunction(descData.Description) then
			Mod:Log("Invalid character description for " .. descData.Name, "Language: " .. lang)
		else
			print("awawa")
			EID:addCharacterInfo(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
end
