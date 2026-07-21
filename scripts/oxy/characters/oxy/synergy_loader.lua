local Mod = OxyTheBunny

local synergyList = {
	"c_section",
	"compound_fracture",
	"crickets_body",
	"dead_tooth",
	"evil_eye",
	"explosivo",
	"extra_directionals",
	"eye_of_greed",
	"fire_mind",
	"ghost_pepper_birds_eye",
	"guppy",
	"haemolacria",
	"immaculate_heart",
	"ipecac",
	"isaacs_tears",
	"jacobs_ladder",
	"lacryphagy",
	"large_zit",
	"lead_pencil",
	"moms_wig",
	"mucormycosis",
	"mulligan",
	"mysterious_liquid",
	"ocular_rift",
	"parasite",
	"pop",
	"sinus_infection",
	"sulfuric_acid",
	"technology_2",
	"terra"
}

for _, path in ipairs(synergyList) do
	Mod.Include("scripts.oxy.characters.oxy.synergies." .. path)
end