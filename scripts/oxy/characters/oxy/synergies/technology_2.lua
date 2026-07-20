local Mod = OxyTheBunny

---@param data table
---@return EntityLaser?
local function tryGetLaser(data)
	return data.Tech2Laser and data.Tech2Laser.Ref and data.Tech2Laser.Ref:ToLaser()
end

---@param player EntityPlayer \
local function postPeffectUpdate(_, player)
	if not Mod.Item.CHAINSAW:CanUseChainsaw(player)
		or not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)
	then
		return
	end
	local data = Mod:GetData(player)
	local laser = tryGetLaser(data)
	local dir = Mod:GetAttackDirection(player, true, true)
	if laser then
		laser.Position = player.Position
		laser.PositionOffset = player:GetLaserOffset(LaserOffset.LASER_TECH2_OFFSET, dir)
	end
	if Mod:IsShooting(player) then
		if not laser then
			laser = EntityLaser.ShootAngle(LaserVariant.THIN_RED, player.Position, dir:GetAngleDegrees(), 2, player:GetLaserOffset(LaserOffset.LASER_TECH2_OFFSET, dir), player)
			laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
			laser:SetInitSound(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK)
			laser.CollisionDamage = player.Damage * 0.2
			data.Tech2Laser = EntityPtr(laser)
		end
		laser.AngleDegrees = dir:GetAngleDegrees()
		laser.Timeout = 2
		local headDir = player:GetHeadDirection()
		--Above
		if headDir == Direction.UP or headDir == Direction.LEFT then
			laser.DepthOffset = -10
		else --Below
			laser.DepthOffset = 3000
		end
	elseif laser then
		laser:Remove()
		data.Tech2Laser = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)
