local Mod = OxyTheBunny

local PASSAGE = {}

OxyTheBunny.Trinket.PASSAGE = PASSAGE

PASSAGE.ID = Isaac.GetTrinketIdByName("Passage")

---@param player EntityPlayer
---@param trinket TrinketType
---@param firstTime boolean
function PASSAGE:OnFirstPickup(player, trinket, firstTime)
	if firstTime then
		local itemConfig = Mod.ItemConfig:GetTrinket(PASSAGE.ID)
		player:AddBombs(itemConfig.AddBombs)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, PASSAGE.OnFirstPickup, PASSAGE.ID)

function PASSAGE:OpenDoorsOnSecretEnter()
	local room = Mod.Room()
	if room:GetType() == RoomType.ROOM_SECRET
		and PlayerManager.AnyoneHasTrinket(PASSAGE.ID)
		and room:IsFirstVisit()
	then
		local player = PlayerManager.FirstTrinketOwner(PASSAGE.ID) ---@cast player EntityPlayer
		Mod.Foreach.Door(function (door, doorSlot)
			door:TryBlowOpen(false, player)
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PASSAGE.OpenDoorsOnSecretEnter)