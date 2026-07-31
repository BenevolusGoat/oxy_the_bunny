local Mod = OxyTheBunny

local MUTUS_LIBER = {}

OxyTheBunny.Item.MUTUS_LIBER = MUTUS_LIBER

MUTUS_LIBER.ID = Isaac.GetItemIdByName("Mutus Liber")

MUTUS_LIBER.PICKUP_MAP = {
	[PickupVariant.PICKUP_HEART] = {
		[HeartSubType.HEART_FULL] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL },
		[HeartSubType.HEART_HALF] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_HALF_SOUL },
		[HeartSubType.HEART_SOUL] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_FULL },
		[HeartSubType.HEART_ETERNAL] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_BLACK },
		[HeartSubType.HEART_BLACK] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_ETERNAL },
		[HeartSubType.HEART_HALF_SOUL] = 			{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_HALF },
		[HeartSubType.HEART_BONE] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_ROTTEN },
		[HeartSubType.HEART_ROTTEN] = 				{ Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_BONE }
	},
	[PickupVariant.PICKUP_COIN] = {
		[CoinSubType.COIN_LUCKYPENNY] = 			{ Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_STICKYNICKEL },
		[CoinSubType.COIN_STICKYNICKEL] = 			{ Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_LUCKYPENNY }
	},
	[PickupVariant.PICKUP_KEY] = {
		[KeySubType.KEY_NORMAL] = 					{ Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_NORMAL },
		[KeySubType.KEY_GOLDEN] = 					{ Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_GOLDEN },
		[KeySubType.KEY_DOUBLEPACK] = 				{ Variant = PickupVariant.PICKUP_BOMB, SubType = BombSubType.BOMB_DOUBLEPACK }
	},
	[PickupVariant.PICKUP_BOMB] = {
		[BombSubType.BOMB_NORMAL] = 				{ Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_NORMAL },
		[BombSubType.BOMB_DOUBLEPACK] = 			{ Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_DOUBLEPACK },
		[BombSubType.BOMB_GOLDEN] = 				{ Variant = PickupVariant.PICKUP_KEY, SubType = KeySubType.KEY_GOLDEN }
	},
	[PickupVariant.PICKUP_TAROTCARD] = {
		[Card.CARD_FOOL] = 							{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_FOOL },
		[Card.CARD_MAGICIAN] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_MAGICIAN },
		[Card.CARD_HIGH_PRIESTESS] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_HIGH_PRIESTESS },
		[Card.CARD_EMPRESS] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_EMPRESS },
		[Card.CARD_EMPEROR] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_EMPEROR },
		[Card.CARD_HIEROPHANT] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_HIEROPHANT },
		[Card.CARD_LOVERS] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_LOVERS },
		[Card.CARD_CHARIOT] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_CHARIOT },
		[Card.CARD_JUSTICE] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_JUSTICE },
		[Card.CARD_HERMIT] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_HERMIT },
		[Card.CARD_WHEEL_OF_FORTUNE] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_WHEEL_OF_FORTUNE },
		[Card.CARD_STRENGTH] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_STRENGTH },
		[Card.CARD_HANGED_MAN] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_HANGED_MAN },
		[Card.CARD_DEATH] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_DEATH },
		[Card.CARD_TEMPERANCE] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_TEMPERANCE },
		[Card.CARD_DEVIL] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_DEVIL },
		[Card.CARD_TOWER] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_TOWER },
		[Card.CARD_STARS] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_STARS },
		[Card.CARD_MOON] = 							{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_MOON },
		[Card.CARD_SUN] = 							{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_SUN },
		[Card.CARD_JUDGEMENT] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_JUDGEMENT },
		[Card.CARD_WORLD] = 						{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_REVERSE_WORLD },
		[Card.CARD_REVERSE_FOOL] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_FOOL },
		[Card.CARD_REVERSE_MAGICIAN] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_MAGICIAN },
		[Card.CARD_REVERSE_HIGH_PRIESTESS] = 		{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_HIGH_PRIESTESS },
		[Card.CARD_REVERSE_EMPRESS] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_EMPRESS },
		[Card.CARD_REVERSE_EMPEROR] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_EMPEROR },
		[Card.CARD_REVERSE_HIEROPHANT] = 			{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_HIEROPHANT },
		[Card.CARD_REVERSE_LOVERS] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_LOVERS },
		[Card.CARD_REVERSE_CHARIOT] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_CHARIOT },
		[Card.CARD_REVERSE_JUSTICE] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_JUSTICE },
		[Card.CARD_REVERSE_HERMIT] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_HERMIT },
		[Card.CARD_REVERSE_WHEEL_OF_FORTUNE] = 		{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_WHEEL_OF_FORTUNE },
		[Card.CARD_REVERSE_STRENGTH] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_STRENGTH },
		[Card.CARD_REVERSE_HANGED_MAN] = 			{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_HANGED_MAN },
		[Card.CARD_REVERSE_DEATH] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_DEATH },
		[Card.CARD_REVERSE_TEMPERANCE] = 			{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_TEMPERANCE },
		[Card.CARD_REVERSE_DEVIL] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_DEVIL },
		[Card.CARD_REVERSE_TOWER] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_TOWER },
		[Card.CARD_REVERSE_STARS] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_STARS },
		[Card.CARD_REVERSE_MOON] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_MOON },
		[Card.CARD_REVERSE_SUN] = 					{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_SUN },
		[Card.CARD_REVERSE_JUDGEMENT] = 			{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_JUDGEMENT },
		[Card.CARD_REVERSE_WORLD] = 				{ Variant = PickupVariant.PICKUP_TAROTCARD, SubType = Card.CARD_WORLD }
	},
}

---@type {[PillEffect]: PillEffect}
MUTUS_LIBER.PILL_EFFECT_MAP = {
	[PillEffect.PILLEFFECT_AMNESIA] =			PillEffect.PILLEFFECT_SEE_FOREVER,
	[PillEffect.PILLEFFECT_SEE_FOREVER] =		PillEffect.PILLEFFECT_AMNESIA,
	[PillEffect.PILLEFFECT_QUESTIONMARK] =		PillEffect.PILLEFFECT_TELEPILLS,
	[PillEffect.PILLEFFECT_TELEPILLS] =			PillEffect.PILLEFFECT_QUESTIONMARK,
	[PillEffect.PILLEFFECT_ADDICTED] =			PillEffect.PILLEFFECT_PERCS,
	[PillEffect.PILLEFFECT_PERCS] =				PillEffect.PILLEFFECT_ADDICTED,
	[PillEffect.PILLEFFECT_IM_EXCITED] =		PillEffect.PILLEFFECT_IM_DROWSY,
	[PillEffect.PILLEFFECT_IM_DROWSY] =			PillEffect.PILLEFFECT_IM_EXCITED,
	[PillEffect.PILLEFFECT_PARALYSIS] =			PillEffect.PILLEFFECT_PHEROMONES,
	[PillEffect.PILLEFFECT_PHEROMONES] =		PillEffect.PILLEFFECT_PARALYSIS,
	[PillEffect.PILLEFFECT_RETRO_VISION] =		PillEffect.PILLEFFECT_SEE_FOREVER,
	[PillEffect.PILLEFFECT_WIZARD] =			PillEffect.PILLEFFECT_POWER,
	[PillEffect.PILLEFFECT_POWER] =				PillEffect.PILLEFFECT_WIZARD,
	[PillEffect.PILLEFFECT_X_LAX] =				PillEffect.PILLEFFECT_SOMETHINGS_WRONG,
	[PillEffect.PILLEFFECT_SOMETHINGS_WRONG] =	PillEffect.PILLEFFECT_X_LAX,
	[PillEffect.PILLEFFECT_BAD_TRIP] =			PillEffect.PILLEFFECT_BALLS_OF_STEEL,
	[PillEffect.PILLEFFECT_BALLS_OF_STEEL] =	PillEffect.PILLEFFECT_BAD_TRIP,
	[PillEffect.PILLEFFECT_RANGE_UP] =			PillEffect.PILLEFFECT_RANGE_DOWN,
	[PillEffect.PILLEFFECT_RANGE_DOWN] =		PillEffect.PILLEFFECT_RANGE_UP,
	[PillEffect.PILLEFFECT_SPEED_UP] =			PillEffect.PILLEFFECT_SPEED_DOWN,
	[PillEffect.PILLEFFECT_SPEED_DOWN] =		PillEffect.PILLEFFECT_SPEED_UP,
	[PillEffect.PILLEFFECT_TEARS_UP] =			PillEffect.PILLEFFECT_TEARS_DOWN,
	[PillEffect.PILLEFFECT_TEARS_DOWN] =		PillEffect.PILLEFFECT_TEARS_UP,
	[PillEffect.PILLEFFECT_LUCK_UP] =			PillEffect.PILLEFFECT_LUCK_DOWN,
	[PillEffect.PILLEFFECT_LUCK_DOWN] =			PillEffect.PILLEFFECT_LUCK_UP
}

---@param item any
---@param rng RNG
---@param player any
---@param flags UseFlag
function MUTUS_LIBER:OnUse(item, rng, player, flags)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then return end
	Mod.Foreach.Pickup(function (pickup, index)
		local transformedData = MUTUS_LIBER.PICKUP_MAP[pickup.Variant] and MUTUS_LIBER.PICKUP_MAP[pickup.Variant][pickup.SubType]
		if transformedData then
			if transformedData.Variant == PickupVariant.PICKUP_TAROTCARD then
				local itemConfig = Mod.ItemConfig:GetCard(transformedData.SubType)
				if not itemConfig then return end
				local isAvailable = itemConfig:IsAvailable()
				local card = isAvailable and transformedData.SubType or Mod.Game:GetItemPool():GetCard(rng:Next(), true, false, false)
				pickup:Morph(pickup.Type, transformedData.Variant, card)
			else
				local variant, subtype = Mod.Spawn.CheckPickupUnlocks(transformedData.Variant, transformedData.SubType)
				pickup:Morph(EntityType.ENTITY_PICKUP, variant, subtype)
			end
		elseif pickup.Variant == PickupVariant.PICKUP_PILL then
			local itemPool = Mod.Game:GetItemPool()
			local curPillColor = pickup.SubType
			local isHorsePill = Mod:HasBitFlags(curPillColor, PillColor.PILL_GIANT_FLAG)
			local curPillEffect = itemPool:GetPillEffect(curPillColor)
			local newPillEffect = MUTUS_LIBER.PILL_EFFECT_MAP[curPillEffect]
			if not newPillEffect then return end
			local newPillColor = itemPool:GetPillColor(newPillEffect)
			if newPillColor == -1 then
				newPillColor = itemPool:ForceAddPillEffect(newPillEffect)
			end
			if isHorsePill then
				newPillColor = newPillColor | PillColor.PILL_GIANT_FLAG
			end
			pickup:Morph(pickup.Type, PickupVariant.PICKUP_PILL, newPillColor)
		end
	end)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, MUTUS_LIBER.OnUse, MUTUS_LIBER.ID)