local Mod = OxyTheBunny

local CHAINSAW = {}

OxyTheBunny.Item.CHAINSAW = CHAINSAW

CHAINSAW.ID = Isaac.GetItemIdByName("Chainsaw")
CHAINSAW.KNIFE = Isaac.GetEntityVariantByName("Oxy's Chainsaw")

CHAINSAW.DEFAULT_HIT_COUNTDOWN = 3

local BACKGROUND_BUGS = Mod:Set({
	EffectVariant.BEETLE,
	EffectVariant.WORM,
	EffectVariant.TINY_BUG,
	EffectVariant.TINY_FLY,
	EffectVariant.BUTTERFLY,
	EffectVariant.TADPOLE
})

---@param player EntityPlayer
function CHAINSAW:CanUseChainsaw(player)
	local weapon = player:GetWeapon(1)
	if player:IsCoopGhost()
		or player:GetWeapon(0) ~= nil
		or weapon == nil
	then
		return false
	end
	return player:HasCollectible(CHAINSAW.ID)
end

---@param player EntityPlayer
---@return EntityEffect?
function CHAINSAW:TryGetChainsaw(player)
	local data = player:GetData()
	return data and data.ActiveChainsaw and data.ActiveChainsaw.Ref and data.ActiveChainsaw.Ref:ToEffect()
end

---@param player EntityPlayer
function CHAINSAW:IsActive(player)
	return CHAINSAW:TryGetChainsaw(player) ~= nil
end

---@param player EntityPlayer
function CHAINSAW:SpawnChainsaw(player)
	local fireDir = Mod:GetAttackDirection(player, false, true)
	local angle = fireDir:GetAngleDegrees() - 90
	local chainsaw = Mod.Spawn.Effect(CHAINSAW.KNIFE, 0, player.Position, nil, player)
	local sprite = chainsaw:GetSprite()
	local data = player:GetData()
	data.ActiveChainsaw = EntityPtr(chainsaw)
	chainsaw.Rotation = angle
	sprite.Rotation = angle
	chainsaw.PositionOffset = fireDir:Resized(5) + Vector(0, -5)
	sprite:Play("Swing", true)
	chainsaw.Parent = player
	local weapon = player:GetWeapon(1)
	if weapon then
		weapon:SetFireDelay(weapon:GetMaxFireDelay())
	end
end

---@param npc? EntityNPC
local function canHitEnemy(npc)
	return npc
		and (
			npc:IsVulnerableEnemy()
			or (npc.Type == EntityType.ENTITY_FIREPLACE and npc.Variant <= 1)
			or npc.Type == EntityType.ENTITY_POOP
			or npc.Type == EntityType.ENTITY_MOVABLE_TNT
		)
		and not npc:IsDead()
end

---@param chainsaw EntityEffect
---@param capsule Capsule
---@param damage number
---@param source EntityRef
---@param tearFlags TearFlags
---@param hitEnemies table
---@param hitGrids table
---@param isTip boolean
local function damageInCapsule(chainsaw, capsule, damage, source, tearFlags, hitEnemies, hitGrids, isTip)
	if Mod:HasBitFlags(Mod.Game:GetDebugFlags(), DebugFlag.HITSPHERES) then
		local shape = DebugRenderer.Get(-1, true)
		shape:Capsule(capsule)
		shape:SetTimeout(1)
	end
	for _, ent in ipairs(Isaac.FindInCapsule(capsule)) do
		local npc = ent:ToNPC()
		if npc and canHitEnemy(npc) and (isTip or not hitEnemies[ent.Index]) then
			npc:TakeDamage(damage, 0, source, 0)
			npc:ApplyTearflagEffects(npc.Position, tearFlags, chainsaw, damage)
			if not npc:HasEntityFlags(EntityFlag.FLAG_NO_FLASH_ON_DAMAGE) then
				Mod.SFXMan:Play(SoundEffect.SOUND_MEATY_DEATHS)
			end
			if hitEnemies then
				hitEnemies[ent.Index] = CHAINSAW.DEFAULT_HIT_COUNTDOWN
			end
		elseif ent:ToEffect() and BACKGROUND_BUGS[ent.Variant] and not ent:IsDead() then
			ent:Die()
		end
	end
	Mod.Foreach.GridInRadius(capsule:GetPosition(), capsule:GetF1(), function (gridEnt, gridIndex)
		if (gridEnt:ToPoop() or gridEnt:ToTNT()) and not hitGrids[gridIndex] then
			gridEnt:HurtWithSource(1, source)
			hitGrids[gridIndex] = CHAINSAW.DEFAULT_HIT_COUNTDOWN
		end
	end)
end

---@param chainsaw EntityEffect
function CHAINSAW:HitboxUpdate(chainsaw)
	local capsule1 = chainsaw:GetNullCapsule("Hit")
	local capsule2 = chainsaw:GetNullCapsule("Hit2")
	local capsuleTip = chainsaw:GetNullCapsule("tip")
	local data = chainsaw:GetData()
	data.HitList = data.HitList or {}
	local hitEnemies = data.HitList
	data.GridList = data.GridList or {}
	local hitGrids = data.GridList
	local source = EntityRef(chainsaw)
	local damage = 3.5
	local sprite = chainsaw:GetSprite()
	local null1 = sprite:GetNullFrame("Hit")
	local null2 = sprite:GetNullFrame("Hit2")
	local nullTip = sprite:GetNullFrame("tip")
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	---@type TearFlags
	local tearFlags = TearFlags.TEAR_NORMAL
	if player then
		local tearParams = player:GetTearHitParams(WeaponType.WEAPON_KNIFE, 1, 1, chainsaw)
		damage = tearParams.TearDamage * 0.85
		tearFlags = tearParams.TearFlags
		chainsaw.Color = tearParams.TearColor
	end

	for index, countdown in pairs(hitEnemies) do
		if countdown > 0 then
			hitEnemies[index] = hitEnemies[index] - 1
		else
			hitEnemies[index] = nil
		end
	end

	for index, countdown in pairs(hitGrids) do
		if countdown > 0 then
			hitGrids[index] = hitGrids[index] - 1
		else
			hitGrids[index] = nil
		end
	end

	if nullTip and nullTip:IsVisible() then
		damageInCapsule(chainsaw, capsuleTip, damage * 2, source, tearFlags, hitEnemies, hitGrids)
	end
	if null1 and null1:IsVisible() then
		damageInCapsule(chainsaw, capsule1, damage, source, tearFlags, hitEnemies, hitGrids)
	end
	if null2 and null2:IsVisible() then
		damageInCapsule(chainsaw, capsule2, damage, source, tearFlags, hitEnemies, hitGrids)
	end
end

---@param chainsaw EntityEffect
function CHAINSAW:ChainsawUpdate(chainsaw)
	if not chainsaw.Parent then
		chainsaw:Remove()
		return
	end

	chainsaw.Position = chainsaw.Parent.Position
	--Above
	if chainsaw.Position.Y + chainsaw.PositionOffset.Y + 10 < chainsaw.Parent.Position.Y then
		chainsaw.DepthOffset = 0
	else --Below
		chainsaw.DepthOffset = 40 * 7
	end

	if chainsaw:GetSprite():IsEventTriggered("Woosh") then
		Mod.SFXMan:Play(SoundEffect.SOUND_SWORD_SPIN)
	end

	CHAINSAW:HitboxUpdate(chainsaw)
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, CHAINSAW.ChainsawUpdate, CHAINSAW.KNIFE)

---@param player EntityPlayer
function CHAINSAW:PeffectUpdate(player)
	local data = Mod:GetData(player)
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local canShoot = player:CanShoot()
	if canUseChainsaw and not data.ChainsawBlindfold then
		if canShoot then
			Mod:SetBlindfold(player, true)
		end
		data.ChainsawBlindfold = true
	elseif not canUseChainsaw and data.ChainsawBlindfold then
		if not canShoot then
			Mod:SetBlindfold(player, false)
		end
		data.ChainsawBlindfold = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CHAINSAW.PeffectUpdate)

---@param player EntityPlayer
function CHAINSAW:OnPlayerUpdate(player)
	local isShooting = Mod:IsShooting(player)
	local chainsaw = CHAINSAW:TryGetChainsaw(player)
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local onCooldown = player:GetWeapon(1) and player:GetWeapon(1):GetFireDelay() > -1
	if isShooting and chainsaw then
		local sprite = chainsaw:GetSprite()
		local fireDir = Mod:GetAttackDirection(player, false, true)
		local angle = fireDir:GetAngleDegrees() - 90
		chainsaw.Rotation = angle
		sprite.Rotation = angle
		chainsaw.PositionOffset = fireDir:Resized(20) + Vector(0, -10)
		player:SetHeadDirection(Mod:GetFireDirection(player), 16, true)
	end
	if canUseChainsaw and isShooting and not chainsaw and player:IsExtraAnimationFinished() and not onCooldown then
		CHAINSAW:SpawnChainsaw(player)
	elseif chainsaw and (not isShooting or not player:IsExtraAnimationFinished() or not canUseChainsaw) then
		local sprite = chainsaw:GetSprite()
		if sprite:IsEventTriggered("Retract") and chainsaw:Exists() then
			chainsaw:Remove()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CHAINSAW.OnPlayerUpdate, PlayerVariant.PLAYER)

---@param player EntityPlayer
function CHAINSAW:UpdateDamage(player)
	if CHAINSAW:CanUseChainsaw(player) then
		player.Damage = player:GetTearPoisonDamage()
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.IMPORTANT, CHAINSAW.UpdateDamage, CacheFlag.CACHE_DAMAGE)