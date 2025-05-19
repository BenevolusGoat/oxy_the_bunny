---@enum FurtheranceCallbacks
OxyTheBunny.ModCallbacks = {

}

OxyTheBunny.UniqueCallbackHandling = {

}

---@param id FurtheranceCallbacks
---@return any
function OxyTheBunny.RunUniqueCallback(id, ...)
	local callbackName = string.gsub(id, "FURTHERANCE", "")
	if OxyTheBunny.UniqueCallbackHandling[callbackName] then
		local callbacks = Isaac.GetCallbacks(id, true)
		table.sort(callbacks, function(a, b)
			return a.Priority < b.Priority
		end)
		return OxyTheBunny.UniqueCallbackHandling[callbackName](callbacks, ...)
	end
end
