local Mod = OxyTheBunny

local TEAR_CHANCE = 1 / 6

---@param ent Entity
---@param flags DamageFlag
---@param source EntityRef
local function mulligan(_, ent, amount, flags, source, cooldown)
	local npc = ent:ToNPC()
	if npc
		and npc:IsActiveEnemy(false)
		and npc:IsVulnerableEnemy()
		and source.Type == EntityType.ENTITY_EFFECT
		and source.Variant == Mod.Item.CHAINSAW.KNIFE
	then
		local chainsaw = source.Entity and source.Entity:ToEffect() ---@cast chainsaw EntityEffect
		local player = source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToPlayer()
		if player
			and (
				player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN)
				or Mod.Item.CHAINSAW:HasTearFlags(chainsaw, TearFlags.TEAR_MULLIGAN)
			)
			and Mod.GENERIC_RNG:RandomFloat() < TEAR_CHANCE
		then
			player:AddBlueFlies(1, player.Position, npc)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, mulligan)
