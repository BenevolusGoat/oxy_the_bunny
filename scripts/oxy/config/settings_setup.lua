--luacheck: no max line length
local Mod = OxyTheBunny
local SettingsHelper = Mod.SettingsHelper

local frameOptions = {}
for i = 5, 20 do
	Mod.Insert(frameOptions, i)
end

SettingsHelper.AddChoiceSetting("General", Mod.Setting.HeartRenovatorDoubleTap,
	"Adjust the double tap window for Heart Renovator", frameOptions, 15)
