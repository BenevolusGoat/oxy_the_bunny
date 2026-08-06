local Mod = OxyTheBunny

return function(modifiers)
	return {
		[Mod.Card.SOUL_OF_OXY.ID] = {
			Name = "Soul of Oxy",
			Description = {
			"Gives the effect of the Chainsaw item for 30 seconds or until taking damage"
			}
		},
		[Mod.Card.STEEL_CARD.ID] = {
			Name = "Steel Card",
			Description = {
			"↑ 1.5x {{Damage}} Damage and {{Tears}} Tears"
			}
		},
	}
end
