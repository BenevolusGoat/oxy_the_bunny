local Mod = OxyTheBunny
local floor = math.floor

local BORING_HORROR = {}

OxyTheBunny.Item.BORING_HORROR = BORING_HORROR

BORING_HORROR.ID = Isaac.GetItemIdByName("The Counterpart")

---@param player EntityPlayer
---@param ent Entity
function BORING_HORROR:FireOOBTear(player, ent)
	local room = Mod.Room()
	local topLeft = room:GetTopLeftPos()
	local bottomRight = room:GetBottomRightPos()
	local rng = Mod.GENERIC_RNG
	local roomSide = rng:RandomInt(4)
	local pos
	--Left/Right
	if roomSide % 2 == 0 then
		local randomY = rng:RandomInt(floor(bottomRight.Y - topLeft.Y))
		local x = roomSide == Direction.LEFT and topLeft.X or bottomRight.X
		pos = Vector(x, randomY)
	else --Up/Down
		local randomX = rng:RandomInt(floor(bottomRight.X - topLeft.X))
		local y = roomSide == Direction.UP and topLeft.Y or bottomRight.Y
		pos = Vector(randomX, y)
	end
	local center = room:GetCenterPos()
	--Push position 2 tiles away from the center of the room
	pos = pos + (pos - center):Resized(80)
	local tear = player:FireTear(pos, Vector.Zero, false, true, false, player, 1)
	local color = tear:GetSprite().Color
	color.A = 0
	tear:SetColor(color, 15, 1, true, false)
	tear.CollisionDamage = tear.CollisionDamage / 2
	tear:ResetSpriteScale(true)
	tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING)
	tear:AddVelocity((ent.Position - pos):Resized(20))
	Mod:GetData(tear).BoringHorror = true
end

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function BORING_HORROR:OnTakeDamage(ent, amount, flags, source, countdown)
	if amount > 0
		and ent:ToNPC()
		and ent:IsActiveEnemy(false)
		and ent:IsVulnerableEnemy()
		and not ent:IsInvincible()
		and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		and source.Entity
	then
		local data = Mod:TryGetData(source.Entity)
		if data and data.BoringHorror then
			return
		end
		local player = Mod:TryGetPlayer(source)
		if player and player:HasCollectible(BORING_HORROR.ID) then
			BORING_HORROR:FireOOBTear(player, ent)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, BORING_HORROR.OnTakeDamage)