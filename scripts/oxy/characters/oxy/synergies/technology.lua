local Mod = OxyTheBunny

---@param player EntityPlayer
local function technology(_, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
		return "gfx/effects/weapon_chainsaw_tech.png"
	end
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_GET_SKIN, technology)

---@param player EntityPlayer
local function techRing(_, _, _, player)
	for i = 1, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY) do
		local ring = EntityLaser.ShootAngle(LaserVariant.THIN_RED, player.Position, 0, 2, Vector(0, -10), player)
		ring.Radius = 58 + (15 * (i - 1))
		ring.SubType = LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT
		local laserParams = player:GetTearHitParams(WeaponType.WEAPON_LASER, 1, Mod.Item.CHAINSAW:GetTearDisplacement(player, false), ring)
		ring.Color = laserParams.TearColor
		ring:AddTearFlags(laserParams.TearFlags)
		ring:SetDisableFollowParent(false)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_CHAINSAW_FIRE, techRing)