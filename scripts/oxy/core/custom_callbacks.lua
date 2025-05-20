local Mod = OxyTheBunny

OxyTheBunny.ModCallbacks = {
	---(EntityBomb Bomb) - Called when a bomb explodes
	POST_BOMB_EXPLODE = "FURTHERANCE_POST_BOMB_EXPLODE",

	---(EntityBomb Bomb) - Called when an Epic Fetus rocket explodes
	POST_ROCKET_EXPLODE = "FURTHERANCE_POST_ROCKET_EXPLODE",
}

local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)

local function postEpicFetusExplode(_, effect)
	if effect.Variant == EffectVariant.ROCKET and effect.PositionOffset.Y == 0 then
		Isaac.RunCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, effect:ToEffect())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postEpicFetusExplode, EntityType.ENTITY_EFFECT)
