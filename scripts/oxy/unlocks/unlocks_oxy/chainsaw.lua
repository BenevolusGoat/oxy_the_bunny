local Mod = OxyTheBunny

local CHAINSAW = {}

OxyTheBunny.Item.CHAINSAW = CHAINSAW

CHAINSAW.ID = Isaac.GetItemIdByName("Chainsaw")
CHAINSAW.KNIFE = Isaac.GetEntityVariantByName("Oxy's Chainsaw")

CHAINSAW.DEFAULT_HIT_COUNTDOWN = 3

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
---@return EntityKnife?
function CHAINSAW:TryGetChainsaw(player)
	local data = player:GetData()
	return data and data.ActiveChainsaw and data.ActiveChainsaw.Ref and data.ActiveChainsaw.Ref:ToKnife()
end

---@param player EntityPlayer
function CHAINSAW:IsActive(player)
	return CHAINSAW:TryGetChainsaw(player) ~= nil
end

---@param player EntityPlayer
function CHAINSAW:SpawnChainsaw(player)
	local fireDir = Mod:GetAttackDirection(player)
	local angle = fireDir:GetAngleDegrees() - 90
	local chainsaw = player:FireKnife(player, angle + 180, true, KnifeSubType.CLUB_HITBOX, CHAINSAW.KNIFE)
	local sprite = chainsaw:GetSprite()
	local data = player:GetData()
	data.ActiveChainsaw = EntityPtr(chainsaw)
	chainsaw.Rotation = angle
	sprite.Rotation = angle
	chainsaw:SetIsSwinging(true)
	sprite:Play("Swing", true)
	chainsaw.Parent = player
	local weapon = player:GetWeapon(1)
	if weapon then
		weapon:SetFireDelay(weapon:GetMaxFireDelay())
	end
end

---@param chainsaw EntityKnife
local function damageInCapsule(chainsaw, capsule, damage, source, hitEnemies)
	for _, ent in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
		local npc = ent:ToNPC()
		if npc and npc:IsVulnerableEnemy() and not hitEnemies[ent.Index] then
			npc:TakeDamage(damage, 0, source, 0)
			npc:ApplyTearflagEffects(npc.Position, chainsaw.TearFlags, chainsaw, damage)
			hitEnemies[ent.Index] = CHAINSAW.DEFAULT_HIT_COUNTDOWN
			Mod.SFXMan:Play(SoundEffect.SOUND_MEATY_DEATHS)
		end
	end
end

---@param chainsaw EntityKnife
function CHAINSAW:HitboxUpdate(chainsaw)
	local capsule1 = chainsaw:GetNullCapsule("Hit")
	local capsule2 = chainsaw:GetNullCapsule("Hit2")
	local capsuleTip = chainsaw:GetNullCapsule("tip")
	local data = chainsaw:GetData()
	data.HitList = data.HitList or {}
	local hitEnemies = data.HitList
	local source = EntityRef(chainsaw)
	local dmg = chainsaw.CollisionDamage
	local sprite = chainsaw:GetSprite()
	local null1 = sprite:GetNullFrame("Hit")
	local null2 = sprite:GetNullFrame("Hit2")
	local nullTip = sprite:GetNullFrame("tip")

	for index, countdown in pairs(hitEnemies) do
		if countdown > 0 then
			hitEnemies[index] = hitEnemies[index] - 1
		else
			hitEnemies[index] = nil
		end
	end

	if nullTip and nullTip:IsVisible() then
		damageInCapsule(chainsaw, capsuleTip, dmg * 2, source, hitEnemies)
	end
	if null1 and null1:IsVisible() then
		damageInCapsule(chainsaw, capsule1, dmg, source, hitEnemies)
	end
	if null2 and null2:IsVisible() then
		damageInCapsule(chainsaw, capsule2, dmg, source, hitEnemies)
	end
end

---@param chainsaw EntityKnife
function CHAINSAW:ChainsawUpdate(chainsaw)
	if chainsaw.Variant ~= CHAINSAW.KNIFE then return end

	if not chainsaw.Parent then
		chainsaw:Remove()
		return
	end

	chainsaw.Position = chainsaw.Parent.Position

	if chainsaw:GetSprite():IsEventTriggered("Woosh") then
		Mod.SFXMan:Play(SoundEffect.SOUND_SWORD_SPIN)
	end

	CHAINSAW:HitboxUpdate(chainsaw)
end

Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, CHAINSAW.ChainsawUpdate, KnifeSubType.CLUB_HITBOX)

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
		local fireDir = Mod:GetAttackDirection(player)
		local angle = fireDir:GetAngleDegrees() - 90
		chainsaw.Rotation = angle
		sprite.Rotation = angle
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