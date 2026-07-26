local Mod = OxyTheBunny

local WHITE_PETAL = {}

OxyTheBunny.Trinket.WHITE_PETAL = WHITE_PETAL

WHITE_PETAL.ID = Isaac.GetTrinketIdByName("White Petal")

---@param targetIdx integer
---@param dimension Dimension
function WHITE_PETAL:ReplaceAngelRooms(targetIdx, dimension)
	if targetIdx ~= GridRooms.ROOM_DEVIL_IDX then return end
	--Room is initialized by the time the game targets the room to transition into
	local roomDesc = Mod.Level():GetRoomByIdx(targetIdx, dimension)
	if roomDesc.Data.Type == RoomType.ROOM_ANGEL
		and roomDesc.VisitedCount == 0
		and roomDesc.Data.Subtype ~= 55
		and PlayerManager.AnyoneHasTrinket(WHITE_PETAL.ID)
	then
		local newRoomConfig = RoomConfig.GetRandomRoom(
			roomDesc.SpawnSeed,
			true,
			StbType.SPECIAL_ROOMS,
			RoomType.ROOM_ANGEL,
			RoomShape.ROOMSHAPE_1x1,
			nil,
			nil,
			nil,
			nil,
			nil,
			55
		)
		roomDesc.Data = newRoomConfig
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, WHITE_PETAL.ReplaceAngelRooms)