local Mod = OxyTheBunny

local prefix = "scripts.oxy.unlocks.unlocks_"

--#region Oxy

local oxy = {
	"bodysuit",
	"counterpart",
	"bunny_ears",
	"four_leaf_clover",
	"little_oxy",
	"sanctuary",
	"tuft_of_fur",
	"mutus_liber",
	"hypersomnia"
}

Mod.LoopInclude(oxy, prefix .. "oxy")

--#endregion

--#region Tainted Oxy

local oxy_b = {
	"passage",
	"red_keychain",
	"soul_of_oxy",
	"steel_card",
	"white_petal"
}

Mod.LoopInclude(oxy_b, prefix .. "oxy_b")

--#endregion

Mod.Include("scripts.oxy.unlocks.unlock_table")
Mod.Include("scripts.oxy.unlocks.unlock_tracker_marks")
