local Mod = OxyTheBunny

local synergyList = {
	"c_section",
	"crickets_body",
	"explosivo",
	"haemolacria",
	"ipecac",
	"lacryphagy",
	"myosotis",
	"parasite",
	"pop",
	"sinus_infection",
}

for _, path in ipairs(synergyList) do
	Mod.Include("scripts.oxy.characters.oxy.synergies." .. path)
end