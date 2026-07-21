local Mod = OxyTheBunny

---@param npc EntityNPC
---@param chainsaw EntityEffect
---@param pos Vector
---@param tearFlags TearFlags
local function mysteriousLiquid(_, npc, pos, tearFlags, chainsaw, damage)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	--As otherwise it lands on the enemy 100% of the time which is kinda nutty
	local dir = (pos - npc.Position):Normalized()
	pos = pos + dir:Resized(Mod:RandomNum(15, 25))
	local creep = Mod.Spawn.Effect(EffectVariant.PLAYER_CREEP_GREEN, 0, pos, nil, player)
	creep:Update() --To update its size immediately
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, mysteriousLiquid,
	TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)

---@param chainsaw EntityEffect
local function leaveCreepDuringArc(_, chainsaw)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player or not Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP) then return end
	local hit1 = chainsaw:GetSprite():GetNullFrame("Hit")
	local tip = chainsaw:GetSprite():GetNullFrame("tip")
	if hit1 and tip and hit1:IsVisible() then
		local offset = tip:GetPos():Rotated(chainsaw.Rotation)
		local creep = Mod.Spawn.Effect(EffectVariant.PLAYER_CREEP_GREEN, 0, chainsaw.Position + offset, nil,
			chainsaw.SpawnerEntity)
		creep:Update() --To update its size immediately
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_UPDATE, leaveCreepDuringArc)
