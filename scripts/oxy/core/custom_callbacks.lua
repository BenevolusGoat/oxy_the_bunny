---@class ModReference
local Mod = OxyTheBunny

OxyTheBunny.ModCallbacks = {
	--(EntityNPC NPC, Vector Position, TearFlags, EntityEffect Chainsaw, float Damage), Optional Arg: TearFlags
	CHAINSAW_APPLY_TEARFLAG_EFFECTS = "OXY_CHAINSAW_APPLY_TEARFLAG_EFFECTS",
	--(GridEntity Grid, integer GridIndex): boolean, Optional Arg: GridEntityType - Return `true` to allow this grid to take damage
	CHAINSAW_PRE_HIT_GRID = "OXY_CHAINSAW_PRE_HIT_GRID",
	--(GridEntity Grid, integer GridIndex), Optional Arg: GridEntityType
	CHAINSAW_POST_HIT_GRID = "OXY_CHAINSAW_POST_HIT_GRID",
	--(EntityEffect Chainsaw)
	POST_CHAINSAW_UPDATE = "OXY_POST_CHAINSAW_UPDATE",
	--(EntityEffect Chainsaw, TearFlags, Vector Pos)
	CHAINSAW_ON_ARC_PEAK = "OXY_CHAINSAW_ON_ARC_PEAK",
	--(Vector FireDirection, integer FireAmount, EntityPlayer Player, integer NumFired, EntityEffect Chainsaw)
	POST_CHAINSAW_FIRE = "OXY_POST_CHAINSAW_FIRE"
}

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source? Entity
---@param damage number
function Mod:OnChainsawApplyTearflagEffects(npc, pos, tearFlags, source, damage)
	if source
		and source.Type == EntityType.ENTITY_EFFECT
		and source.Variant == Mod.Item.CHAINSAW.KNIFE
	then
		local chainsaw = source:ToEffect() ---@cast chainsaw EntityEffect
		local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
		if not player then return end
		local callbacks = Isaac.GetCallbacks(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS)
		for _, callback in ipairs(callbacks) do
			local func = callback.Function
			local param = callback.Param
			if not param or Mod:HasBitFlags(tearFlags, param) then
				func(callback.Mod, npc, pos, tearFlags, chainsaw, damage, player)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_APPLY_TEARFLAG_EFFECTS, Mod.OnChainsawApplyTearflagEffects)

--[[ local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)

local function postEpicFetusExplode(_, effect)
	if effect.Variant == EffectVariant.ROCKET and effect.PositionOffset.Y == 0 then
		Isaac.RunCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, effect:ToEffect())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postEpicFetusExplode, EntityType.ENTITY_EFFECT)
 ]]