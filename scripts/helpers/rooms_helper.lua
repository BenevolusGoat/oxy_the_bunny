function OxyTheBunny:GetRoomDesc()
	return OxyTheBunny.Level():GetCurrentRoomDesc()
end

function OxyTheBunny:IsInStartingRoom(checkHasLeft)
	local level = OxyTheBunny.Level()
	local roomIndex = level:GetCurrentRoomDesc().SafeGridIndex
	local startingRoomIndex = level:GetStartingRoomIndex()

	return roomIndex == startingRoomIndex
		and level:GetStage() == LevelStage.STAGE1_1
		and (not checkHasLeft or OxyTheBunny.Room():IsFirstVisit())
end

---Helper function that calculates what the stage type should be for the provided stage.
---This emulates what the game's internal code does.
---
---Regretfully taken from IsaacScript
---@param stage LevelStage
function OxyTheBunny:CalculateStageType(stage)
	local seeds = OxyTheBunny.Game:GetSeeds()
	local stageSeed = seeds:GetStageSeed(stage)
	if stageSeed % 2 == 0 then
		return StageType.STAGETYPE_WOTL
	end
	if stageSeed % 3 == 0 then
		return StageType.STAGETYPE_AFTERBIRTH
	end
	return StageType.STAGETYPE_ORIGINAL
end

---Helper function that calculates what the Repentance stage type should be for the provided stage.
---This emulates what the game's internal code does.
---
---Regretfully taken from IsaacScript
---@param stage LevelStage
function OxyTheBunny:CalculateStageTypeRepentance(stage)
	if stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
		return StageType.STAGETYPE_REPENTANCE
	end
	local seeds = OxyTheBunny.Game:GetSeeds()
	local stageSeed = seeds:GetStageSeed(stage)
	local halfStageSeed = math.floor(stageSeed / 2)

	if halfStageSeed % 2 == 0 then
		return StageType.STAGETYPE_REPENTANCE_B
	end
	return StageType.STAGETYPE_REPENTANCE
end

---@param cond? fun(room: RoomDescriptor): boolean
---@return RoomDescriptor[]
function OxyTheBunny:GetAllRooms(cond)
	local collectedRooms = {}
	local level = OxyTheBunny.Level()
	local rooms = level:GetRooms()

	for i = 0, #rooms - 1 do
		local room = rooms:Get(i)
		if not cond or cond(room) then
			OxyTheBunny.Insert(collectedRooms, room)
		end
	end
	return collectedRooms
end

---@param count integer
---@param rng RNG
---@param cond? fun(room: RoomDescriptor): boolean
---@return RoomDescriptor[]
function OxyTheBunny:GetRandomRoomsOnFloor(count, rng, cond)
	local roomIndexes = OxyTheBunny:GetAllRooms(cond)
	local randomRooms = {}
	for _ = 1, count do
		local randomRoomDesc = OxyTheBunny:GetDifferentRandomValue(randomRooms, roomIndexes, rng)
		OxyTheBunny.Insert(randomRooms, randomRoomDesc)
	end
	return randomRooms
end

---@param roomDesc RoomDescriptor
function OxyTheBunny:GetRequiredDoors(roomDesc)
	local doors = roomDesc.Data.Doors
	local requiredDoors = 0
	for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		if OxyTheBunny:HasBitFlags(doors, 1 << i) then
			requiredDoors = requiredDoors + 1
		end
	end
	return requiredDoors
end

---Returns if the provided `roomConfigRoom` should be allowed to replace the current `roomDesc`
---
---RoomDescriptor.AllowedDoors contains all present doors, while RoomConfigRoom contains the doors it allows.
---If there's a mismatch, it could potentially lead to a softlock
---@param roomDesc RoomDescriptor
---@param roomConfigRoom RoomConfigRoom
function OxyTheBunny:CanReplaceRoom(roomDesc, roomConfigRoom)
	for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		if OxyTheBunny:HasBitFlags(roomDesc.AllowedDoors, 1 << doorSlot)
			and not OxyTheBunny:HasBitFlags(roomConfigRoom.Doors, 1 << doorSlot)
		then
			return false
		end
	end

	return true
end

---@param secondFloorOnly boolean
function OxyTheBunny:CheckValidPreWombChapter(secondFloorOnly)
	local level = OxyTheBunny.Level()
	local stage = level:GetStage()
	return ((
			stage < LevelStage.STAGE4_1
			and (not secondFloorOnly and stage % 2 ~= 0 or stage % 2 == 0)
		)
		and not level:IsAscent()
		and not OxyTheBunny.Game:IsGreedMode()
	)
end

-- For getting a speicifc group of rooms of the respective difficulty
function OxyTheBunny:GetRoomMode()
	return OxyTheBunny.Game:IsGreedMode() and 1 or 0
end

---@param func fun(doorSlot: GridEntityDoor)
function OxyTheBunny:ForEachDoor(func)
	local room = OxyTheBunny.Room()
	for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(doorSlot)
		if door then
			local result = func(door)
			if result then
				return true
			end
		end
	end
end

---@param func fun(gridEnt: GridEntity, gridIndex: integer)
---@param gridType? GridEntityType
---@param gridVariant? integer
function OxyTheBunny:ForEachGrid(func, gridType, gridVariant)
	local room = OxyTheBunny.Room()
	for i = 0, room:GetGridSize() do
		local gridEntiy = room:GetGridEntity(i)
		if gridEntiy
			and (not gridType or gridEntiy:GetType() == gridType)
			and (not gridVariant or gridEntiy:GetVariant() == gridVariant)
		then
			local result = func(gridEntiy, i)
			if result then
				return true
			end
		end
	end
end
