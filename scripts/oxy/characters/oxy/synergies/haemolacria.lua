local Mod = OxyTheBunny

---@param npc EntityNPC
---@param pos Vector
---@param tearFlags TearFlags
---@param source Entity
---@param damage number
---@param player EntityPlayer
local function applyHaemolacria(_, npc, pos, tearFlags, source, damage, player)
	local tear = Mod.Spawn.Tear(TearVariant.BLOOD, pos, nil, tearFlags, player)
	tear:FireSplitTear(pos, Vector.Zero, 1, 1, TearVariant.BLOOD, SplitTearType.BURST)
	tear:Remove()
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, applyHaemolacria, TearFlags.TEAR_BURSTSPLIT)

---@param chainsaw EntityEffect
local function haemoTrail(_, chainsaw)
	if not Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_BURSTSPLIT) then return end
	local sprite = chainsaw:GetSprite()
	local nullTip = sprite:GetNullFrame("tip")
	if not nullTip then return end
	local push = ((chainsaw.Position + nullTip:GetPos()) - chainsaw.Position):Resized(60  * sprite.Scale.X)
	local trail = Mod.Spawn.Effect(EffectVariant.HAEMO_TRAIL, 0, chainsaw.Position + push + (nullTip:GetPos() * sprite.Scale):Rotated(chainsaw.Rotation), nil, chainsaw)
	trail.SpriteScale = sprite.Scale
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_UPDATE, haemoTrail)