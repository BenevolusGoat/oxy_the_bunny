local Mod = OxyTheBunny

local TUFT_OF_FUR = {}

OxyTheBunny.Trinket.TUFT_OF_FUR = TUFT_OF_FUR

TUFT_OF_FUR.ID = Isaac.GetTrinketIdByName("Tuft of Fur")

local STATUS_TO_FLAG = {
	[StatusEffect.BAITED] = EntityFlag.FLAG_BAITED,
	[StatusEffect.BLEEDING] = EntityFlag.FLAG_BLEED_OUT,
	[StatusEffect.BRIMSTONE_MARK] = EntityFlag.FLAG_BRIMSTONE_MARKED,
	[StatusEffect.BURN] = EntityFlag.FLAG_BURN,
	[StatusEffect.CHARMED] = EntityFlag.FLAG_CHARM,
	[StatusEffect.CONFUSION] = EntityFlag.FLAG_CONFUSION,
	[StatusEffect.FEAR] = EntityFlag.FLAG_FEAR,
	[StatusEffect.FREEZE] = EntityFlag.FLAG_FREEZE,
	[StatusEffect.ICE] = EntityFlag.FLAG_ICE,
	[StatusEffect.KNOCKBACK] = EntityFlag.FLAG_KNOCKED_BACK,
	[StatusEffect.MAGNETIZED] = EntityFlag.FLAG_MAGNETIZED,
	[StatusEffect.MIDAS_FREEZE] = EntityFlag.FLAG_MIDAS_FREEZE,
	[StatusEffect.POISON] = EntityFlag.FLAG_POISON,
	[StatusEffect.SHRINK] = EntityFlag.FLAG_SHRINK,
	[StatusEffect.SLOWING] = EntityFlag.FLAG_SLOW,
	[StatusEffect.WEAKNESS] = EntityFlag.FLAG_WEAKNESS,
}

---@param npc EntityNPC
function TUFT_OF_FUR:OnNPCUpdate(npc)
	local data = Mod:GetData(npc)
	for statusEffect, statusData in pairs(data.StatusEffects or {}) do
		if npc:HasEntityFlags(STATUS_TO_FLAG[statusEffect]) then
			statusData.Lifetime = statusData.Lifetime + 1
			if (statusData.Lifetime - 3) % 20 == 0 then
				npc:TakeDamage(statusData.Damage, 0, statusData.Source, 0)
			end
		else
			data.StatusEffects[statusEffect] = nil
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.EARLY, TUFT_OF_FUR.OnNPCUpdate)

---@param statusID StatusEffect
---@param ent Entity
---@param source EntityRef
---@param duration integer
function TUFT_OF_FUR:OnStatusApply(statusID, ent, source, duration)
	local player = Mod:TryGetPlayer(source) or PlayerManager.FirstTrinketOwner(TUFT_OF_FUR.ID)
	if player and player:HasTrinket(TUFT_OF_FUR.ID) then
		local mult = player:GetTrinketMultiplier(TUFT_OF_FUR.ID)
		local data = Mod:GetData(ent)
		data.StatusEffects = data.StatusEffects or {}
		data.StatusEffects[statusID] = {Damage = player.Damage * mult, Source = EntityRef(player), Lifetime = (data.StatusEffects[statusID] and data.StatusEffects[statusID].Lifetime or 0)}
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_STATUS_EFFECT_APPLY, TUFT_OF_FUR.OnStatusApply)