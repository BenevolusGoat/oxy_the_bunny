local Mod = OxyTheBunny
local loader = Mod.PatchesLoader

local function minimapAPIPatch()
	Mod.SaveManager.InitMinimapAPI(MinimapAPI, MinimapAPI.BranchVersion)

	local sprite = Sprite("gfx/ui/oxy_minimap_icons.anm2", true)

	MinimapAPI:AddIcon("SoulOfOxy", sprite, "SoulOfOxy", 0)
	MinimapAPI:AddPickup("SoulOfOxy", "SoulOfOxy", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
		Mod.Card.SOUL_OF_OXY.ID, MinimapAPI.PickupNotCollected, "runes", 11100)

	MinimapAPI:AddIcon("SteelCard", sprite, "SteelCard", 0)
	MinimapAPI:AddPickup("SteelCard", "SteelCard", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
		Mod.Card.STEEL_CARD.ID, MinimapAPI.PickupNotCollected, "cards", 10100)
end

loader:RegisterPatch("MinimapAPI", minimapAPIPatch)
