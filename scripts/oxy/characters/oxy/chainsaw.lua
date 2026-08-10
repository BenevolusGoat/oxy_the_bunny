--#region Variables

local Mod = OxyTheBunny

local CHAINSAW = {}

OxyTheBunny.Item.CHAINSAW = CHAINSAW

CHAINSAW.ID = Isaac.GetItemIdByName("Chainsaw")
CHAINSAW.NULL_ID = Isaac.GetNullItemIdByName("chainsaw stats")
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

--#endregion

--#region Helpers

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

---@class ChainsawWeapon
---@field Pointer EntityPtr?
---@field RotationOffset number
---@field Damage number
---@field DamageScale number
---@field TearFlags TearFlags
---@field HitList table
---@field GridList table
---@field MaxSwings integer

---@class PlayerChainsawData
---@field Weapons ChainsawWeapon[]
---@field LastFrameFired integer\
---@field NumFired integer
---@field Blindfold boolean
---@field TearDisplacement integer
---@field Charge number
---@field MaxCharge number
---@field UsesCharge boolean

---@param player EntityPlayer
---@return PlayerChainsawData
function CHAINSAW:GetPlayerData(player)
	local data = Mod:GetData(player)
	if not data.Chainsaw then
		---@diagnostic disable-next-line: inject-field
		data.Chainsaw = {
			Weapons = {},
			LastFrameFired = 0,
			NumFired = 0,
			Blindfold = false,
			TearDisplacement = -1,
			Charge = 0,
			MaxCharge = 0
		}
	end
	return data.Chainsaw
end

---@param chainsaw EntityEffect
---@return ChainsawWeapon
local function initChainsawWeapon(chainsaw)
	return {
		Pointer = EntityPtr(chainsaw),
		RotationOffset = 0,
		Damage = 3.5,
		DamageScale = 1,
		TearFlags = TearFlags.TEAR_NORMAL,
		HitList = {},
		GridList = {},
		MaxSwings = 3
	}
end

---@param chainsaw EntityEffect
---@return ChainsawWeapon
function CHAINSAW:GetChainsawData(chainsaw)
	local data = Mod:GetData(chainsaw)
	if not data.Chainsaw then
		---@diagnostic disable-next-line: inject-field
		data.Chainsaw = initChainsawWeapon(chainsaw)
	end
	return data.Chainsaw
end

---@param player EntityPlayer
---@return ChainsawWeapon[]
function CHAINSAW:GetChainsaws(player)
	local data = CHAINSAW:GetPlayerData(player)
	data.Weapons = data.Weapons or {}
	return data.Weapons
end

---@param player EntityPlayer
function CHAINSAW:IsActive(player)
	local chainsaws = CHAINSAW:GetChainsaws(player)
	return chainsaws and chainsaws > 0
end

---@param chainsaw EntityEffect
---@param tearFlags TearFlags
function CHAINSAW:HasTearFlags(chainsaw, tearFlags)
	local data = CHAINSAW:GetChainsawData(chainsaw)
	return Mod:HasBitFlags(data.TearFlags, tearFlags)
end

---@param player EntityPlayer
---@param advance? boolean
function CHAINSAW:GetTearDisplacement(player, advance)
	local data = CHAINSAW:GetPlayerData(player)
	if not data.TearDisplacement then
		data.TearDisplacement = -1
	end
	if advance then
		local displacement = data.TearDisplacement
		if displacement == -1 then
			data.TearDisplacement = 1
		else
			data.TearDisplacement = -1
		end
	end
	return data.TearDisplacement
end

---@param player EntityPlayer
---@param chainsaw EntityEffect
---@param displacement integer
local function updateChainsawParams(player, chainsaw, damageScale, displacement)
	local data = CHAINSAW:GetChainsawData(chainsaw)
	local tearParams = player:GetTearHitParams(WeaponType.WEAPON_KNIFE, damageScale, displacement, chainsaw)
	data.Damage = tearParams.TearDamage
	data.DamageScale = damageScale
	data.TearFlags = tearParams.TearFlags
	chainsaw.Color = tearParams.TearColor
	--local tearDelay = (30 / (player.MaxFireDelay + 1))
	--chainsaw:GetSprite().PlaybackSpeed = Mod:Clamp(1 + ((tearDelay - 1) * 0.4), 0.25, 1.5)
end

---@param player EntityPlayer
---@param angle number
---@param pos Vector
---@param displacement integer
function CHAINSAW:SpawnChainsaw(player, angle, pos, damageScale, displacement)
	local spritesheet = Isaac.RunCallback(Mod.ModCallbacks.CHAINSAW_GET_SKIN, player)
	if not spritesheet then
		spritesheet = "gfx/effects/weapon_chainsaw.png"
	end
	local chainsaw = Mod.Spawn.Effect(CHAINSAW.KNIFE, 0, pos, nil, player)
	local sprite = chainsaw:GetSprite()
	updateChainsawParams(player, chainsaw, damageScale, displacement)
	chainsaw.Rotation = angle
	--Mod:DebugLog("Playback Speed:", chainsaw:GetSprite().PlaybackSpeed)
	sprite.Rotation = angle
	sprite:ReplaceSpritesheet(0, spritesheet, true)
	sprite:Play("Swing", true)
	chainsaw.Parent = player
	return chainsaw
end

--#endregion

--#region Chainsaw Update

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
				if isTip then
					local impact = Mod.Spawn.Effect(EffectVariant.IMPACT, 0, npc.Position, nil, chainsaw)
					impact.DepthOffset = 10
					impact.SpriteScale = Vector(1.5, 1.5)
					impact.Color = chainsaw.Color
					Mod.SFXMan:Play(SoundEffect.SOUND_KNIFE_PULL, 1, 2, false, 1.2)
				else
					Mod.SFXMan:Play(SoundEffect.SOUND_MEATY_DEATHS)
				end
			end
			hitEnemies[ent.Index] = true
		elseif ent:ToEffect() and BACKGROUND_BUGS[ent.Variant] and not ent:IsDead() then
			ent:Die()
		end
	end
end

---@param topLeft Vector
---@param bottomRight Vector
---@function
local function getGridEntitiesInRectangle(topLeft, bottomRight)
	topLeft = Vector(topLeft.X // 40, topLeft.Y // 40)
	bottomRight = Vector(bottomRight.X // 40, bottomRight.Y // 40)

	local room = Mod.Room()
	local size = room:GetGridSize()
	local gridEntities = {}

	for x = topLeft.X, bottomRight.X do
		for y = topLeft.Y, bottomRight.Y do
			local gridIndex = room:GetGridIndex(Vector(x, y) * 40)
			--Very rarely, can encounter a garbage grid entity with an index below 1 that crashes with cast functions
			if gridIndex > 0 and gridIndex < size then
				local gridEntity = room:GetGridEntity(gridIndex)
				if gridEntity then
					gridEntities[#gridEntities + 1] = gridEntity
				end
			end
		end
	end

	return gridEntities
end

---@param chainsaw EntityEffect
function CHAINSAW:HitboxUpdate(chainsaw)
	local capsule1 = chainsaw:GetNullCapsule("Hit")
	local capsule2 = chainsaw:GetNullCapsule("Hit2")
	local capsuleTip = chainsaw:GetNullCapsule("tip")
	local data = CHAINSAW:GetChainsawData(chainsaw)
	local hitEnemies = data.HitList
	local hitGrids = data.GridList
	local source = EntityRef(chainsaw)
	local damage = data.Damage
	local sprite = chainsaw:GetSprite()
	local null1 = sprite:GetNullFrame("Hit")
	local null2 = sprite:GetNullFrame("Hit2")
	local nullTip = sprite:GetNullFrame("tip")
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	---@type TearFlags
	local tearFlags = data.TearFlags
	if player and (sprite:IsEventTriggered("Swing") or sprite:GetFrame() == 0) then
		local displacement = CHAINSAW:GetTearDisplacement(player, true)
		updateChainsawParams(player, chainsaw, data.DamageScale, displacement)
		data.HitList = {}
		data.GridList = {}
		hitEnemies = data.HitList
		hitGrids = data.GridList
		damage = data.Damage
		tearFlags = data.TearFlags
	end
	local hasKnife = false
	if player then
		hasKnife = player:HasWeaponType(WeaponType.WEAPON_KNIFE)
	end

	chainsaw.CollisionDamage = damage

	if nullTip and nullTip:IsVisible() then
		damageInCapsule(chainsaw, capsuleTip, damage * 2, source, tearFlags, hitEnemies, hitGrids, true)
	end
	if null1 and null1:IsVisible() then
		damageInCapsule(chainsaw, capsule1, damage, source, tearFlags, hitEnemies, hitGrids, hasKnife)
		--local grids = getGridEntitiesInRectangle(topLeft, bottomRight)
		Mod.Foreach.GridInRadius(capsule1:GetPosition(), capsule1:GetF1(), function(gridEnt, gridIndex)
			if hitGrids[gridIndex] then return end
			local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_PRE_HIT_GRID, gridEnt:GetType(),
				gridEnt, gridIndex, chainsaw)
			if (result == true or gridEnt:ToPoop() or gridEnt:ToTNT()) then
				gridEnt:HurtWithSource(1, source)
				Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_POST_HIT_GRID, gridEnt:GetType(), gridEnt, gridIndex,
					chainsaw)
			end
			hitGrids[gridIndex] = true
		end)
	end
	if null2 and null2:IsVisible() then
		damageInCapsule(chainsaw, capsule2, damage, source, tearFlags, hitEnemies, hitGrids, hasKnife)
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
			local data = CHAINSAW:GetPlayerData(player)
			if (data.LastFrameFired or -1) ~= Mod.Game:GetFrameCount() then
				data.LastFrameFired = data.LastFrameFired
				data.NumFired = (data.NumFired or 0) + 1
			end
			local fireDir = Vector.FromAngle(chainsaw.Rotation + 90)
			local fireAmount = 1
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
				fireAmount = 12
			end
			Isaac.RunCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, fireDir, fireAmount, player, data.NumFired, chainsaw)
		end
	end

	CHAINSAW:HitboxUpdate(chainsaw)
	Isaac.RunCallback(Mod.ModCallbacks.POST_CHAINSAW_UPDATE, chainsaw)
	if sprite:IsFinished() then
		chainsaw:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, CHAINSAW.ChainsawUpdate, CHAINSAW.KNIFE)

--#endregion

--#region Fire Chainsaw

---@param player EntityPlayer
function CHAINSAW:PeffectUpdate(player)
	local data = CHAINSAW:GetPlayerData(player)
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local canShoot = player:CanShoot()
	local weapon = Isaac.GetPlayer():GetWeapon(1)
	data.MaxCharge = weapon
		and Isaac.RunCallback(Mod.ModCallbacks.CHAINSAW_GET_MAX_CHARGE, player)
		or 0
	if data.MaxCharge == 0 then
		data.Charge = 0
	end
	if canUseChainsaw and not data.Blindfold then
		if not weapon then return end
		local wType = weapon:GetWeaponType()
		local fireDelay = weapon:GetFireDelay()
		Isaac.DestroyWeapon(weapon)
		if canShoot then
			Mod:SetBlindfold(player, true)
		end
		local newWeapon = Isaac.CreateWeapon(wType, Isaac.GetPlayer())
		newWeapon:SetFireDelay(fireDelay)
		Isaac.GetPlayer():SetWeapon(newWeapon, 1)
		data.Blindfold = true
	elseif not canUseChainsaw and data.Blindfold then
		if not canShoot then
			Mod:SetBlindfold(player, false)
		end
		data.Blindfold = nil
		data.Charge = 0
		data.MaxCharge = 0
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
function CHAINSAW:GetMaxFireDelay(player)
	local weapon = player:GetWeapon(1)
	local maxFireDelay = weapon and weapon:GetMaxFireDelay() or player.MaxFireDelay
	local tears = 30 / (maxFireDelay + 1)
	local mult = 0.35
	if maxFireDelay >= 30 then
		mult = 0.9
	elseif maxFireDelay >= 20 then
		mult = 0.6
	end
	tears = tears * mult
	local newMaxFireDelay = (30 / tears) - 1
	maxFireDelay = newMaxFireDelay

	return maxFireDelay
end

---@param player EntityPlayer
function CHAINSAW:GetMaxSwings(player)
	local weapon = player:GetWeapon(1)
	local maxFireDelay = weapon and weapon:GetMaxFireDelay() or player.MaxFireDelay
	if maxFireDelay < 20 then
		return 3
	elseif maxFireDelay < 30 then
		return 2
	else
		return 1
	end
end

---@param player EntityPlayer
---@param fireDir Vector
---@param angle number
---@param displacement integer
---@return ChainsawWeapon
function CHAINSAW:FireChainsaw(player, fireDir, angle, damageScale, displacement)
	local chainsaw = CHAINSAW:SpawnChainsaw(player, angle, player.Position, damageScale, displacement)
	local a1m = fireDir:GetAngleDegrees()
	local a2m = chainsaw.Rotation
	local angleDiff = math.min(a1m - a2m, 360 - a1m - a2m)
	---@class ChainsawWeapon
	local chainsawData = initChainsawWeapon(chainsaw)
	chainsawData.MaxSwings = CHAINSAW:GetMaxSwings(player)
	chainsawData.RotationOffset = angleDiff
	chainsawData.DamageScale = damageScale
	Mod:GetData(chainsaw).ChainsawData = chainsawData
	return chainsawData
end

---@param player EntityPlayer
---@param damageScale? number
function CHAINSAW:WeaponFire(player, damageScale)
	damageScale = damageScale or 1
	local fireDir = Mod:GetAttackDirection(player, true, true)
	local displacement = CHAINSAW:GetTearDisplacement(player, true)
	local multiShotParams = player:GetMultiShotParams(WeaponType.WEAPON_KNIFE)
	local data = CHAINSAW:GetPlayerData(player)
	local maxFireDelay = CHAINSAW:GetMaxFireDelay(player)
	data.Weapons = data.Weapons or {}
	local tears = multiShotParams:GetNumTears()
	for i = 0, tears - 1 do
		local multiShot = player:GetMultiShotPositionVelocity(i, WeaponType.WEAPON_KNIFE, fireDir, player.ShotSpeed * 10,
			multiShotParams)
		local angle = multiShot.Velocity:GetAngleDegrees()
		local playerChainsawData = CHAINSAW:FireChainsaw(player, fireDir, angle, damageScale, displacement)
		Mod.Insert(data.Weapons, playerChainsawData)
	end
	local extraSaws = runExtraSawsCallback(player, multiShotParams)
	for _, rotation in ipairs(extraSaws) do
		local angle = fireDir:Rotated(rotation):GetAngleDegrees()
		local playerChainsawData = CHAINSAW:FireChainsaw(player, fireDir, angle, damageScale, displacement)
		Mod.Insert(data.Weapons, playerChainsawData)
	end
	local weapon = player:GetWeapon(1)
	---@cast weapon Weapon
	weapon:SetFireDelay(maxFireDelay)
	return data.Weapons
end

---@param chainsawWeapon ChainsawWeapon
---@param chainsaw EntityEffect
---@param isShooting boolean
---@param data PlayerChainsawData
local function shouldRetract(chainsawWeapon, chainsaw, isShooting, data)
	local sprite = chainsaw:GetSprite()
	local maxSwings = chainsawWeapon.MaxSwings
	local optionalRetract = not isShooting and data.MaxCharge == 0
		and (sprite:IsEventTriggered("Retract 1")
		or sprite:IsEventTriggered("Retract 2")
		or sprite:IsEventTriggered("Retract 3"))
	local forcedRetract = sprite:IsEventTriggered("Retract " .. maxSwings)
	return optionalRetract
		or forcedRetract
end

---@param player EntityPlayer
function CHAINSAW:OnPlayerUpdate(player)
	local isShooting = Mod:IsShooting(player)
	local data = CHAINSAW:GetPlayerData(player)
	local chainsaws = CHAINSAW:GetChainsaws(player)
	local canUseChainsaw = CHAINSAW:CanUseChainsaw(player)
	local weapon = player:GetWeapon(1)
	local onCooldown = weapon and weapon:GetFireDelay() > -1 or player.FireDelay > -1
	local playingAnim = not player:IsExtraAnimationFinished()

	if canUseChainsaw and not playingAnim then
		---@cast weapon Weapon
		local canFireChainsaw = Isaac.RunCallbackWithParam(Mod.ModCallbacks.CHAINSAW_CAN_FIRE, weapon:GetWeaponType(),
			player, data, isShooting, onCooldown)
		if canFireChainsaw ~= false
			and isShooting
			and not onCooldown
			and ((#chainsaws == 0) or player.MaxFireDelay <= 5.099)
		then
			CHAINSAW:WeaponFire(player)
		end
	end

	local fireDir = Mod:GetAttackDirection(player, true, true)
	for i = #chainsaws, 1, -1 do
		local chainsawWeapon = chainsaws[i]
		local chainsaw = chainsawWeapon.Pointer and chainsawWeapon.Pointer.Ref and
			chainsawWeapon.Pointer.Ref:ToEffect()
		if chainsaw then
			local angle = fireDir:Rotated(chainsawWeapon.RotationOffset):GetAngleDegrees() - 90
			local sprite = chainsaw:GetSprite()
			chainsaw.Rotation = angle
			sprite.Rotation = angle
			chainsaw.PositionOffset = fireDir:Resized(10) + Vector(0, -10)
			if shouldRetract(chainsawWeapon, chainsaw, isShooting, data) then
				chainsaw:Remove()
			end
		end
		if not chainsaw or not chainsaw:Exists() then
			table.remove(data.Weapons, i)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CHAINSAW.OnPlayerUpdate, PlayerVariant.PLAYER)

--#endregion

--#region Stats

---@param player EntityPlayer
function CHAINSAW:UpdateDamage(player)
	if CHAINSAW:CanUseChainsaw(player) then
		player.Damage = player:GetTearPoisonDamage()
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.IMPORTANT, CHAINSAW.UpdateDamage,
	CacheFlag.CACHE_DAMAGE)

---@param player EntityPlayer
---@param item CollectibleType
local function updateChainsawStats(_, player, item)
	local effects = player:GetEffects()
	local hasNull = effects:HasNullEffect(CHAINSAW.NULL_ID)
	local canUse = Mod.Item.CHAINSAW:CanUseChainsaw(player)
	if canUse and not hasNull then
		player:AddNullItemEffect(CHAINSAW.NULL_ID, false, 0, false)
	elseif not canUse and hasNull then
		player:GetEffects():RemoveNullEffect(CHAINSAW.NULL_ID, -1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_ADDED, updateChainsawStats, CHAINSAW.ID)
Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, updateChainsawStats, CHAINSAW.ID)

--#endregion

--#region Stackable Chainsaws

---@param player EntityPlayer
function CHAINSAW:MultiShot(player, params, weaponType)
	local numChainsaw = player:GetCollectibleNum(CHAINSAW.ID)
	if numChainsaw <= 1 then return end
	local weapon = player:GetWeapon(1)
	if weapon then
		local mult = numChainsaw - 1
		params:SetSpreadAngle(weaponType, params:GetSpreadAngle(weaponType) + 2.167 * mult)
		params:SetNumTears(params:GetNumTears() + mult)
		local expectedAmount = params:GetNumTears() / params:GetNumEyesActive()
		params:SetNumLanesPerEye(expectedAmount)
		return params
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, CHAINSAW.MultiShot)

--#endregion

--#region Chargebar

local chargebar = Sprite("gfx/chargebar.anm2", true)

---@param ent Entity | Vector
---@param offset Vector
---@param ignoreShake? boolean
local function getEntityRenderPos(ent, offset, ignoreShake)
	local pos
	if getmetatable(ent).__type == "Vector" then
		---@cast ent Vector
		pos = ent
	else
		---@cast ent Entity
		pos = ent.Position + ent.PositionOffset
		if ent:ToPlayer() and Mod.Room():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT then
			---@cast ent EntityPlayer
			pos = pos + ent:GetFlyingOffset()
		end
	end
	local renderPos = Isaac.WorldToRenderPosition(pos) + offset
	if ignoreShake then
		renderPos = renderPos - Mod.Game.ScreenShakeOffset
	end
	return renderPos
end

---@param player EntityPlayer
function CHAINSAW:RenderChargebar(player, offset)
	if Mod.Room():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT
		and Options.ChargeBars
		and CHAINSAW:CanUseChainsaw(player)
	then
		local renderPos = getEntityRenderPos(player, offset)
		local data = CHAINSAW:GetPlayerData(player)
		if data.MaxCharge > 0 then
			HudHelper.RenderChargeBar(chargebar, data.Charge, data.MaxCharge, renderPos + Vector(12, -35))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, CHAINSAW.RenderChargebar, PlayerVariant.PLAYER)

--#endregion
