local Mod = OxyTheBunny

--#region Helpers

---@param player EntityPlayer
---@return boolean
---@function
function OxyTheBunny:IsShooting(player)
	if player.ControlsCooldown > 0 or not player.ControlsEnabled then
		return false
	end
	return RoomTransition.GetTransitionMode() > 0 and player:GetShootingInput():Length() >= 0.5 or player:GetAimDirection():Length() >= 0.5
end

---@param player EntityPlayer
---@return Vector?
function OxyTheBunny:TryGetMarkedTargetAimVector(player)
	local target = player:GetMarkedTarget()
	if target then
		return (target.Position - player.Position):Normalized()
	end
end

--#endregion

--#region Tracking last player input

---@param player EntityPlayer
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	player:GetData().OXY_LastAttackDirection = Vector.Zero
end)

local attackInputs = {
	[ButtonAction.ACTION_SHOOTLEFT] = Vector(-1,0),
	[ButtonAction.ACTION_SHOOTRIGHT] = Vector(1,0),
	[ButtonAction.ACTION_SHOOTUP] = Vector(0,-1),
	[ButtonAction.ACTION_SHOOTDOWN] = Vector(0,1)
}
--Amount of frames (in 60 fps) that your last diagonal inputs are saved
local DIAGONAL_INPUT_INTERVAL = 7
local DIAGONAL_DIR = 0.70710676908493

---@param player EntityPlayer
Mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, function(_, player)
	if player:GetFireDirection() ~= Direction.NO_DIRECTION then
		player:GetData().OXY_LastAttackDirection = Mod:GetAttackDirection(player)
	end
	local oppositesPressed = player:AreOpposingShootDirectionsPressed()
	local data = player:GetData()
	data.OXY_LastInputs = data.OXY_LastInputs or {}
	for button, _ in pairs(attackInputs) do
		if Input.IsActionPressed(button, player.ControllerIndex) then
			if oppositesPressed then
				data.OXY_LastInputs[button] = nil
			else
				data.OXY_LastInputs[button] = DIAGONAL_INPUT_INTERVAL
			end
		elseif data.OXY_LastInputs[button] then
			if data.OXY_LastInputs[button] > 0 then
				data.OXY_LastInputs[button] = data.OXY_LastInputs[button] - 1
			else
				data.OXY_LastInputs[button] = nil
			end
		end
	end
end)

--#endregion

--#region Tracking last familiar input

---@param familiar EntityFamiliar
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
	if familiar:GetWeapon() then
		familiar:GetData().OXY_LastAttackDirection = {AimDirection = Vector.Zero, Direction = -1, TargetPos = nil, AutoAim = false}
	end
end)

---@param familiar EntityFamiliar
Mod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CallbackPriority.LATE, function(_, familiar)
	if familiar:GetWeapon() and familiar.ShootDirection ~= Direction.NO_DIRECTION then
		familiar:GetData().OXY_LastAttackDirection = Mod:GetFamiliarAttackInfo(familiar)
	end
end)

---Returns information on the expected direction for the familiar to fire in. Takes all familiar-related synergies into account
---@param familiar EntityFamiliar
---@param allowLastShotDirection? boolean
---@return {AimDirection: Vector, Direction: Direction, TargetPos: Vector?, AutoAim: boolean}
function OxyTheBunny:GetFamiliarAttackInfo(familiar, allowLastShotDirection)
	---@diagnostic disable-next-line: missing-parameter
	local autoAim, attackTable = familiar:TryAimAtMarkedTarget()
	if autoAim then
		---@diagnostic disable-next-line: need-check-nil
		return {AimDirection = attackTable[1], Direction = attackTable[2], TargetPos = attackTable[3], AutoAim = true}
	end
	local fireDir = familiar:GetWeapon() and familiar.ShootDirection or Mod:GetFireDirection(familiar.Player)
	if allowLastShotDirection and fireDir == Direction.NO_DIRECTION then
		return familiar:GetData().OXY_LastAttackDirection
	elseif familiar:GetWeapon() and familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
		return Mod:GetAimDirection(familiar.Player)
	else
		local vec = Mod:DirectionToVector(fireDir)
		return {AimDirection = vec, Direction = fireDir, TargetPos = nil, AutoAim = false}
	end
end

---@param familiar EntityFamiliar
---@param allowLastShotDirection? boolean
function OxyTheBunny:GetFamiliarAttackDirection(familiar, allowLastShotDirection)
	return Mod:GetFamiliarAttackInfo(familiar, allowLastShotDirection).AimDirection
end

--#endregion

--#region Primary attack functions

--Info on the vanilla shooting functions. Identical across keyboard and controller:
--FireDirection: Returns exact expected direction to fire, not a vector. -1 on room transition
--GetAimDirection: Returns "balanced" 360 Vector, will average if more than one button is pressed, not fully accurate to expected fire direction unless 360 input is allowed. Length is 0 on room transition.
--GetShootingInput:  Returns 360 Vector, adds all inputs together resulting in improper vectors for fire direction. Does not reset on room transition. Only best for detecting if you're firing through room transition
--GetShootingJoystick: Identical to GetShootingInput

-- Custom implementation of GetAimDirection that doesn't reset between rooms.
---@param player EntityPlayer
function OxyTheBunny:GetAimDirection(player)
	local isMouseEnabled = Options.MouseControl
	local aimVector = Vector.Zero

	--Mouse
	if isMouseEnabled and Input.IsMouseBtnPressed(MouseButton.LEFT) and player.ControllerIndex == 0 then
		local mousePos = Input.GetMousePosition(true)
		local direction = (mousePos - player.Position):Normalized()
		aimVector = direction
	end

	--Keyboard & Controller
	if not isMouseEnabled and Mod:IsShooting(player) then
		if RoomTransition.GetTransitionMode() > 0 and player:GetShootingInput():Length() > 0 then
			return player:GetData().OXY_LastAttackDirection
		else
			aimVector = player:GetAimDirection()
		end
	end

	--Marked
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		local targetAimVector = Mod:TryGetMarkedTargetAimVector(player)
		if targetAimVector then
			aimVector = targetAimVector
		end
	end

	return aimVector
end

-- Custom implementation of GetFireDirection that doesn't reset between rooms.
---@param player EntityPlayer
---@param aimDir? Vector
---@return Direction
function OxyTheBunny:GetFireDirection(player, aimDir)
	if RoomTransition.GetTransitionMode() > 0 and player:GetShootingInput():Length() > 0 or aimDir then
		local aimVec = aimDir or player:GetData().OXY_LastAttackDirection
		local angle = aimVec:GetAngleDegrees()
		local dir = ((angle + 45) // 90) * 90
		local angleToDir = {
			[0] = Direction.RIGHT,
			[90] = Direction.DOWN,
			[180] = Direction.LEFT,
			[-180] = Direction.LEFT,
			[-90] = Direction.UP,
		}
		return angleToDir[dir]
	else
		return player:GetFireDirection()
	end
end

---Returns the expected direction for the player to fire in, taking collectibles into account.
---@param player EntityPlayer
---@param allowLastShotDirection? boolean @If `true`, if the player isn't firing, will return the direction they last attacked in instead of `Vector.Zero`
---@param allow360? boolean @Bypasses Analog Stick requirement
---@return Vector direction
function OxyTheBunny:GetAttackDirection(player, allowLastShotDirection, allow360)
	local finalShootingDir = Vector.Zero
	local aimDir = Mod:GetAimDirection(player)
	local fireDir = Mod:GetFireDirection(player)
	local fireDirVec = Mod:DirectionToVector(fireDir)
	local canShoot360 = player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
		or allow360

	if allowLastShotDirection
		and player:GetData().OXY_LastAttackDirection
		and not Mod:IsShooting(player)
	then
		local data = player:GetData()
		local newVec
		if not player:GetMarkedTarget() and canShoot360 then
			for input, _ in pairs(data.OXY_LastInputs or {}) do
				if not newVec then
					newVec = attackInputs[input]
				else
					newVec = (newVec + attackInputs[input]) * DIAGONAL_DIR
					return newVec
				end
			end
		end
		return player:GetData().OXY_LastAttackDirection
	end

	if canShoot360 then
		if aimDir.X ~= 0 or aimDir.Y ~= 0 then
			finalShootingDir = Vector(aimDir.X, aimDir.Y)
		end
	elseif fireDir ~= Direction.NO_DIRECTION then
		finalShootingDir = fireDirVec
	end

	return finalShootingDir
end

--#endregion

--#region Render inputs

--[[ local inputToName = {
	[ButtonAction.ACTION_SHOOTLEFT] = "LEFT: ",
	[ButtonAction.ACTION_SHOOTRIGHT] = "RIGHT: ",
	[ButtonAction.ACTION_SHOOTUP] = "UP: ",
	[ButtonAction.ACTION_SHOOTDOWN] = "DOWN: ",
}

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player, offset)
	local renderPos = Mod:GetEntityRenderPos(player, offset)
	local data = player:GetData()
	if not data.OXY_LastInputs then
		return
	end
	for i = ButtonAction.ACTION_SHOOTLEFT, ButtonAction.ACTION_SHOOTDOWN do
		local result = "X"
		if data.OXY_LastInputs[i] then
			result = tostring(data.OXY_LastInputs[i])
		end
		Isaac.RenderText(inputToName[i] .. result, renderPos.X + 15, renderPos.Y - 60 + (i - 3) * 15, 1, 1, 1, 1)
		local pressed = Input.IsActionPressed(i, player.ControllerIndex)
		Isaac.RenderText(pressed and "Y" or "X", renderPos.X - 20, renderPos.Y - 60 + (i - 3) * 15, 1, 1, 1, 1)
	end
	Isaac.RenderText("Opposites?: " .. tostring(player:AreOpposingShootDirectionsPressed()), renderPos.X - 20, renderPos.Y + 20, 1, 1, 1, 1)
	local aimDir = player:GetAimDirection()
	Isaac.RenderText("Aim Dir: " .. tostring(aimDir.X) .. ", " .. aimDir.Y, renderPos.X - 20, renderPos.Y + 40, 1, 1, 1, 1)
end) ]]

--#endregion