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

---@class PlayerChainsawData
---@field Pointer EntityPtr
---@field RotationOffset number

---@param player EntityPlayer
---@return PlayerChainsawData[]
function CHAINSAW:GetChainsaws(player)
	local data = Mod:GetData(player)
	data.ChainsawWeapons = data.ChainsawWeapons or {}
	return data.ChainsawWeapons
end

---@param player EntityPlayer
function CHAINSAW:IsActive(player)
	local chainsaws = CHAINSAW:GetChainsaws(player)
	return chainsaws and chainsaws > 0
end

---@param chainsaw EntityEffect
---@param tearFlags TearFlags
function CHAINSAW:HasTearFlags(chainsaw, tearFlags)
	local data = Mod:GetData(chainsaw)
	if not data.ChainsawTearFlags then return false end
	return Mod:HasBitFlags(data.ChainsawTearFlags, tearFlags)
end

---@param player EntityPlayer
---@param advance? boolean
function CHAINSAW:GetTearDisplacement(player, advance)
	local data = Mod:GetData(player)
	if not data.ChainsawTearDisplacement then
		data.ChainsawTearDisplacement = -1
	end
	if advance then
		local displacement = data.ChainsawTearDisplacement
		if displacement == -1 then
			data.ChainsawTearDisplacement = 1
		else
			data.ChainsawTearDisplacement = -1
		end
	end
	return data.ChainsawTearDisplacement
end

---@param player EntityPlayer
---@param angle number
---@param pos Vector
---@param displacement integer
---@param isSpecter? boolean
function CHAINSAW:SpawnChainsaw(player, angle, pos, displacement, isSpecter)
	local chainsaw = Mod.Spawn.Effect(CHAINSAW.KNIFE, 0, pos, nil, player)
	local sprite = chainsaw:GetSprite()
	local data = Mod:GetData(chainsaw)
	local tearParams = player:GetTearHitParams(WeaponType.WEAPON_KNIFE, 1, displacement, chainsaw)
	data.ChainsawDamage = tearParams.TearDamage * 0.85
	data.ChainsawTearFlags = tearParams.TearFlags
	chainsaw.Color = tearParams.TearColor
	chainsaw.Rotation = angle
	sprite.Rotation = angle
	sprite:Play("Swing", true)
	chainsaw.Parent = player
	if isSpecter then
		sprite:ReplaceSpritesheet(0, "gfx/weapon_specter.png", true)
	end
	return chainsaw
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
		if npc and canHitEnemy(npc) and not hitEnemies[ent.Index] then
			npc:TakeDamage(damage, 0, source, 0)
			local pos = npc.Position + (chainsaw.Position - npc.Position):Resized(npc.Size)
			npc:ApplyTearflagEffects(pos, tearFlags, chainsaw, damage)
			if not npc:HasEntityFlags(EntityFlag.FLAG_NO_FLASH_ON_DAMAGE) then
				Mod.SFXMan:Play(SoundEffect.SOUND_MEATY_DEATHS)
			end
			if hitEnemies then
				hitEnemies[ent.Index] = true
			end
		elseif ent:ToEffect() and BACKGROUND_BUGS[ent.Variant] and not ent:IsDead() then
			ent:Die()
		end
	end
	Mod.Foreach.GridInRadius(capsule:GetPosition(), capsule:GetF1(), function(gridEnt, gridIndex)
		if hitGrids[gridIndex] then return end
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, gridEnt:GetType(),
			gridEnt, gridIndex, chainsaw)
		if (result == true or gridEnt:ToPoop() or gridEnt:ToTNT()) then
			gridEnt:HurtWithSource(1, source)
			Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, gridEnt:GetType(), gridEnt, gridIndex, chainsaw)
		end
		hitGrids[gridIndex] = true
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
	if player and (sprite:IsEventTriggered("Swing") or sprite:GetFrame() == 0) then
		local displacement = CHAINSAW:GetTearDisplacement(player, true)
		local tearParams = player:GetTearHitParams(WeaponType.WEAPON_KNIFE, 1, displacement, chainsaw)
		data.ChainsawDamage = tearParams.TearDamage * 0.85
		data.ChainsawTearFlags = tearParams.TearFlags
		data.HitList = {}
		data.GridList = {}
		hitEnemies = data.HitList
		hitGrids = data.GridList
		damage = data.ChainsawDamage
		tearFlags = data.ChainsawTearFlags
		chainsaw.Color = tearParams.TearColor
	end

	chainsaw.CollisionDamage = damage

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
		return
	end
	local sprite = chainsaw:GetSprite()
	--Above
	if chainsaw.Position.Y + chainsaw.PositionOffset.Y + 10 < chainsaw.Parent.Position.Y then
		chainsaw.DepthOffset = 0
	else --Below
		chainsaw.DepthOffset = 40 * 7
	end

	chainsaw.Position = chainsaw.Parent.Position

	if sprite:IsEventTriggered("SwingSound") or sprite:IsEventTriggered("Swing") then
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
	if sprite:IsFinished() then
		chainsaw:Remove()
	end
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
---@param multiShotParams MultiShotParams
local function runExtraSawsCallback(player, multiShotParams)
	local extraSaws = {}
	local callbacks = Isaac.GetCallbacks(Mod.ModCallbacks.CHAINSAW_GET_EXTRA_SAWS)
	for _, callback in ipairs(callbacks) do
		local func = callback.Function
		local result = func(callback.Mod, player, multiShotParams)
		if type(result) == "table" then
			Mod:AppendTable(extraSaws, result)
		end
	end
	return extraSaws
end

---@param player EntityPlayer
---@param fireDir Vector
---@param angle number
---@param displacement integer
function CHAINSAW:FireChainsaw(player, fireDir, angle, displacement)
	local chainsaw = CHAINSAW:SpawnChainsaw(player, angle, player.Position, displacement, player:GetPlayerType() == Mod.PlayerType.OXY_B)
	local a1m = fireDir:GetAngleDegrees()
	local a2m = chainsaw.Rotation
	local angleDiff = math.min(a1m-a2m, 360-a1m-a2m)
	---@type PlayerChainsawData
	return {
		Pointer = EntityPtr(chainsaw),
		RotationOffset = angleDiff
	}
end

---@param player EntityPlayer
function CHAINSAW:WeaponFire(player)
	local fireDir = Mod:GetAttackDirection(player, false, true)
	local displacement = CHAINSAW:GetTearDisplacement(player, true)
	local multiShotParams = player:GetMultiShotParams(WeaponType.WEAPON_KNIFE)
	local data = Mod:GetData(player)
	data.ChainsawWeapons = data.ChainsawWeapons or {}
	local tears = multiShotParams:GetNumTears()
	for i = 0, tears - 1 do
		local multiShot = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_KNIFE, fireDir, player.ShotSpeed * 10, multiShotParams)
		local angle = multiShot.Velocity:GetAngleDegrees()
		local playerChainsawData = CHAINSAW:FireChainsaw(player, fireDir, angle, displacement)
		Mod.Insert(data.ChainsawWeapons, playerChainsawData)
	end
	local extraSaws = runExtraSawsCallback(player, multiShotParams)
	for _, rotation in ipairs(extraSaws) do
		local angle = fireDir:Rotated(rotation):GetAngleDegrees()
		local playerChainsawData = CHAINSAW:FireChainsaw(player, fireDir, angle, displacement)
		Mod.Insert(data.ChainsawWeapons, playerChainsawData)
	end
	local weapon = player:GetWeapon(1)
	if weapon then
		weapon:SetFireDelay(weapon:GetMaxFireDelay())
	end
end

---@param player EntityPlayer
function CHAINSAW:OnPlayerUpdate(player)
	local isShooting = Mod:IsShooting(player)
	local data = Mod:GetData(player)
	local chainsaws = CHAINSAW:GetChainsaws(player)
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local weapon = player:GetWeapon(1)
	local onCooldown = weapon and weapon:GetFireDelay() > -1 or player.FireDelay > -1
	local playingAnim = not player:IsExtraAnimationFinished()
	if canUseChainsaw and isShooting and not playingAnim and not onCooldown and #chainsaws == 0 then
		CHAINSAW:WeaponFire(player)
	end
	for i = #chainsaws, 1, -1 do
		local playerChainsawData = chainsaws[i]
		local chainsaw = playerChainsawData.Pointer and playerChainsawData.Pointer.Ref and playerChainsawData.Pointer.Ref:ToEffect()
		if isShooting and chainsaw then
			local sprite = chainsaw:GetSprite()
			local fireDir = Mod:GetAttackDirection(player, false, true)
			local angle = fireDir:Rotated(playerChainsawData.RotationOffset):GetAngleDegrees() - 90
			chainsaw.Rotation = angle
			sprite.Rotation = angle
			chainsaw.PositionOffset = fireDir:Resized(10) + Vector(0, -10)
		end
		if chainsaw then
			local sprite = chainsaw:GetSprite()
			if (not isShooting and sprite:IsEventTriggered("Early Retract") or sprite:IsEventTriggered("Retract")) then
				chainsaw:Remove()
			end
		end
		if not chainsaw or not chainsaw:Exists() then
			table.remove(data.ChainsawWeapons, i)
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
