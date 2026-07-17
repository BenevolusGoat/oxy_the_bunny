local Mod = OxyTheBunny

local synergyList = {
	"c_section",
	"compound_fracture",
	"crickets_body",
	"evil_eye",
	"explosivo",
	"eye_of_greed",
	"ghost_pepper_birds_eye",
	"haemolacria",
	"immaculate_heart",
	"ipecac",
	"isaacs_tears",
	"jacobs_ladder",
	"lacryphagy",
	"lead_pencil",
	"moms_wig",
	"mucormycosis",
	"ocular_rift",
	"parasite",
	"pop",
	"sinus_infection",
}

for _, path in ipairs(synergyList) do
	Mod.Include("scripts.oxy.characters.oxy.synergies." .. path)
end
