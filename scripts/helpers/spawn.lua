--By TheCatWizard
local game = Game()
local Spawn = {}
local max = math.max
local persistentGameData = Isaac.GetPersistentGameData()

local PickupUnlocks = {
	[PickupVariant.PICKUP_HEART] = {
		[HeartSubType.HEART_GOLDEN] = function() return persistentGameData:Unlocked(Achievement.GOLDEN_HEARTS) end
	},
	[PickupVariant.PICKUP_BOMB] = {
		[BombSubType.BOMB_GOLDEN] = function() return persistentGameData:Unlocked(Achievement.GOLD_BOMB) end
	},
	[PickupVariant.PICKUP_KEY] = {
		[KeySubType.KEY_CHARGED] = function() return persistentGameData:Unlocked(Achievement.CHARGED_KEY) end
	},
	[PickupVariant.PICKUP_COIN] = {
		[CoinSubType.COIN_LUCKYPENNY] = function() return persistentGameData:Unlocked(Achievement.LUCKY_PENNIES) end,
		[CoinSubType.COIN_STICKYNICKEL] = function() return persistentGameData:Unlocked(Achievement.STICKY_NICKELS) end,
		[CoinSubType.COIN_GOLDEN] = function() return persistentGameData:Unlocked(Achievement.GOLDEN_PENNY) end
	},
	[PickupVariant.PICKUP_LIL_BATTERY] = {
		[BatterySubType.BATTERY_MICRO] = function() return persistentGameData:Unlocked(Achievement.EVERYTHING_IS_TERRIBLE) end,
		[BatterySubType.BATTERY_GOLDEN] = function() return persistentGameData:Unlocked(Achievement.GOLDEN_BATTERY) end
	},
	[PickupVariant.PICKUP_PILL] = {
		[PillColor.PILL_GOLD] = function() return persistentGameData:Unlocked(Achievement.GOLDEN_PILLS) end,
		[PillColor.PILL_GIANT_FLAG] = function() return persistentGameData:Unlocked(Achievement.HORSE_PILLS) end
	},
	[PickupVariant.PICKUP_TRINKET] = {
		[TrinketType.TRINKET_GOLDEN_FLAG] = function() return persistentGameData:Unlocked(Achievement.GOLDEN_TRINKET) end
	},
	[PickupVariant.PICKUP_WOODENCHEST] = function() return persistentGameData:Unlocked(Achievement.WOODEN_CHEST) and PickupVariant.PICKUP_WOODENCHEST or PickupVariant.PICKUP_CHEST end,
	[PickupVariant.PICKUP_MEGACHEST] = function() return persistentGameData:Unlocked(Achievement.MEGA_CHEST) and PickupVariant.PICKUP_MEGACHEST or PickupVariant.PICKUP_LOCKEDCHEST end,
	[PickupVariant.PICKUP_GRAB_BAG] = {
		[SackSubType.SACK_BLACK] = function() return persistentGameData:Unlocked(Achievement.BLACK_SACK) end
	}
}

local function randomSeed()
	return max(Random(), 1) -- seed being 0 causes a crash
end

--#region Pickups

---@alias EntityOrNil Entity | nil
---@alias IntOrNil integer | nil
---@alias VectorOrNil Vector | nil
---@alias TearFlagsOrNil TearFlags | nil

---@param variant PickupVariant
---@param subtype integer
---@return PickupVariant, integer
local function checkPickupUnlocks(variant, subtype)
	local isUnlocked
	if variant == PickupVariant.PICKUP_TRINKET and subtype & TrinketType.TRINKET_GOLDEN_FLAG == TrinketType.TRINKET_GOLDEN_FLAG then
		isUnlocked = PickupUnlocks[PickupVariant.PICKUP_TRINKET][TrinketType.TRINKET_GOLDEN_FLAG]()
		if not isUnlocked then
			return variant, subtype & ~TrinketType.TRINKET_GOLDEN_FLAG
		else
			return variant, subtype
		end
	elseif variant == PickupVariant.PICKUP_PILL and subtype & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
		isUnlocked = PickupUnlocks[PickupVariant.PICKUP_PILL][PillColor.PILL_GIANT_FLAG]()
		if not isUnlocked then
			return variant, subtype & ~PillColor.PILL_GIANT_FLAG
		else
			return variant, subtype
		end
	else
		local pickupTable = PickupUnlocks[variant]
		if type(pickupTable) == "function" then
			isUnlocked = pickupTable()
		elseif type(pickupTable) == "table" then
			local subtypeTable = pickupTable[subtype]
			if subtypeTable then
				isUnlocked = pickupTable[subtype]()
			end
		end
	end
	if type(isUnlocked) == "number" then
		return isUnlocked, subtype
	elseif type(isUnlocked) == "boolean" and not isUnlocked then
		return variant, 0
	end
	return variant, subtype
end

---@type fun(variant: PickupVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
local function spawnPickup(variant, subtype, position, velocity, spawner, seed)
	variant, subtype = checkPickupUnlocks(variant, subtype)
	local pickup =  game:Spawn(
		EntityType.ENTITY_PICKUP, variant,
		position, velocity or Vector.Zero,
		spawner, subtype, seed or randomSeed()
	):ToPickup() ---@cast pickup EntityPickup
	return pickup
end

---@type fun(variant: PickupVariant| 0, subtype: integer| 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Pickup(variant, subtype, position, velocity, spawner, seed)
	return spawnPickup(variant, subtype, position, velocity, spawner, seed)
end

---@type fun(subtype: HeartSubType| 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Heart(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_HEART, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: CoinSubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Coin(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_COIN, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: KeySubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Key(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_KEY, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: BombSubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Bomb(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_BOMB, subtype,
						position, velocity, spawner, seed)
end

---@type fun(chestVariant: PickupVariant, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Chest(chestVariant, position, velocity, spawner, seed)
	return spawnPickup(chestVariant, 0,
						position, velocity, spawner, seed)
end

---@type fun(subtype: SackSubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Sack(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_GRAB_BAG, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: PillColor | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Pill(pillColor, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_PILL, pillColor,
						position, velocity, spawner, seed)
end

---@type fun(pillColor: PillColor | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.HorsePill(pillColor, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_PILL, pillColor | PillColor.PILL_GIANT_FLAG,
						position, velocity, spawner, seed)
end

---@type fun(subtype: BatterySubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Battery(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_LIL_BATTERY, subtype,
						position, velocity, spawner, seed)
end

---@type fun(itemId:CollectibleType | 0, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Collectible(itemId, position, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_COLLECTIBLE, itemId,
						position, Vector.Zero, spawner, seed)
end

---@type fun(position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.ShopItem(position, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_SHOPITEM, 0,
						position, Vector.Zero, spawner, seed)
end

---@type fun(trinketType: TrinketType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Trinket(trinketType, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_TRINKET, trinketType,
						position, velocity, spawner, seed)
end

--#endregion

---@type fun(variant: BombVariant, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityBomb
function Spawn.LitBomb(variant, position, velocity, spawner, seed)
	local bomb = game:Spawn(
		EntityType.ENTITY_BOMB, variant,
		position, velocity or Vector.Zero,
		spawner, 0, seed or randomSeed()
	):ToBomb() ---@cast bomb EntityBomb
	return bomb
end

---@type fun(tearVariant: TearVariant, position: Vector, velocity: VectorOrNil, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityTear
function Spawn.Tear(tearVariant, position, velocity, tearFlags, spawner, seed)
	local tear = game:Spawn(
		EntityType.ENTITY_TEAR, tearVariant,
		position, velocity or Vector.Zero,
		spawner, 0, seed or randomSeed()
	):ToTear() ---@cast tear EntityTear

	if tearFlags then
		tear:AddTearFlags(tearFlags)
	end

	return tear
end

---@type fun(variant: FamiliarVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityFamiliar
function Spawn.Familiar(variant, subtype, position, velocity, spawner, seed)
	local familiar = game:Spawn(
		EntityType.ENTITY_FAMILIAR, variant,
		position, velocity or Vector.Zero,
		spawner, subtype, seed or randomSeed()
	):ToFamiliar() ---@cast familiar EntityFamiliar

	return familiar
end

local SlotUnlocks = {
	[SlotVariant.CRANE_GAME] = function() return persistentGameData:Unlocked(Achievement.CRANE_GAME) and SlotVariant.CRANE_GAME or SlotVariant.SLOT_MACHINE end,
	[SlotVariant.ROTTEN_BEGGAR] = function() return persistentGameData:Unlocked(Achievement.ROTTEN_BEGGAR) and SlotVariant.ROTTEN_BEGGAR or SlotVariant.KEY_MASTER end,
	[SlotVariant.HELL_GAME] = function() return persistentGameData:Unlocked(Achievement.HELL_GAME) and SlotVariant.HELL_GAME or SlotVariant.DEVIL_BEGGAR end,
}

---@type fun(slotVariant: SlotVariant, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntitySlot
function Spawn.Slot(slotVariant, position, spawner, seed)
	if slotVariant == SlotVariant.CONFESSIONAL and not persistentGameData:Unlocked(Achievement.CONFESSIONAL) then
		---@diagnostic disable-next-line: return-type-mismatch
		return Spawn.Heart(HeartSubType.HEART_SOUL, position, nil, spawner, seed)
	elseif SlotUnlocks[slotVariant] then
		slotVariant = SlotUnlocks[slotVariant]()
	end
	local slot = game:Spawn(
		EntityType.ENTITY_SLOT, slotVariant,
		position, Vector.Zero,
		spawner, 0, seed or randomSeed()
	):ToSlot() ---@cast slot EntitySlot

	return slot
end

--#region Lasers

---@type fun(variant: LaserVariant, subtype: LaserSubType, position: Vector, velocity: VectorOrNil, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityLaser
local function spawnLaser(variant, subtype, position, velocity, tearFlags, spawner, seed)
	local laser = game:Spawn(
		EntityType.ENTITY_LASER, variant,
		position, velocity or Vector.Zero,
		spawner, subtype or 0, seed or randomSeed()
	):ToLaser() ---@cast laser EntityLaser

	if tearFlags then
		laser:AddTearFlags(tearFlags)
	end

	return laser
end

---@type fun(variant: LaserVariant, position: Vector, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityLaser
function Spawn.LinearLaser(variant, position, tearFlags, spawner, seed)
	return spawnLaser(variant, LaserSubType.LASER_SUBTYPE_LINEAR,
						position, Vector.Zero, tearFlags, spawner, seed)
end

---@type fun(variant: LaserVariant, position: Vector, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityLaser
function Spawn.LudoLaser(variant, position, tearFlags, spawner, seed)
	return spawnLaser(variant, LaserSubType.LASER_SUBTYPE_RING_LUDOVICO,
						position, Vector.Zero, tearFlags, spawner, seed)
end

---@type fun(variant: LaserVariant, position: Vector, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, followParent: boolean, seed: IntOrNil): EntityLaser
function Spawn.RingLaser(variant, position, tearFlags, spawner, followParent, seed)
	local subtype = followParent and LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT
									or LaserSubType.LASER_SUBTYPE_RING_PROJECTILE
	return spawnLaser(variant, subtype,
						position, Vector.Zero, tearFlags, spawner, seed)
end

--#endregion

--#region Effects

---@type fun(variant: EffectVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
local function spawnEffect(variant, subtype, position, velocity, spawner, seed)
	local effect = game:Spawn(
		EntityType.ENTITY_EFFECT, variant,
		position, velocity or Vector.Zero,
		spawner, subtype, seed or randomSeed()
	):ToEffect() ---@cast effect EntityEffect

	return effect
end

---@type fun(variant: EffectVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.Effect(variant, subtype, position, velocity, spawner, seed)
	return spawnEffect(variant, subtype, position, velocity, spawner, seed)
end

---@type fun(subtype: integer, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.Poof01(subtype, position, spawner, seed)
	return spawnEffect(EffectVariant.POOF01, subtype, position, Vector.Zero, spawner, seed)
end

---@type fun(subtype: integer, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.Poof02(subtype, position, spawner, seed)
	return spawnEffect(EffectVariant.POOF02, subtype, position, Vector.Zero, spawner, seed)
end

---@alias CrackTheSkySubtype
---|0  #Default Instant Crack the Sky. 17 frames of hitbox
---|1  #2 frames of hitbox before turning into SubType 10
---|2  #Delayed with a visual cue. 17 frames of hitbox
---|10 #Visual only, no hitbox

---@type fun(subtype: CrackTheSkySubtype, position: Vector, damage: number, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.CrackTheSky(subtype, position, damage, spawner, seed)
	local beam = spawnEffect(EffectVariant.CRACK_THE_SKY, subtype, position, Vector.Zero, spawner, seed)

	beam.Parent = spawner ---@diagnostic disable-line
	beam.CollisionDamage = damage
	beam:Update()

	return beam
end

---@type fun(target:Entity, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.BigHornHand(target, spawner, seed)
	local hand = spawnEffect(EffectVariant.BIG_HORN_HAND, 0, target.Position, Vector.Zero, spawner, seed)
	hand.Target = target

	return hand
end

---@type fun(type: 0|1|2|3|4|5|6,
--- position: Vector,
--- colorize: { R: number, G: number, B: number, A: number } | nil,
--- persistent: boolean|nil): EntityEffect
function Spawn.BloodSplat(lvl, position, colorize, persistent)
	return Epiphany.BLOOD_SPLAT:SpawnBlood(lvl, position, colorize, persistent)
end

local rng = RNG()

---@param lower? integer
---@param upper? integer
local function randomNum(lower, upper)
	if upper then
		return rng:RandomInt((upper - lower) + 1) + lower
	elseif lower then
		return rng:RandomInt(lower) + 1
	else
		return rng:RandomFloat()
	end
end

---@param position Vector
---@param velocity? Vector
---@param spawner? Entity
---@param seed? integer
---@return EntityEffect[]
function Spawn.DustCloud(position, velocity, spawner, seed)
	local cloud = spawnEffect(EffectVariant.DUST_CLOUD, 0, position, velocity or RandomVector():Resized(randomNum(0, 4) + randomNum()), spawner, seed)
	cloud:SetTimeout(randomNum(15, 25))
	cloud.Color.A = max(0.3, randomNum())
	return cloud
end

---@param position Vector
---@param velocity? Vector
---@param spawner? Entity
---@param seed? integer
---@param amount? integer
---@return EntityEffect[]
function Spawn.DustClouds(position, velocity, spawner, seed, amount)
	local clouds = {}
	for _ = 1, amount or 5 do
		clouds[#clouds + 1] = Spawn.DustCloud(position, velocity, spawner, seed)
	end
	return clouds
end

---@param spawner Entity
---@param trailLength number @Recommended float. Smaller the number, longer the trail
function Spawn.Trail(spawner, trailLength)
	local trail = spawnEffect(EffectVariant.SPRITE_TRAIL, 0, spawner.Position, Vector.Zero, spawner)
	trail.MinRadius = trailLength
	trail.Parent = spawner
	trail:Update()
	return trail
end

---@alias NotificationSubType
---|0 #Heart
---|1 #Battery Up
---|2 #Backstabber
---|3 #Battery Down
---|4 #Soul Heart
---|5 #Black Heart

local subTypeToSFX = {
	[0] = SoundEffect.SOUND_VAMP_GULP,
	[1] = SoundEffect.SOUND_BATTERYCHARGE,
	[2] = SoundEffect.SOUND_MEATY_DEATHS,
	[3] = SoundEffect.SOUND_BATTERYDISCHARGE,
	[4] = SoundEffect.SOUND_HOLY,
	[5] = SoundEffect.SOUND_UNHOLY
}

local sfxman = SFXManager()

---@param pos Vector
---@param notifType NotificationSubType
---@param playSFX? boolean Default: `false`
function Spawn.Notification(pos, notifType, playSFX)
	local effect = spawnEffect(EffectVariant.HEART, notifType, pos)

	effect:GetSprite().Offset = Vector(0, -24)
	effect.DepthOffset = 1

	if playSFX then
		sfxman:Play(subTypeToSFX[notifType])
	end
	return effect
end

---@alias HolyBeamType
---|0  #Default. Instant Crack the Sky. 17 frames of hitbox
---|1  #2 frames of hitbox before turning into SubType 10
---|2  #Delayed with a visual cue. 17 frames of hitbox
---|10 #Visual only, no hitbox

---@param beamType HolyBeamType
---@param pos Vector
---@param spawner Entity
---@param parent Entity
---@param damage number
function Spawn.HolyBeam(beamType, pos, spawner, parent, damage)
	local beam = spawnEffect(EffectVariant.CRACK_THE_SKY, beamType, pos, Vector.Zero, spawner)
		:ToEffect()
	---@cast beam EntityEffect

	beam.Parent = parent
	beam.CollisionDamage = damage
	beam:Update()
	return beam
end

--#endregion

return Spawn