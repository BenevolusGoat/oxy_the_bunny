local settings = OxyTheBunny.SaveManager.DEFAULT_SAVE.file.settings
settings.Debug = {
	MonsterDexOverride = true
}
function OxyTheBunny:GameSave()
	return OxyTheBunny.SaveManager.GetPersistentSave()
end

---@param ent? Entity @If an entity is provided, returns an entity specific save within the run save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass? false|boolean @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table @Can return nil if data has not been loaded, or the manager has not been initialized. Will create data if none exists.
function OxyTheBunny:RunSave(ent, noHourglass, allowSoulSave)
	return OxyTheBunny.SaveManager.GetRunSave(ent, noHourglass, allowSoulSave)
end

---@param ent? Entity  @If an entity is provided, returns an entity specific save within the floor save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass? false|boolean @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table @Can return nil if data has not been loaded, or the manager has not been initialized. Will create data if none exists.
function OxyTheBunny:FloorSave(ent, noHourglass, allowSoulSave)
	return OxyTheBunny.SaveManager.GetFloorSave(ent, noHourglass, allowSoulSave)
end

---@param ent? Entity | integer @If an entity is provided, returns an entity specific save within the room save, which is a floor-lasting save that has unique data per-room. If a grid index is provided, returns a grid index specific save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass? false|boolean @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param listIndex? integer @Returns data for the provided `listIndex` instead of the index of the current room.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table @Can return nil if data has not been loaded, or the manager has not been initialized. Will create data if none exists.
function OxyTheBunny:RoomSave(ent, noHourglass, listIndex, allowSoulSave)
	return OxyTheBunny.SaveManager.GetRoomSave(ent, noHourglass, listIndex, allowSoulSave)
end

---@param ent? Entity | integer  @If an entity is provided, returns an entity specific save within the room save. If a grid index is provided, returns a grid index specific save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass? false|boolean @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param allowSoulSave? boolean @If true, if the `ent` is The Soul attached to The Forgotten, will return a differently indexed save, as opposed to a shared save between the two.
---@return table @Can return nil if data has not been loaded, or the manager has not been initialized. Will create data if none exists.
function OxyTheBunny:TempSave(ent, noHourglass, allowSoulSave)
	return OxyTheBunny.SaveManager.GetTempSave(ent, noHourglass, allowSoulSave)
end

---@param pickup EntityPickup
---@param persistOnReroll? boolean
function OxyTheBunny:PickupSave(pickup, persistOnReroll)
	if persistOnReroll then
		return OxyTheBunny.SaveManager.GetRerollPickupSave(pickup)
	else
		return OxyTheBunny.SaveManager.GetNoRerollPickupSave(pickup)
	end
end

function OxyTheBunny:AddDefaultFileData(key, value)
	OxyTheBunny.SaveManager.DEFAULT_SAVE.file.other[key] = value
end
