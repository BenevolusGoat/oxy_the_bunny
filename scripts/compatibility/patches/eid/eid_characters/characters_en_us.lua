local Mod = OxyTheBunny

return function()
	return {
		[Mod.PlayerType.OXY] = {
			Name = "Oxy",
			Description = {
				"I am",
				"#a bunny"
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
