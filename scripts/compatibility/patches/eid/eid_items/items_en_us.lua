local Mod = OxyTheBunny
local OXY_EID = Mod.EID_Support
local Item = Mod.Item

return function(modifiers)
	return {
		[Item.BODYSUIT.ID] = {
			Name = "Bodysuit",
			Description = {
			"↑ {{Speed}} +0.1 Speed",
			"#Raises Isaac's minimum {{Speed}} speed to 1.2"
			}
		},
		[Item.BUNNY_EARS.ID] = {
			Name = "Bunny Ears",
			Description = {
			"{{Timer}} When taking damage, recieve for the room:",
			"#{{ArrowUp}} {{Tears}} +1 Tears up",
			"#{{Slow}} Slow all enemies in the room"
			}
		},
		[Item.CHAINSAW.ID] = {
			Name = "Chainsaw",
			Description = {
			"Isaac's tears are replaced by a large saw attached to a chain",
			"#The saw is spectral and can hit all enemies in its path",
			"#{{Damage}} The saw deals 2x Isaac's damage when hitting enemies at the arc of the swing",
			"#{{Tears}} Fires in a 3-swing burst",
			"#{{Blank}} Faster and slower fire rates replace the burst of swings with a consistent swing pattern"
			}
		},
		[Item.COUNTERPART.ID] = {
			Name = "The Counterpart",
			Description = {
			"When dealing damage, spawns plus tears from offscreen that fly in towards enemies",
			"#Plus tears deal half damage"
			}
		},
		[Item.HOLSTER.ID] = {
			Name = "Holster",
			Description = {
			"Enables Oxy to freely switch between the Chainsaw and normal tears"
			}
		},
		[Item.HYPERSOMNIA.ID] = {
			Name = "Hypersomnia",
			Description = {
			"{{CurseDarkness}} Every floor except Home is given Curse of Darkness",
			"#{{IsaacsRoom}} An unlocked clean bedroom will generate on every floor whenever possible",
			"#{{Damage}} Sleeping in a bedroom clears the Curse of Darkness and grants +1 Damage for the rest of the floor",
			"#{{Warning}} Bedrooms will not spawn in ???, The Void or Home"
			}
		},
		[Item.LITTLE_OXY.ID] = {
			Name = "Little Oxy",
			Description = {
			"{{Charm}} Shoots charm tears",
			"#Deals 3.5 damage per tear"
			}
		},
		[Item.MANIFEST.ID] = {
			Name = "Manifest",
			Description = {
			}
		},
		[Item.MUTUS_LIBER.ID] = {
			Name = "Mutus Liber",
			Description = {
			"Transmutes items into their opposite/alternate versions and vice versa:",
			"#{{Card}} Tarot cards become Reverse Tarot cards",
			"#{{Pill}} Negative pills become Positive pills",
			"#{{Key}} Keys become {{Bomb}} Bombs",
			"#{{Coin}} Lucky pennies become Sticky nickels",
			"#{{Heart}} Red hearts become {{SoulHeart}} Soul hearts",
			"#{{EmptyBoneHeart}} Bone hearts become {{RottenHeart}} Rotten hearts",
			"#{{BlackHeart}} Black hearts become {{EternalHeart}} Eternal hearts"
			}
		},
		[Item.RED_KEYCHAIN.ID] = {
			Name = "Red Keychain",
			Description = {
			"Creates a red room adjacent to a regular room, indicated by a door outline",
			"#Red Rooms can be special rooms",
			"#Entering a room outside the 13x13 floor map teleports Isaac to the I AM ERROR room",
			"#{{Collectible580}} 5 red rooms may be opened before the keychain runs out",
			"#Entering a new floor refreshes the keychain"
			}
		},
		[Item.SANCTUARY.ID] = {
			Name = "Sanctuary",
			Description = {
			"{{SecretRoom}} Improves Secret Room layouts",
			"#{{Collectible}} Secret Rooms are highly likely to contain item pedestals"
			}
		},
	}
end
