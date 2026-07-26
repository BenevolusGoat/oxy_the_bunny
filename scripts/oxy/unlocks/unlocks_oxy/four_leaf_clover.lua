--#region Variables

local Mod = OxyTheBunny

local FOUR_LEAF_CLOVER = {}

OxyTheBunny.Trinket.FOUR_LEAF_CLOVER = FOUR_LEAF_CLOVER

FOUR_LEAF_CLOVER.ID = Isaac.GetTrinketIdByName("Four Leaf Clover")

local BOSS_RUSH_PAR_TIME = 36000
local BOSS_RUSH_PAR_TIME_ALT = 45000
local BLUE_WOMB_PAR_TIME = 54000

FOUR_LEAF_CLOVER.TROLL_BOMBS = Mod:Set({
	BombVariant.BOMB_TROLL,
	BombVariant.BOMB_SUPERTROLL,
	BombVariant.BOMB_HOT,
	BombVariant.BOMB_GOLDENTROLL
})

local teleportActive = false

--#endregion

--#region Teleport special rooms only

---@return RoomDescriptor[]
function FOUR_LEAF_CLOVER:GetSpecialRooms(currentRoomIdx)
	local collectedRooms = {}
	local level = Mod.Level()
	local rooms = level:GetRooms()
	local dim = level:GetDimension()

	for i = 0, #rooms - 1 do
		local roomDesc = rooms:Get(i)
		if roomDesc.Data.Type ~= RoomType.ROOM_ULTRASECRET
			and roomDesc.Data.Type ~= RoomType.ROOM_DEFAULT
			and roomDesc.ListIndex ~= currentRoomIdx
			and roomDesc:GetDimension() == dim
		then
			Mod.Insert(collectedRooms, roomDesc)
		end
	end
	return collectedRooms
end

function FOUR_LEAF_CLOVER:OnTeleportUse()
	if PlayerManager.AnyoneHasTrinket(FOUR_LEAF_CLOVER.ID) then
		teleportActive = true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.LATE, FOUR_LEAF_CLOVER.OnTeleportUse, CollectibleType.COLLECTIBLE_TELEPORT)

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	teleportActive = false
end)

function FOUR_LEAF_CLOVER:RandomIdx(roomIndex, iAmErorr, seed)
	if teleportActive then
		local rooms = FOUR_LEAF_CLOVER:GetSpecialRooms(Mod.Level():GetCurrentRoomDesc().ListIndex)
		if #rooms == 0 then return end
		local rng = RNG(seed)
		local room = rooms[rng:RandomInt(#rooms) + 1]
		teleportActive = false
		return room.GridIndex
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_GET_RANDOM_ROOM_INDEX, CallbackPriority.EARLY, FOUR_LEAF_CLOVER.RandomIdx)

--#endregion

--#region New Par Times

function FOUR_LEAF_CLOVER:UpdateParTimes()
	local game = Mod.Game
	local hasTrinket = PlayerManager.AnyoneHasTrinket(FOUR_LEAF_CLOVER.ID)
	local isAltPath = Mod.Level():GetStageType() >= StageType.STAGETYPE_REPENTANCE
	local BOSS_RUSH_PAR_TIME_MODIFIED = isAltPath and BOSS_RUSH_PAR_TIME_ALT or BOSS_RUSH_PAR_TIME
	if hasTrinket
		and (
			game.BossRushParTime < BOSS_RUSH_PAR_TIME_MODIFIED * 2
		or game.BlueWombParTime < BLUE_WOMB_PAR_TIME * 2
	)
	then
		game.BossRushParTime = BOSS_RUSH_PAR_TIME_MODIFIED * 2
		game.BlueWombParTime = BLUE_WOMB_PAR_TIME * 2
	elseif not hasTrinket
		and (
			game.BossRushParTime >= BOSS_RUSH_PAR_TIME_MODIFIED * 2
		or game.BlueWombParTime >= BLUE_WOMB_PAR_TIME * 2
	)
	then
		game.BossRushParTime = BOSS_RUSH_PAR_TIME_MODIFIED
		game.BlueWombParTime = BLUE_WOMB_PAR_TIME
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, FOUR_LEAF_CLOVER.UpdateParTimes, FOUR_LEAF_CLOVER.ID)
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, FOUR_LEAF_CLOVER.UpdateParTimes, FOUR_LEAF_CLOVER.ID)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, FOUR_LEAF_CLOVER.UpdateParTimes)

--#endregion

--#region No Troll Bombs

---@param bomb EntityBomb
function FOUR_LEAF_CLOVER:RemoveTrollBombs(bomb)
	if PlayerManager.AnyoneHasTrinket(FOUR_LEAF_CLOVER.ID)
		and bomb.SpawnerType ~= EntityType.ENTITY_PLAYER
		and FOUR_LEAF_CLOVER.TROLL_BOMBS[bomb.Variant]
	then
		bomb:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, FOUR_LEAF_CLOVER.RemoveTrollBombs)

--#endregion