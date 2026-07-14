local Mod = OxyTheBunny

local CHAINSAW = {}

OxyTheBunny.Item.CHAINSAW = CHAINSAW

CHAINSAW.ID = Isaac.GetItemIdByName("Chainsaw")
CHAINSAW.KNIFE = Isaac.GetEntityVariantByName("Chainsaw")

---@param player EntityPlayer
function CHAINSAW:IsActive(player)
	return false
end
