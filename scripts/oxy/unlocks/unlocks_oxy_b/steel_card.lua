local Mod = OxyTheBunny

local STEEL_CARD = {}

OxyTheBunny.Card.STEEL_CARD = STEEL_CARD

STEEL_CARD.ID = Isaac.GetCardIdByName("Steel Card")
STEEL_CARD.NULL_ID = Isaac.GetNullItemIdByName("steel card")

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function STEEL_CARD:OnUse(card, player, flags)
	player:AddNullItemEffect(STEEL_CARD.NULL_ID)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, STEEL_CARD.OnUse, STEEL_CARD.ID)