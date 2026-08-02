local Mod = OxyTheBunny

---@param player EntityPlayer
local function maxCharge(_, player)
	local weapon = player:GetWeapon(1)
	---@cast weapon Weapon

	if Mod:HasBitFlags(weapon:GetModifiers(), WeaponModifier.CHOCOLATE_MILK) then
		return weapon:GetMaxCharge() * 0.75
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_GET_MAX_CHARGE, maxCharge)

local MIN_DAMAGE_MULTIPLIER = 0.1
local MAX_DAMAGE_MULTIPLIER = 4
local MIN_SCALE_MULTIPLIER = 0.5
local MAX_SCALE_MULTIPLIER = 1.5

---@param player EntityPlayer
---@param data PlayerChainsawData
---@param isShooting boolean
---@param onCooldown boolean
local function chocPeffectUpdate(_, player, data, isShooting, onCooldown)
	local weapon = player:GetWeapon(1)
	local modifiers = weapon and weapon:GetModifiers()
	if not (weapon
			and modifiers
			and Mod:HasBitFlags(modifiers, WeaponModifier.CHOCOLATE_MILK)
			and not Mod:HasBitFlags(modifiers, WeaponModifier.CURSED_EYE)
			and data.MaxCharge > 0
		)
	then
		return
	end
	local soyMode = Mod:HasBitFlags(modifiers, WeaponModifier.SOY_MILK)
	if isShooting then
		if not player:HasEntityFlags(EntityFlag.FLAG_INTERPOLATION_UPDATE) and data.Charge < data.MaxCharge then
			data.Charge = data.Charge + 1
		end
	end
	if (data.Charge > 0 and not isShooting) or (data.Charge >= data.MaxCharge and soyMode) then
		--TODO: This needs to increase with firerate
		local minDamageMult = Mod:Clamp(MIN_DAMAGE_MULTIPLIER, MIN_DAMAGE_MULTIPLIER, MAX_DAMAGE_MULTIPLIER)
		local damageScale = Mod:Lerp(minDamageMult,	MAX_DAMAGE_MULTIPLIER, data.Charge / data.MaxCharge)
		local chainsaws = Mod.Item.CHAINSAW:WeaponFire(player, damageScale)
		for i, chainsawData in ipairs(chainsaws) do
			local chainsaw = chainsawData.Pointer.Ref
			---@cast chainsaw Entity
			local scale = Mod:Lerp(MIN_SCALE_MULTIPLIER, MAX_SCALE_MULTIPLIER, data.Charge / data.MaxCharge)
			if soyMode then
				scale = scale / 2
			end
			chainsaw.SpriteScale = chainsaw.SpriteScale * scale
		end
		data.Charge = 0
		local durationMult = data.Weapons[1] and data.Weapons[1].Pointer.Ref:GetSprite().PlaybackSpeed or 1
		player:SetHeadDirection(Mod:VectorToDirection(Mod:GetAttackDirection(player, true, true)), math.ceil(16 / durationMult), true)
	end
	if isShooting and #data.Weapons > 0 then
		player:SetHeadDirection(Mod:VectorToDirection(Mod:GetAttackDirection(player, true, true)), 2, true)
	end
	return false
end

Mod:AddPriorityCallback(Mod.ModCallbacks.CHAINSAW_CAN_FIRE, CallbackPriority.LATE, chocPeffectUpdate)
