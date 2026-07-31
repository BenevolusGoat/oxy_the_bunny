local Mod = OxyTheBunny
local OXY_EID = Mod.EID_Support
local DD = OXY_EID.DynamicDescriptions
local Item = Mod.Item

---@type {[CollectibleType]: {_modifier: fun(descObj: EID_DescObj, ...: any): any}}
local modifiers = {
}

local path = "scripts.compatibility.patches.eid.eid_items.items_"
local languages = {
	"en_us",
}
local descriptions = {}
for _, language in ipairs(languages) do
	descriptions[language] = Mod.Include(path .. language)(modifiers)
end

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for itemID, data in pairs(desc) do
		allDescData[itemID] = allDescData[itemID] or {}
		if modifiers[itemID] then
			Mod:AddToDictionary(allDescData[itemID], modifiers[itemID])
		end
		allDescData[itemID][lang] = data
	end
end

for id, collectibleDescData in pairs(allDescData) do
	for language, descData in pairs(collectibleDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local fallbackDesc = descData.FallbackDescription

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		if fallbackDesc and not DD:IsValidDescription(fallbackDesc) then
			Mod:Log("Invalid collectible fallback description for " .. name .. " (" .. id .. ")",
				"Language: " .. language)
			fallbackDesc = nil
		end

		OXY_EID:TryAddSynergyDescriptions(id, descData, language)

		local minimized = DD:MakeMinimizedDescription(description)
		local minimizedFallback = fallbackDesc and DD:MakeMinimizedDescription(fallbackDesc)

		if not DD:ContainsFunction(minimized) and not collectibleDescData._AppendToEnd then
			EID:addCollectible(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla items that already have one
			if not EID.descriptions[language].collectibles[id] then
				local desc = minimizedFallback and table.concat(minimizedFallback, "") or ""
				EID:addCollectible(id, desc, name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd, fallbackDesc ~= nil),
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE, id, language)
		end

		::continue::
	end
end
