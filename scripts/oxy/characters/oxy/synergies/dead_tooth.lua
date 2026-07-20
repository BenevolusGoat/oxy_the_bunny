local Mod = OxyTheBunny

---@param data table
---@return EntityEffect?
local function tryGetAura(data)
	return data.DeadToothAura and data.DeadToothAura.Ref and data.DeadToothAura.Ref:ToEffect()
end

---@param player EntityPlayer \
local function postPeffectUpdate(_, player)
	if not Mod.Item.CHAINSAW:CanUseChainsaw(player)
		or not player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_TOOTH)
	then
		return
	end
	local data = Mod:GetData(player)
	local aura = tryGetAura(data)
	if aura then
		aura.Position = player.Position
	end
	if Mod:IsShooting(player) and (not aura or not aura:IsDead()) then
		if not aura then
			aura = Mod.Spawn.Effect(EffectVariant.FART_RING, 0, player.Position, nil, player)
			aura.SpriteScale = Vector(0.8, 0.8)
			aura.ParentOffset = Vector.Zero
			data.DeadToothAura = EntityPtr(aura)
		end
	elseif aura then
		if not aura:IsDead() then
			aura:Die()
		elseif aura:GetSprite():IsFinished("Disappear") then
			data.DeadToothAura = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)
