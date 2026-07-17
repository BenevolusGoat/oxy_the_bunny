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
	return player:HasCollectible(CHAINSAW.ID) or player:GetPlayerType() == Mod.PlayerType.OXY_B
end

---@param player EntityPlayer
---@return EntityEffect?
function CHAINSAW:TryGetChainsaw(player)
	local data = Mod:GetData(player)
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
	local data = Mod:GetData(player)
	local cData = Mod:GetData(chainsaw)
	local tearParams = player:GetTearHitParams(WeaponType.WEAPON_KNIFE, 1, 1, chainsaw)
	cData.ChainsawDamage = tearParams.TearDamage * 0.85
	cData.ChainsawTearFlags = tearParams.TearFlags
	chainsaw.Color = tearParams.TearColor
	chainsaw.Rotation = angle
	sprite.Rotation = angle
	chainsaw.PositionOffset = fireDir:Resized(10) + Vector(0, -10)
	sprite:Play("Swing", true)
	chainsaw.Parent = player
	data.ActiveChainsaw = EntityPtr(chainsaw)
	if player:GetPlayerType() == Mod.PlayerType.OXY_B then
		sprite:ReplaceSpritesheet(0, "gfx/weapon_specter.png", true)
	end
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

local function runArcPeakCallback(chainsaw, tearFlags, pos)
	local callbacks = Isaac.GetCallbacks(Mod.ModCallbacks.CHAINSAW_ON_ARC_PEAK)
	for _, callback in ipairs(callbacks) do
		local func = callback.Function
		local param = callback.Param
		if not param or Mod:HasBitFlags(tearFlags, param) then
			func(callback.Mod, chainsaw, tearFlags, pos)
		end
	end
end

---@param chainsaw EntityEffect
---@param capsule Capsule
---@param damage number
---@param source EntityRef
---@param tearFlags TearFlags
---@param hitEnemies table
---@param hitGrids table
---@param isTip? boolean
local function damageInCapsule(chainsaw, capsule, damage, source, tearFlags, hitEnemies, hitGrids, isTip)
	if Mod:HasBitFlags(Mod.Game:GetDebugFlags(), DebugFlag.HITSPHERES) then
		local shape = DebugRenderer.Get(-1, true)
		shape:Capsule(capsule)
		shape:SetTimeout(1)
	end
	if isTip then
		runArcPeakCallback(chainsaw, tearFlags, capsule:GetPosition())
	end
	for _, ent in ipairs(Isaac.FindInCapsule(capsule)) do
		local npc = ent:ToNPC()
		if npc and canHitEnemy(npc) and (isTip or not hitEnemies[ent.Index]) then
			npc:TakeDamage(damage, 0, source, 0)
			local pos = npc.Position + (chainsaw.Position - npc.Position):Resized(npc.Size)
			npc:ApplyTearflagEffects(pos, tearFlags, chainsaw, damage)
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
	Mod.Foreach.GridInRadius(capsule:GetPosition(), capsule:GetF1(), function(gridEnt, gridIndex)
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, gridEnt:GetType(), gridEnt,
			gridIndex)
		if (result == true or gridEnt:ToPoop() or gridEnt:ToTNT()) and not hitGrids[gridIndex] then
			gridEnt:HurtWithSource(1, source)
			hitGrids[gridIndex] = CHAINSAW.DEFAULT_HIT_COUNTDOWN
			Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, gridEnt:GetType(), gridEnt, gridIndex)
		end
	end)
end

---@param chainsaw EntityEffect
function CHAINSAW:HitboxUpdate(chainsaw)
	local capsule1 = chainsaw:GetNullCapsule("Hit")
	local capsule2 = chainsaw:GetNullCapsule("Hit2")
	local capsuleTip = chainsaw:GetNullCapsule("tip")
	local data = Mod:GetData(chainsaw)
	data.HitList = data.HitList or {}
	local hitEnemies = data.HitList
	data.GridList = data.GridList or {}
	local hitGrids = data.GridList
	local source = EntityRef(chainsaw)
	local damage = data.ChainsawDamage or 3.5
	local sprite = chainsaw:GetSprite()
	local null1 = sprite:GetNullFrame("Hit")
	local null2 = sprite:GetNullFrame("Hit2")
	local nullTip = sprite:GetNullFrame("tip")
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	---@type TearFlags
	local tearFlags = data.ChainsawTearFlags or TearFlags.TEAR_NORMAL
	if player and (sprite:IsEventTriggered("Early Retract") or sprite:IsEventTriggered("Retract")) then
		local tearParams = player:GetTearHitParams(WeaponType.WEAPON_KNIFE, 1, 1, chainsaw)
		data.ChainsawDamage = tearParams.TearDamage * 0.85
		data.ChainsawTearFlags = tearParams.TearFlags
		damage = data.ChainsawDamage
		tearFlags = data.ChainsawTearFlags
		chainsaw.Color = tearParams.TearColor
	end
	chainsaw.CollisionDamage = damage

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
		damageInCapsule(chainsaw, capsuleTip, damage * 2, source, tearFlags, hitEnemies, hitGrids, true)
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
		local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
		if player then
			local data = Mod:GetData(player)
			if (data.LastChainsawFired or -1) ~= Mod.Game:GetFrameCount() then
				data.LastChainsawFired = data.LastChainsawFired
				data.ChainsawNumFired = (data.ChainsawNumFired or 0) + 1
			end
			local fireDir = Vector.FromAngle(chainsaw.Rotation + 90)
			local fireAmount = 1
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
				fireAmount = 12
			end
			Isaac.RunCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, fireDir, fireAmount, player, data.ChainsawNumFired, chainsaw)
		end
	end

	CHAINSAW:HitboxUpdate(chainsaw)
	Isaac.RunCallback(Mod.ModCallbacks.POST_CHAINSAW_UPDATE, chainsaw)
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, CHAINSAW.ChainsawUpdate, CHAINSAW.KNIFE)

local STUCK_KNIVES = Mod:Set({
	KnifeVariant.MOMS_KNIFE,
	KnifeVariant.SUMPTORIUM,
	KnifeVariant.BONE_CLUB,
	KnifeVariant.BONE_SCYTHE,
})

---@param player EntityPlayer
function CHAINSAW:PeffectUpdate(player)
	local data = Mod:GetData(player)
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local canShoot = player:CanShoot()
	if canUseChainsaw and not data.ChainsawBlindfold then
		if canShoot then
			Mod:SetBlindfold(player, true)
		end
		Mod.Foreach.Knife(function (knife, index)
			if knife.Parent
				and GetPtrHash(player) == GetPtrHash(knife.Parent)
				and STUCK_KNIVES[knife.Variant]
			then
				knife:Remove()
			end
		end, nil, 0, {Inverse = true})
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
	local chainsawExists = chainsaw ~= nil
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local onCooldown = player:GetWeapon(1) and player:GetWeapon(1):GetFireDelay() > -1
	local playingAnim = not player:IsExtraAnimationFinished()
	if isShooting and chainsaw then
		local sprite = chainsaw:GetSprite()
		local fireDir = Mod:GetAttackDirection(player, false, true)
		local angle = fireDir:GetAngleDegrees() - 90
		chainsaw.Rotation = angle
		sprite.Rotation = angle
		chainsaw.PositionOffset = fireDir:Resized(10) + Vector(0, -10)
	end
	if canUseChainsaw and isShooting and not chainsawExists and not playingAnim and not onCooldown then
		CHAINSAW:SpawnChainsaw(player)
	elseif chainsawExists and (not isShooting or playingAnim or not canUseChainsaw or onCooldown) then
		---@cast chainsaw EntityEffect
		local sprite = chainsaw:GetSprite()
		if (not isShooting and sprite:IsEventTriggered("Early Retract") or sprite:IsEventTriggered("Retract")) and chainsaw:Exists() then
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
