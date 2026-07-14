local Mod = OxyTheBunny

local TAINTED_UNLOCK = {}

local function checkOxyTaintedLocked()
	local player = Isaac.GetPlayer()
	local playerType = player:GetPlayerType()
	local persistGameData = Isaac.GetPersistentGameData()
	return playerType == Mod.PlayerType.OXY
		and not persistGameData:Unlocked(Mod.Character.OXY_B.ACHIEVEMENT)
end

function TAINTED_UNLOCK:OnSlotSpawn(entType, variant, subtype, grid, seed)
	local level = Mod.Level()
	if level:GetStage() == LevelStage.STAGE8 --Home
		and level:GetCurrentRoomIndex() == 94 --Closet
		and entType == EntityType.ENTITY_SLOT
		and variant == SlotVariant.HOME_CLOSET_PLAYER
		and checkOxyTaintedLocked()
	then
		return { entType, variant, subtype }
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, TAINTED_UNLOCK.OnSlotSpawn)

---@param slot EntitySlot
function TAINTED_UNLOCK:CryingTaintedSpriteOnInit(slot)
	local player = Isaac.GetPlayer()
	if player:GetPlayerType() == Mod.PlayerType.ARACHNA then
		local sprite = slot:GetSprite()
		sprite:ReplaceSpritesheet(0, player:GetEntityConfigPlayer():GetTaintedCounterpart():GetSkinPath(), true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, TAINTED_UNLOCK.CryingTaintedSpriteOnInit, SlotVariant.HOME_CLOSET_PLAYER)

---@param slot EntitySlot
function TAINTED_UNLOCK:UnlockTainted(slot)
	if checkOxyTaintedLocked() then
		local sprite = slot:GetSprite()
		local unlock_table = Mod.PlayerTypeToCompletionTable[Mod.PlayerType.ARACHNA]
		local tainted = unlock_table[CompletionType.TAINTED]
		local persistGameData = Isaac.GetPersistentGameData()
		if sprite:IsFinished("PayPrize") then
			persistGameData:TryUnlock(tainted)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, TAINTED_UNLOCK.UnlockTainted, SlotVariant.HOME_CLOSET_PLAYER)
