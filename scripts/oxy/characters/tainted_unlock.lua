local Mod = OxyTheBunny

local TAINTED_UNLOCK = {}

TAINTED_UNLOCK.ACHIEVEMENT = Isaac.GetAchievementIdByName("The Inhabited")

function TAINTED_UNLOCK:OnClosetEntry()
	if not REPENTOGON then return end
	local level = Mod.Level()
	local room = Mod.Room()

	if level:GetStage() == LevelStage.STAGE8 --Home
		and level:GetCurrentRoomIndex() == 94 --Closet
		and room:IsFirstVisit()
	then
		local player = Isaac.GetPlayer()
		local playerType = player:GetPlayerType()
		if not Mod.PersistGameData:Unlocked(TAINTED_UNLOCK.ACHIEVEMENT) then
			local innerChild = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_INNER_CHILD)[1]
			local shopKeeper = Isaac.FindByType(EntityType.ENTITY_SHOPKEEPER)[1]

			if innerChild then
				innerChild:Remove()
			elseif shopKeeper then
				shopKeeper:Remove()
			end

			Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.HOME_CLOSET_PLAYER, playerType, room:GetCenterPos(), Vector.Zero, player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TAINTED_UNLOCK.OnClosetEntry)

---@param slot EntitySlot
function TAINTED_UNLOCK:CryingTaintedSpriteOnInit(slot)
	local player = Isaac.GetPlayer()
	if Mod.PlayerTypeToCompletionTable[player:GetPlayerType()] then
		local sprite = slot:GetSprite()
		sprite:ReplaceSpritesheet(0, player:GetEntityConfigPlayer():GetTaintedCounterpart():GetSkinPath(), true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, TAINTED_UNLOCK.CryingTaintedSpriteOnInit, SlotVariant.HOME_CLOSET_PLAYER)

---@param slot EntitySlot
function TAINTED_UNLOCK:UnlockTainted(slot)
	local player = Isaac.GetPlayer()
	local sprite = slot:GetSprite()

	if player:GetPlayerType() == Mod.PlayerType.OXY and sprite:IsFinished("PayPrize") then
		Mod.PersistGameData:TryUnlock(TAINTED_UNLOCK.ACHIEVEMENT)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, TAINTED_UNLOCK.UnlockTainted, SlotVariant.HOME_CLOSET_PLAYER)
