local Mod = OxyTheBunny
local OXY_EID = Mod.EID_Support
local DD = OXY_EID.DynamicDescriptions

local modifiers = {
	[Mod.Card.SOUL_OF_OXY.ID] = {
		_metadata = { 6, true }
	},
	[Mod.Card.STEEL_CARD.ID] = {
		_metadata = { 6, false },
	},
}

local path = "scripts.compatibility.patches.eid.eid_cards.cards_"
local languages = {
	"en_us"
}
local descriptions = {}
for _, language in ipairs(languages) do
	descriptions[language] = Mod.Include(path .. language)(modifiers)
end

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for cardID, data in pairs(desc) do
		allDescData[cardID] = allDescData[cardID] or {}
		if modifiers[cardID] then
			Mod:AddToDictionary(allDescData[cardID], modifiers[cardID])
		end
		allDescData[cardID][lang] = data
	end
end

for id, cardDescData in pairs(allDescData) do
	for language, descData in pairs(cardDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local metadata = cardDescData._metadata

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid card description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not cardDescData._AppendToEnd then
			EID:addCard(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla cards that already have one
			if not EID.descriptions[language].cards[id] then
				EID:addCard(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, cardDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TAROTCARD, id, language)
		end

		if metadata then
			EID:addCardMetadata(id, metadata[1], metadata[2])
		end

		::continue::
	end
end
