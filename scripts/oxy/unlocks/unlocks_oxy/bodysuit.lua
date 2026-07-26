local Mod = OxyTheBunny

local BODYSUIT = {}

OxyTheBunny.Item.BODYSUIT = BODYSUIT

BODYSUIT.ID = Isaac.GetItemIdByName("Bodysuit")

BODYSUIT.SPEED_CAP = 1.2
BODYSUIT.SPEED_UP = 0.1

---@param player EntityPlayer
function BODYSUIT:OnSpeedCache(player)
	if player:HasCollectible(BODYSUIT.ID) then
		player.MoveSpeed = math.max(player.MoveSpeed, BODYSUIT.SPEED_CAP) + (BODYSUIT.SPEED_UP * player:GetCollectibleNum(BODYSUIT.ID))
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, BODYSUIT.OnSpeedCache, CacheFlag.CACHE_SPEED)