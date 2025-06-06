--Cacheing data rather than needing to check it a ton of times. Especially important when doing something on render callbacks
--For now, what playertypes are present for global modifiers

local CACHE_DATA = {}
OxyTheBunny.CACHE_DATA = CACHE_DATA

CACHE_DATA.PlayerTypes = {}

function CACHE_DATA:OnPlayerInit(player)
	local playerType = player:GetPlayerType()
	CACHE_DATA.PlayerTypes[playerType] = true
	OxyTheBunny:GetData(player).CachedPlayerType = playerType
end

OxyTheBunny:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, CACHE_DATA.OnPlayerInit)

function CACHE_DATA:OnPeffectUpdate(player)
	local playerType = player:GetPlayerType()
	local data = OxyTheBunny:GetData(player)
	if data.CachedPlayerType
		and data.CachedPlayerType ~= playerType
	then
		CACHE_DATA.PlayerTypes[data.CachedPlayerType] = nil
		CACHE_DATA.PlayerTypes[playerType] = true
	end
end

OxyTheBunny:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CACHE_DATA.OnPeffectUpdate)
