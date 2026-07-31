--#region Variables

local Mod = OxyTheBunny

local SLEEPYHEAD = {}

OxyTheBunny.Item.SLEEPYHEAD = SLEEPYHEAD

SLEEPYHEAD.ID = Isaac.GetItemIdByName("Hypersomnia")

SLEEPYHEAD.BLOCKED_STAGES = Mod:Set({
	LevelStage.STAGE4_3, --Blue Womb
	LevelStage.STAGE7, --Void
	LevelStage.STAGE8, --Home
})

--#endregion

--#region Darkness

---@param curses integer
function SLEEPYHEAD:CurseOfDarkness(curses)
	if PlayerManager.AnyoneHasCollectible(SLEEPYHEAD.ID)
		and not Mod.Game:IsGreedMode()
		and not SLEEPYHEAD.BLOCKED_STAGES[Mod.Level():GetStage()]
	then
		return Mod:AddBitFlags(curses, LevelCurse.CURSE_OF_DARKNESS)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, SLEEPYHEAD.CurseOfDarkness)

--#endregion

--#region Sleeping in bed

function SLEEPYHEAD:PostBedSleep()
	if PlayerManager.AnyoneHasCollectible(SLEEPYHEAD.ID) then
		local floor_save = Mod:FloorSave()
		Mod.Level():RemoveCurses(LevelCurse.CURSE_OF_DARKNESS)
		floor_save.BedsSlept = (floor_save.BedsSlept or 0) + 1
		Mod.Foreach.Player(function (player, index)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		end)
	end
end

---@diagnostic disable-next-line: undefined-field
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TRIGGER_BED_SLEEP_EFFECT, CallbackPriority.LATE, SLEEPYHEAD.PostBedSleep)

--#endregion

--#region Damage bonus

---@param player EntityPlayer
---@param value number
function SLEEPYHEAD:DamageBonus(player, stat, value)
	if player:HasCollectible(SLEEPYHEAD.ID) then
		return value + (Mod:FloorSave().BedsSlept or 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, SLEEPYHEAD.DamageBonus, EvaluateStatStage.DAMAGE_UP)

--#endregion

--#region Room Generation (taken from Epiphany's room_gen_helper.lua, which I coded for its rgon rework :) )

local RoomGenHelper = {}

OxyTheBunny.RoomGenHelper = RoomGenHelper
local MAX_ROOM_GEN_ATTEMPTS = 20

--#region Helpers

---Returns the expected variables for allowing multiple doors and special neighbors
---@param roomType RoomType
local function getDefaultValidRoomPlacementArgs(roomType)
	local level = Mod.Level()
	local allowMultipleDoors = roomType == RoomType.ROOM_SECRET
		or roomType == RoomType.ROOM_DEFAULT
		or Mod.Level():GetStage() == LevelStage.STAGE7
	local allowSpecialNeighbors = Mod.Game:IsGreedMode()
	if allowSpecialNeighbors then
		return allowMultipleDoors, allowSpecialNeighbors
	end
	if roomType == RoomType.ROOM_SUPERSECRET then
		allowSpecialNeighbors = false
	elseif roomType == RoomType.ROOM_SECRET or level:GetStage() == LevelStage.STAGE4_3 then
		allowSpecialNeighbors = true
	end
	return allowMultipleDoors, allowSpecialNeighbors
end

function RoomGenHelper:UpdateMinimAPI()
	if MinimapAPI then
		MinimapAPI:CheckForNewRedRooms()
	end
end

---@param listIndex integer
function RoomGenHelper:IsOxyGeneratedRoom(listIndex)
	local floor_save = Mod.SaveManager.TryGetFloorSave()
	return floor_save
		and floor_save.OxyGeneratedIndexes
		and floor_save.OxyGeneratedIndexes[tostring(listIndex)]
end

---Attempts up to 60 times to generate a random room that can be generated on the current floor. 20 attempts per 3 stages:
---
---Stage 1: Allow multiple doors and special neighbors based on room type and gamemode
---
---Stage 2: Always allow multiple doors. Allow special neighbors based on room type and gamemode
---
---Stage 3: Always allow multiple doors and special neighbors
---@param rng RNG
---@param stage StbType The stage the room belongs to.
---@param type RoomType
---@param shape? RoomShape @default: `RoomShape.NUM_ROOMSHAPES` (Any shape).
---@param minVariant? integer @default: `-1`.
---@param maxVariant? integer @default: `-1`
---@param minDifficulty? integer @default: `0.`
---@param maxDifficulty? integer @default: `99.`
---@param requiredDoors? integer @default: `0` (One door on any side). Accepts a DoorMask.
---@param subType? integer @default: `-1`.
---@param mode? integer @default: `-1`.
---@return RoomConfigRoom, boolean
function RoomGenHelper:TryGetValidRandomRoom(rng, stage, type, shape, minVariant, maxVariant, minDifficulty,
											 maxDifficulty, requiredDoors, subType, mode)
	local level = Mod.Level()
	local roomConfig
	local allowMultipleDoors, allowSpecialNeighbors = getDefaultValidRoomPlacementArgs(type)
	local hasValidLocations = false
	local function generateRoom()
		local numTries = 0
		repeat
			roomConfig = RoomConfig.GetRandomRoom(
				rng:Next(),
				false, --Reduce weight
				stage,
				type,
				shape,
				minVariant,
				maxVariant,
				minDifficulty or 0,
				maxDifficulty or 99,
				requiredDoors,
				subType,
				mode
			)
			numTries = numTries + 1
			hasValidLocations = roomConfig and #level:FindValidRoomPlacementLocations(roomConfig, Dimension.CURRENT, allowMultipleDoors, allowSpecialNeighbors) > 0 or false
		until hasValidLocations
			or numTries >= MAX_ROOM_GEN_ATTEMPTS
	end
	generateRoom()
	if hasValidLocations then
		return roomConfig, hasValidLocations
	end
	allowMultipleDoors = true
	generateRoom()
	if hasValidLocations then
		return roomConfig, hasValidLocations
	end
	allowSpecialNeighbors = true
	generateRoom()
	return roomConfig, hasValidLocations
end

---Attempts up to 60 times to generate a room from an array of variants that can be generated on the current floor. 20 attempts per 3 stages:
---
---Stage 1: Allow multiple doors and special neighbors based on room type and gamemode
---
---Stage 2: Always allow multiple doors. Allow special neighbors based on room type and gamemode
---
---Stage 3: Always allow multiple doors and special neighbors
---@param stbType StbType
---@param roomType RoomType
---@param variants integer[]
---@param difficulty? integer @default: `-1`, pulling from all difficulties.
---@return RoomConfigRoom, boolean
function RoomGenHelper:TryGetValidRoomByStbAndVariant(stbType, roomType, variants, difficulty, rng)
	local level = Mod.Level()
	local roomConfig
	local allowMultipleDoors, allowSpecialNeighbors = getDefaultValidRoomPlacementArgs(roomType)
	local hasValidLocations
	local function generateRoom()
		local numTries = 0
		repeat
			roomConfig = RoomConfig.GetRoomByStageTypeAndVariant(stbType, roomType, variants[rng:RandomInt(#variants) + 1], difficulty)
			numTries = numTries + 1
			hasValidLocations = #level:FindValidRoomPlacementLocations(roomConfig, Dimension.CURRENT, allowMultipleDoors, allowSpecialNeighbors) > 0
		until hasValidLocations
			or numTries >= MAX_ROOM_GEN_ATTEMPTS
	end
	generateRoom()
	if hasValidLocations then
		return roomConfig, hasValidLocations
	end
	allowMultipleDoors = true
	generateRoom()
	if hasValidLocations then
		return roomConfig, hasValidLocations
	end
	allowSpecialNeighbors = true
	generateRoom()
	return roomConfig, hasValidLocations
end

--#endregion

--#region Floor RNG

RoomGenHelper.FLOOR_GEN_RNG = RNG(Mod:Random())

local function updateFloorRNG()
	local level = Mod.Game:GetLevel()
	RoomGenHelper.FLOOR_GEN_RNG:SetSeed(level:GetDungeonPlacementSeed())
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, updateFloorRNG)

--#endregion

--#region Adding rooms

---Adds a room of the provided room type to the floor.
---@param roomTypeOrConfig RoomType | RoomConfigRoom
---@return RoomDescriptor?
function RoomGenHelper:AddRoom(roomTypeOrConfig)
	local level = Mod.Game:GetLevel()
	if level:IsAscent() or Mod.Level():GetStage() == LevelStage.STAGE8 then
		return
	end

	local greedMode = Mod.Game:IsGreedMode()
	local dimension = Dimension.CURRENT
	local rng = RoomGenHelper.FLOOR_GEN_RNG
	---@type RoomConfigRoom
	local roomConfig
	local roomType
	local allowMultipleDoors, allowSpecialNeighbors

	if type(roomTypeOrConfig) == "number" then
		local roomSubtype = 0
		---@cast roomTypeOrConfig RoomType
		roomType = roomTypeOrConfig
--[[ 		if RoomGenHelper.RoomTypeToSubtype[roomType] then
			roomSubtype = RoomGenHelper.RoomTypeToSubtype[roomType](rng)
		end ]]

		local stbType = StbType.SPECIAL_ROOMS
--[[ 		if roomType == RoomType.ROOM_DEFAULT then
			stbType = Isaac.GetCurrentStageConfigId()
		end ]]

		local minVariant, maxVariant = -1, -1
--[[ 		if roomType == RoomType.ROOM_CHALLENGE then
			local stageType = level:GetStageType()
			local stage = level:GetStage()
			if (stage == LevelStage.STAGE2_1 or stage == LevelStage.STAGE2_2)
				and stageType >= StageType.STAGETYPE_REPENTANCE
			then
				minVariant = CHALLENGE_VARIANT_MINES_MIN
				maxVariant = CHALLENGE_VARIANT_MINES_MAX
			else
				minVariant = CHALLENGE_VARIANT_REGULAR_MIN
				maxVariant = CHALLENGE_VARIANT_REGULAR_MAX
			end
		end ]]

		local mode = -1 --Automatically pull from the respective gamemode
		if greedMode
			and (roomType == RoomType.ROOM_DEFAULT or roomType == RoomType.ROOM_SHOP)
		then
			mode = 0
			if stbType == 24 or stbType == 25 then
				stbType = StbType.BASEMENT
			end
		end

		allowMultipleDoors, allowSpecialNeighbors = getDefaultValidRoomPlacementArgs(roomType)

		roomConfig = RoomGenHelper:TryGetValidRandomRoom(rng, stbType, roomType, nil, minVariant, maxVariant, nil, nil, nil, roomSubtype, mode)
	else
		---@cast roomTypeOrConfig RoomConfigRoom
		roomConfig = roomTypeOrConfig
		roomType = roomConfig.Type
		allowMultipleDoors, allowSpecialNeighbors = getDefaultValidRoomPlacementArgs(roomType)
	end

	local roomName = Mod:FindInTable(RoomType, roomType)
	if not roomConfig then Mod:DebugLog("Failed to obtain room to generate with type", roomName) return end

	Mod:DebugLog("Attempting spawn for", roomName .. ".", "MultipleDoors:", tostring(allowMultipleDoors) .. ",", "SpecialNeighbors:", allowSpecialNeighbors)

	-- Fetch all valid locations.
	local options = level:FindValidRoomPlacementLocations(roomConfig, dimension, allowMultipleDoors, allowSpecialNeighbors)
	local isSecret = roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET
	Mod:DebugLog("Num available placement options:", #options)

	options = Mod:ShuffleTable(options, rng)
	local preferredSecretNeighbors = 3

	::tryAgain::

	for _, gridIndex in pairs(options) do
		Mod:DebugLog("Searching grid index", gridIndex)
		local invalidSecretNeighbor = false
		local hasSecretNeighbor = false
		local hasNonSecretNeighbor = false
		-- Get the RoomDescriptors of all rooms that would be neighboring the room if placed here.
		local neighbors = level:GetNeighboringRooms(gridIndex, roomConfig.Shape)
		if roomType == RoomType.ROOM_SECRET then
			local numNeighbors = 0
			for _, _ in pairs(neighbors) do
				numNeighbors = numNeighbors + 1
			end
			if numNeighbors < preferredSecretNeighbors then
				Mod:DebugLog("Skipping. Secret with only", numNeighbors, "when searching for at least", preferredSecretNeighbors)
				goto skipOption
			end
		end

		for _, neighborDesc in pairs(neighbors) do
			local neighborType = neighborDesc.Data.Type
			if neighborType == RoomType.ROOM_SECRET then
				hasSecretNeighbor = true
			end
			if neighborType ~= RoomType.ROOM_SECRET and neighborType ~= RoomType.ROOM_SUPERSECRET then
				hasNonSecretNeighbor = true
			end
			if hasSecretNeighbor and not hasNonSecretNeighbor then
				Mod:DebugLog("Invalid neighbor found at", neighborDesc.GridIndex .. ", skip placement (Secret neighbor with no non-secret neighbors).")
				invalidSecretNeighbor = true
				break
			end
			if isSecret and (neighborType == RoomType.ROOM_SECRET)
				or neighborType == RoomType.ROOM_SUPERSECRET
				or neighborType == RoomType.ROOM_ULTRASECRET
				or (greedMode and neighborType == RoomType.ROOM_DEFAULT) --Would block angel/devil otherwise
			then
				Mod:DebugLog("Invalid neighbor found at", neighborDesc.GridIndex .. ", skip placement (Super secret, ultra secret, secret next to secret, or a default room in greed mode).")
				invalidSecretNeighbor = true
				break
			end
		end

		if invalidSecretNeighbor then goto skipOption end

		local seed = rng:Next()
		-- Try to place the room.
		local room = level:TryPlaceRoom(roomConfig, gridIndex, dimension, seed, allowMultipleDoors, allowSpecialNeighbors)
		if room then
			if level:HasMirrorDimension() then
				level:TryPlaceRoom(roomConfig, gridIndex, Dimension.MIRROR, seed, allowMultipleDoors, allowSpecialNeighbors)
			end
			Mod:DebugLog(roomName, "variant", room.Data.OriginalVariant, "generated at index", gridIndex)
			RoomGenHelper:UpdateMinimAPI()
			local floor_save = Mod:FloorSave()
			floor_save.OxyGeneratedIndexes = floor_save.OxyGeneratedIndexes or {}
			floor_save.OxyGeneratedIndexes[tostring(room.ListIndex)] = true
			return room
		end

		::skipOption::
	end
	if roomType == RoomType.ROOM_SECRET and preferredSecretNeighbors > 1 then
		preferredSecretNeighbors = preferredSecretNeighbors - 1
		goto tryAgain
	end
	Mod:DebugLog("Failed to generate", roomName)
end

--#endregion

--#endregion

--#region Spawn Bedroom

function SLEEPYHEAD:OnNewLevel()
	local stage = Mod.Level():GetStage()
	if PlayerManager.AnyoneHasCollectible(SLEEPYHEAD.ID)
		and not Mod.Game:IsGreedMode()
		and not SLEEPYHEAD.BLOCKED_STAGES[stage]
	then
		for i = 1, PlayerManager.GetNumCollectibles(SLEEPYHEAD.ID) do
			RoomGenHelper:AddRoom(RoomType.ROOM_ISAACS)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SLEEPYHEAD.OnNewLevel)

--#endregion

--#region Unlock Bedroom door for free

function SLEEPYHEAD:TryOpenBedroomDoor()
	if PlayerManager.AnyoneHasCollectible(SLEEPYHEAD.ID) then
		Mod.Foreach.Player(function (player, index)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		end)
		Mod.Foreach.Door(function (door, doorSlot)
			local targetIdx = door.TargetRoomIndex
			local listIndex = Mod.Level():GetRoomByIdx(targetIdx).ListIndex
			if door.TargetRoomType == RoomType.ROOM_ISAACS
				and RoomGenHelper:IsOxyGeneratedRoom(listIndex)
				and door:IsLocked()
			then
				door:SetLocked(false)
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SLEEPYHEAD.TryOpenBedroomDoor)

--#endregion