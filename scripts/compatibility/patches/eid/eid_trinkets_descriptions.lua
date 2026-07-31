local Mod = OxyTheBunny
local Trinket = Mod.Trinket
local OXY_EID = Mod.EID_Support
local DD = OXY_EID.DynamicDescriptions

local modifiers = {
}

local path = "scripts.compatibility.patches.eid.eid_trinkets.trinkets_"
local languages = {
	"en_us"
}
local descriptions = {}
for _, language in ipairs(languages) do
	descriptions[language] = Mod.Include(path .. language)(modifiers)
end

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for trinketID, data in pairs(desc) do
		allDescData[trinketID] = allDescData[trinketID] or {}
		if modifiers[trinketID] then
			Mod:AddToDictionary(allDescData[trinketID], modifiers[trinketID])
		end
		allDescData[trinketID][lang] = data
	end
end

for id, trinketDescData in pairs(allDescData) do
	for language, descData in pairs(trinketDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid trinket description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not trinketDescData._AppendToEnd then
			EID:addTrinket(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla trinkets that already have one
			if not EID.descriptions[language].trinkets[id] then
				EID:addTrinket(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, trinketDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET, id, language)
		end

		::continue::
	end
end
