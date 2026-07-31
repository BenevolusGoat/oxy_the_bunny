local Mod = OxyTheBunny
local Item = Mod.Item

return function(modifiers)
	return {
		[Mod.PlayerType.OXY] = {
			Name = "Oxy",
			Description = {
			}
		},
		[Mod.PlayerType.OXY_B] = {
			Name = "Tainted Oxy",
			Description = {
			}
		},
	}
end
