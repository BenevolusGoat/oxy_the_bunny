local Mod = OxyTheBunny

return function()
	return {
		[Mod.PlayerType.OXY] = {
			Name = "Oxy",
			Description = {
				"buny"
			}
		},
		[Mod.PlayerType.OXY_B] = {
			Name = "Tainted Oxy",
			Description = {
				"Can't have Red Hearts",
			}
		},
	}
end
