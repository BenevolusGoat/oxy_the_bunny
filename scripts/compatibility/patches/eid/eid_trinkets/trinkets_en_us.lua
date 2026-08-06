local Mod = OxyTheBunny
local Trinket = Mod.Trinket

return function(modifiers)
	return {
		[Trinket.FOUR_LEAF_CLOVER.ID] = {
			Name = "Four Leaf Clover",
			Description = {
			"{{Timer}} Doubles the time limit to reach the Boss Rush and Hush floor",
			"#{{Blank}} (40:00 and 1:00:00)",
			"#Troll bombs cannot appear",
			"#{{Collectible44}} The Teleport! effect can only ever land in a special room"
			},
		},
		[Trinket.PASSAGE.ID] = {
			Name = "Passage",
			Description = {
			"{{Bomb}} +1 Bomb on pickup",
			"#{{SecretRoom}} Entering a secret room opens all adjacent doors"
			}
		},
		[Trinket.TUFT_OF_FUR.ID] = {
			Name = "Tuft of Fur",
			Description = {
			"Tear effects additionally deal damage over time",
			"#Effects that already deal damage over time deal extra damage"
			},
		},
		[Trinket.WHITE_PETAL.ID] = {
			Name = "White Petal",
			Description = {
			"{{AngelChance}} +10% Angel Room chance",
			"#Angel Rooms are special variants that always contain at least 2 pedestals, Soul/Eternal Hearts and enemies"
			},
		},
	}
end
