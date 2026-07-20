local max = math.max
local Mod = OxyTheBunny

---@param npc EntityNPC
---@param chainsaw EntityEffect
---@param pos Vector
---@param tearFlags TearFlags
local function fireMindExplosion(_, npc, pos, tearFlags, chainsaw, damage)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	local luck = Mod:GetTearModifierLuck(player)
	local chance = 1 / max(1, 10 - (luck * 0.7))
	local roll = Mod.GENERIC_RNG:RandomFloat()
	if roll < chance then
		local params = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 1)
		Mod.Game:BombExplosionEffects(pos, damage, tearFlags, params.TearColor, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_APPLY_TEARFLAG_EFFECTS, fireMindExplosion, TearFlags.TEAR_BURN)
