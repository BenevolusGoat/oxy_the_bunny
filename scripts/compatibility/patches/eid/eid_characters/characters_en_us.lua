local Mod = OxyTheBunny

return function()
	return {
		[Mod.PlayerType.OXY] = {
			Name = "Oxy",
			Description = {
				"#Swings a large saw that is spectral and hits all enemies in its path",
				"#{{Damage}} The saw deals 2x Oxy's damage when hitting enemies at the arc of the swing",
				"#{{Warning}} Taking damage uncharges Holster and prevents Oxy from using the Chainsaw until it is charged",
				"#{{Charm}} Has innate charm tears"
			}
		},
		[Mod.PlayerType.OXY_B] = {
			Name = "Tainted Oxy",
			Description = {
				"{{BlackHeart}} Cannot have Red Hearts",
				"#Uses a Specter to attack with pink strings that are spectral and hit all enemies in their path",
				"#Every 10 seconds, the Specter flips between an active and inactive state",
				"#{{Blank}} When inactive, Oxy is forced to use tears",
				"#{{Fear}} Has innate fear tears"
			}
		},
	}
end
