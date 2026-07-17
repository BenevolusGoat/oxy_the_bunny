local Mod = OxyTheBunny

---@param chainsaw EntityEffect
local function fireEvilEye(_, chainsaw, tearFlags, pos)
	local player = chainsaw.SpawnerEntity and chainsaw.SpawnerEntity:ToPlayer()
	if not player then return end
	local velDir = (pos - chainsaw.Position):Resized(10 * player.ShotSpeed)
	local tear = player:FireTear(player.Position, velDir, true, true, false, player, 1)
	tear:Remove()
	Mod.SFXMan:Stop(SoundEffect.SOUND_TEARS_FIRE)
end

Mod:AddCallback(Mod.ModCallbacks.CHAINSAW_ON_ARC_PEAK, fireEvilEye)