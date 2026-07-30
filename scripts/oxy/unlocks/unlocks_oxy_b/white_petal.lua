local Mod = OxyTheBunny

local WHITE_PETAL = {}

OxyTheBunny.Trinket.WHITE_PETAL = WHITE_PETAL

WHITE_PETAL.ID = Isaac.GetTrinketIdByName("White Petal")
WHITE_PETAL.ANGEL_CHANCE = 0.2

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
			0,
			0,
			nil,
			500
		)
		roomDesc.Data = newRoomConfig
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, WHITE_PETAL.ReplaceAngelRooms)

function WHITE_PETAL:AddAngelChanceOnNewLevel()
	if PlayerManager.AnyoneHasTrinket(WHITE_PETAL.ID) then
		Mod.Level():AddAngelRoomChance(WHITE_PETAL.ANGEL_CHANCE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WHITE_PETAL.AddAngelChanceOnNewLevel)

function WHITE_PETAL:UpdateAngelChance()
	if PlayerManager.AnyoneHasTrinket(WHITE_PETAL.ID) then
		Mod.Level():AddAngelRoomChance(WHITE_PETAL.ANGEL_CHANCE)
	else
		Mod.Level():AddAngelRoomChance(-WHITE_PETAL.ANGEL_CHANCE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, WHITE_PETAL.UpdateAngelChance, WHITE_PETAL.ID)
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, WHITE_PETAL.UpdateAngelChance, WHITE_PETAL.ID)