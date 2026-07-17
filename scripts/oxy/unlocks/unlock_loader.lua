local Mod = OxyTheBunny

local prefix = "scripts.oxy.unlocks.unlocks_"

--#region Oxy

local oxy = {
}

Mod.LoopInclude(oxy, prefix .. "oxy")

--#endregion

--#region Tainted Oxy

local oxy_b = {
	"soul_of_oxy",
}

Mod.LoopInclude(oxy_b, prefix .. "oxy_b")

--#endregion

Mod.Include("scripts.oxy.unlocks.unlock_table")
Mod.Include("scripts.oxy.unlocks.unlock_tracker_marks")
