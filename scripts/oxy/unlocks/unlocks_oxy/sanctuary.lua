local Mod = OxyTheBunny

local SANCTUARY = {}

OxyTheBunny.Item.SANCTUARY = SANCTUARY

SANCTUARY.ID = Isaac.GetItemIdByName("Sanctuary")

---@param slot LevelGeneratorRoom
---@param roomConfig RoomConfigRoom
---@param seed integer
function SANCTUARY:ReplaceSecretRooms(slot, roomConfig, seed)
	if PlayerManager.AnyoneHasCollectible(SANCTUARY.ID) and roomConfig.Type == RoomType.ROOM_SECRET then
		local newRoomConfig = RoomConfig.GetRandomRoom(
			seed,
			true,
			StbType.SPECIAL_ROOMS,
			RoomType.ROOM_SECRET,
			RoomShape.ROOMSHAPE_1x1,
			nil,
			nil,
			nil,
			nil,
			nil,
			55
		)
		if newRoomConfig then
			return newRoomConfig
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, SANCTUARY.ReplaceSecretRooms)