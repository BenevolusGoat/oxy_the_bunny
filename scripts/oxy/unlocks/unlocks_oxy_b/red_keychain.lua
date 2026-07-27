--#region Variables

local Mod = OxyTheBunny
local min = math.min
local max = math.max

local RED_KEYCHAIN = {}

OxyTheBunny.Item.RED_KEYCHAIN = RED_KEYCHAIN

RED_KEYCHAIN.ID = Isaac.GetItemIdByName("Red Keychain")
RED_KEYCHAIN.FAMILIAR = Isaac.GetEntityVariantByName("Red Keychain")

local selectedDoors = {}

--Maximum number of keys expected on Red Keychain
RED_KEYCHAIN.MAX_KEYS = 5
--How long you need to press against the door outline to unlock it. 30 = 1 second
RED_KEYCHAIN.DOOR_COLLISION_TIME = 30
--Speed of the key animation
RED_KEYCHAIN.PLAYBACK_SPEED = 0.85
--How many tiles out to detect a Red Door outline relative to the player. 40 = 1 Tile
RED_KEYCHAIN.DETECTION_RANGE = 120
--Color of poof when losing a key
RED_KEYCHAIN.POOF_COLOR = Color(151 / 255,35 / 255, 35 / 255)

--#endregion

--#region Helpers

---@param familiar EntityFamiliar
function RED_KEYCHAIN:GetNumKeys(familiar)
	return familiar.Keys
end

---@param familiar EntityFamiliar
---@param num integer
function RED_KEYCHAIN:AddKeys(familiar, num)
	Mod:DebugLog("Added", num, "keys to Red Keychain", familiar.InitSeed)
	familiar.Keys = familiar.Keys + num
	familiar:GetSprite():Play("FloatDown" .. Mod:Clamp(familiar.Keys, 1, RED_KEYCHAIN.MAX_KEYS))
	if num < 0 then
		local poof = Mod.Spawn.Poof01(0, familiar.Position, familiar)
		poof.Color = RED_KEYCHAIN.POOF_COLOR
	end
	if familiar.Keys <= 0 then
		local player = familiar.Player
		Mod:DebugLog("Keys expended! Removing keychain...")
		RED_KEYCHAIN:SetRemovedKeychains(player, RED_KEYCHAIN:GetRemovedKeychains(player) + 1)
	end
end

---@param player EntityPlayer
function RED_KEYCHAIN:TryGetKeychain(player)
	return Mod.Foreach.Familiar(function(_familiar, index)
		if GetPtrHash(_familiar.Player) == GetPtrHash(player) then
			return _familiar
		end
	end, RED_KEYCHAIN.FAMILIAR)
end

---@param player EntityPlayer
function RED_KEYCHAIN:AddInnateRedKey(player)
	player:AddInnateCollectible(CollectibleType.COLLECTIBLE_RED_KEY, 1, "Red Keychain")
	Mod:DebugLog("Added innate Red Key")
end

---@param player EntityPlayer
function RED_KEYCHAIN:HasInnateRedKey(player)
	return player:GetInnateCollectibleCount(CollectibleType.COLLECTIBLE_RED_KEY, "Red Keychain") > 0
end

---@param player EntityPlayer
function RED_KEYCHAIN:RemoveInnateRedKey(player)
	Mod:DebugLog("Removed innate Red Key")
	return player:RemoveInnateCollectible(CollectibleType.COLLECTIBLE_RED_KEY, 1, "Red Keychain")
end

---@param player EntityPlayer
function RED_KEYCHAIN:GetRemovedKeychains(player)
	local player_run_save = Mod:TryGetRunSave(player)
	return player_run_save and player_run_save.KeychainsRemoved or 0
end

---@param player EntityPlayer
---@param num integer
function RED_KEYCHAIN:SetRemovedKeychains(player, num)
	local player_run_save = Mod:RunSave(player)
	player_run_save.KeychainsRemoved = num
	player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
	Mod:DebugLog("Number of removed keychains set to", num)
end

---@param ent Entity | Vector
---@param offset Vector
---@param ignoreShake? boolean
function RED_KEYCHAIN:GetEntityRenderPosition(ent, offset, ignoreShake)
	local pos
	if getmetatable(ent).__type == "Vector" then
		---@cast ent Vector
		pos = ent
	else
		---@cast ent Entity
		pos = ent.Position + ent.PositionOffset
		if ent:ToPlayer() and Mod.Room():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
			---@cast ent EntityPlayer
			pos = pos + ent:GetFlyingOffset()
		end
	end
	local renderPos = Isaac.WorldToRenderPosition(pos) + offset
	if ignoreShake then
		renderPos = renderPos - Mod.Game.ScreenShakeOffset
	end
	return renderPos
end

---@param player EntityPlayer
---@return Entity
local function tryGetDoorOutlineTarget(player)
	local data = Mod:GetData(player)
	---@type EntityPtr
	local closestDoor = data.ClosestDoorOutline
	return closestDoor and closestDoor.Ref
end

---@param player EntityPlayer
local function tryRemoveDoorOutlineTarget(player)
	local closestDoor = tryGetDoorOutlineTarget(player)
	if closestDoor then
		local data = Mod:GetData(player)
		local ptrHash = GetPtrHash(closestDoor)
		if selectedDoors[ptrHash] then
			selectedDoors[ptrHash].ShouldRender = false
		end
		data.ClosestDoorOutline = nil
	end
end

---@param doorOutline EntityEffect
local function setDoorLockData(doorOutline)
	local spr = Sprite("gfx/door_redkeychain.anm2", true)
	spr:SetFrame("KeyClosed", 0)
	spr.Rotation = doorOutline:GetSprite().Rotation
	spr.Offset = doorOutline:GetSprite().Offset
	spr.Color.A = 0
	spr.PlaybackSpeed = RED_KEYCHAIN.PLAYBACK_SPEED
	return {Sprite = spr, ShouldRender = true}
end

--#endregion

--#region Familiar setup

---@param familiar EntityFamiliar
function RED_KEYCHAIN:MakeFollower(familiar)
	familiar:AddToFollowers()
	familiar:GetSprite():Play("FloatDown" .. 5)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, RED_KEYCHAIN.MakeFollower, RED_KEYCHAIN.FAMILIAR)

---@param familiar EntityFamiliar
function RED_KEYCHAIN:OnFamiliarUpdate(familiar)
	local data = Mod:GetData(familiar)
	if not data.InitAnimation then
		local numKeys = RED_KEYCHAIN:GetNumKeys(familiar)
		if numKeys == 0 then
			RED_KEYCHAIN:AddKeys(familiar, RED_KEYCHAIN.MAX_KEYS)
			numKeys = RED_KEYCHAIN.MAX_KEYS
		end
		familiar:GetSprite():Play("FloatDown" .. numKeys)
		data.InitAnimation = true
	end
	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, RED_KEYCHAIN.OnFamiliarUpdate, RED_KEYCHAIN.FAMILIAR)

---@param player EntityPlayer
function RED_KEYCHAIN:HandleCache(player)
	local num = player:GetCollectibleNum(RED_KEYCHAIN.ID)
		+ player:GetEffects():GetCollectibleEffectNum(RED_KEYCHAIN.ID)
		- RED_KEYCHAIN:GetRemovedKeychains(player)
	local rng = RNG(Mod:Random())
	player:CheckFamiliar(RED_KEYCHAIN.FAMILIAR, num, rng, Mod.ItemConfig:GetCollectible(RED_KEYCHAIN.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RED_KEYCHAIN.HandleCache, CacheFlag.CACHE_FAMILIARS)

--#endregion

--#region Detect collision with wall that has the door target

---@param player EntityPlayer
---@param gridIndex integer
---@param gridEnt GridEntity?
function RED_KEYCHAIN:DetectPlayerAgainstDoor(player, gridIndex, gridEnt)
	if player:HasCollectible(RED_KEYCHAIN.ID)
		and gridEnt
		and gridEnt:GetType() == GridEntityType.GRID_WALL
	then
		local room = Mod.Room()
		local doorOutline = tryGetDoorOutlineTarget(player)
		if doorOutline
			and room:GetGridIndex(doorOutline.Position) == gridIndex
		then
			local data = Mod:GetData(player)
			data.CollidingOnDoorOutline = true
			data.DoorOutlineIndex = gridIndex
			return true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GRID_COLLISION, RED_KEYCHAIN.DetectPlayerAgainstDoor, PlayerVariant.PLAYER)

--#endregion

--#region Peffect Update

--#region Innate red key

---@param player EntityPlayer
function RED_KEYCHAIN:HandleInnateKey(player, hasKeychain)
	local hasKey = RED_KEYCHAIN:HasInnateRedKey(player)
	if hasKeychain and not hasKey then
		RED_KEYCHAIN:AddInnateRedKey(player)
	elseif not hasKeychain and hasKey then
		RED_KEYCHAIN:RemoveInnateRedKey(player)
	end
end

--#endregion

--#region Set closest door outline as target

---@param player EntityPlayer
function RED_KEYCHAIN:MarkNearestDoor(player, hasKeychain)
	if not player:HasCollectible(RED_KEYCHAIN.ID)
		or not hasKeychain
	then
		tryRemoveDoorOutlineTarget(player)
		return
	end
	local closestDoorOutline
	Mod.Foreach.EffectInRadius(player.Position, RED_KEYCHAIN.DETECTION_RANGE, function(door, index)
		if not closestDoorOutline
			or door.Position:DistanceSquared(player.Position) < closestDoorOutline.Position:DistanceSquared(player.Position)
		then
			closestDoorOutline = door
		end
	end, EffectVariant.DOOR_OUTLINE)
	if not closestDoorOutline then
		tryRemoveDoorOutlineTarget(player)
		return
	end
	local data = Mod:GetData(player)
	local lastTargetedDoor = tryGetDoorOutlineTarget(player)
	if not lastTargetedDoor then
		data.ClosestDoorOutline = EntityPtr(closestDoorOutline)
		selectedDoors[GetPtrHash(closestDoorOutline)] = setDoorLockData(closestDoorOutline)
		lastTargetedDoor = closestDoorOutline
	end
	if GetPtrHash(closestDoorOutline) ~= GetPtrHash(lastTargetedDoor) then
		data.ClosestDoorOutline:SetReference(closestDoorOutline)
		selectedDoors[GetPtrHash(closestDoorOutline)] = setDoorLockData(closestDoorOutline)
		selectedDoors[GetPtrHash(lastTargetedDoor)] = nil
	end
	if data.CollidingOnDoorOutline then
		selectedDoors[GetPtrHash(closestDoorOutline)].Sprite:Play("KeyOpen")
	else
		selectedDoors[GetPtrHash(closestDoorOutline)].Sprite:SetFrame("KeyClosed", 0)
	end
end

--#endregion

--#region Increment timer for opening door

---@param player EntityPlayer
function RED_KEYCHAIN:UpdateCollisionTime(player)

	local data = Mod:GetData(player)
	if data.CollidingOnDoorOutline then
		data.DoorOutlineCollisionTime = (data.DoorOutlineCollisionTime or 0) + 1
		if data.DoorOutlineCollisionTime == RED_KEYCHAIN.DOOR_COLLISION_TIME then
			local gridIndex = data.DoorOutlineIndex
			local room = Mod.Room()
			for _, doorSlot in pairs(DoorSlot) do
				local slotPos = room:GetDoorSlotPosition(doorSlot)
				local indexPos = room:GetGridPosition(gridIndex)
				if slotPos.X == indexPos.X and slotPos.Y == indexPos.Y then
					RED_KEYCHAIN:OpenDoor(player, doorSlot)
					return true
				end
			end
		end
	elseif data.DoorOutlineCollisionTime then
		data.DoorOutlineCollisionTime = nil
		data.DoorOutlineIndex = nil
	end
	data.CollidingOnDoorOutline = false
end

--#endregion

---@param player EntityPlayer
function RED_KEYCHAIN:OnPeffectUpdate(player)
	local hasKeychain = RED_KEYCHAIN:TryGetKeychain(player) ~= nil
	RED_KEYCHAIN:HandleInnateKey(player, hasKeychain)
	RED_KEYCHAIN:MarkNearestDoor(player, hasKeychain)
	RED_KEYCHAIN:UpdateCollisionTime(player)
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, RED_KEYCHAIN.OnPeffectUpdate)

--#endregion

--#region Reset door stuff

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	selectedDoors = {}
	Mod.Foreach.Player(function (player, index)
		local data = Mod:GetData(player)
		data.DoorOutlineCollisionTime = nil
		data.DoorOutlineIndex = nil
		data.CollidingOnDoorOutline = nil
		data.ClosestDoorOutline = nil
	end)
end)

--#endregion

--#region Render door lock

---@param effect EntityEffect
function RED_KEYCHAIN:RenderDoorLock(effect, offset)
	local lockData = selectedDoors[GetPtrHash(effect)]
	if lockData then
		local lockSprite = lockData.Sprite
		local renderPos = RED_KEYCHAIN:GetEntityRenderPosition(effect, offset)
		if lockData.ShouldRender then
			if lockSprite.Color.A < 1 then
				lockSprite.Color.A = min(1, Mod:Lerp(lockSprite.Color.A, 1.1, 0.05))
			end
		else
			if lockSprite.Color.A > 0 then
				lockSprite.Color.A = max(0, Mod:Lerp(lockSprite.Color.A, -0.1, 0.05))
			else
				selectedDoors[GetPtrHash(effect)] = nil
				return
			end
		end
		lockSprite:Render(renderPos)
		if Isaac.GetFrameCount() % 2 == 0 and not Mod.Game:IsPaused() then
			lockSprite:Update()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, RED_KEYCHAIN.RenderDoorLock, EffectVariant.DOOR_OUTLINE)

--#endregion

--#region Open Red Room door

---@param player EntityPlayer
---@param doorSlot DoorSlot
function RED_KEYCHAIN:OpenDoor(player, doorSlot)
	local data = Mod:GetData(player)
	local level = Mod.Level()
	level:MakeRedRoomDoor(level:GetCurrentRoomDesc().SafeGridIndex, doorSlot)
	data.DoorOutlineCollisionTime = nil
	data.DoorOutlineIndex = nil
	data.CollidingOnDoorOutline = nil
	local door = tryGetDoorOutlineTarget(player)
	if door then
		selectedDoors[GetPtrHash(door)] = nil
	end
	data.ClosestDoorOutline = nil
	local keychain = RED_KEYCHAIN:TryGetKeychain(player)
	RED_KEYCHAIN:AddKeys(keychain, -1)
end

--#endregion

--#region Debug render for opening door

--[[ function RED_KEYCHAIN:DebugRender()
	local player = Isaac.GetPlayer()
	local data = Mod:GetData(player)
	local renderPos = Vector(50, 50)
	local collisionTime = data.DoorOutlineCollisionTime or 0
	local collidingOnDoor = data.CollidingOnDoorOutline or false
	local collidingDoorIndex = data.DoorOutlineIndex or "N/A"
	Isaac.RenderText("Collision Time: " .. tostring(collisionTime), renderPos.X, renderPos.Y, 1, 1, 1, 1)
	renderPos = renderPos + Vector(0, 12)
	Isaac.RenderText("Colliding with Door?: " .. tostring(collidingOnDoor), renderPos.X, renderPos.Y, 1, 1, 1, 1)
	renderPos = renderPos + Vector(0, 12)
	Isaac.RenderText("Door Index: " .. tostring(collidingDoorIndex), renderPos.X, renderPos.Y, 1, 1, 1, 1)
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, RED_KEYCHAIN.DebugRender) ]]

--#endregion

--#region Reset keys and keychains per floor

---@param player EntityPlayer
---@param playerUpdate boolean
---@param postInitFinished boolean
function RED_KEYCHAIN:ResetKeychains(player, playerUpdate, postInitFinished)
	if postInitFinished and RED_KEYCHAIN:GetRemovedKeychains(player) > 0 then
		RED_KEYCHAIN:SetRemovedKeychains(player, 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, RED_KEYCHAIN.ResetKeychains)

function RED_KEYCHAIN:ResetKeys()
	Mod.Foreach.Familiar(function (familiar, index)
		RED_KEYCHAIN:AddKeys(familiar, RED_KEYCHAIN.MAX_KEYS - RED_KEYCHAIN:GetNumKeys(familiar))
	end, RED_KEYCHAIN.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, RED_KEYCHAIN.ResetKeys)

--#endregion
