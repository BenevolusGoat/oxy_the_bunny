local Mod = OxyTheBunny

local BUNNY = {}

OxyTheBunny.TRANSFORMATION_BUNNY = BUNNY

BUNNY.ID = Isaac.GetNullItemIdByName("bunny transformation")
BUNNY.CONFIG = Mod.ItemConfig:GetNullItem(BUNNY.ID)
BUNNY.NUM_ITEMS_NEEDED = 2

---@param player EntityPlayer
function BUNNY:HasTransformation(player)
	local player_run_save = Mod:TryGetRunSave(player)
	return player_run_save and player_run_save.BunnyTransformation
end

---@param player EntityPlayer
function BUNNY:CheckTransformation(player)
	local effects = player:GetEffects()
	local progress = effects:GetNullEffectNum(BUNNY.ID)
	local player_run_save = Mod:RunSave(player)
	if progress >= BUNNY.NUM_ITEMS_NEEDED and not player_run_save.BunnyTransformation then
		player_run_save.BunnyTransformation = true
		if not player_run_save.BunnyTransformationFirstTime then
			player:AddMaxHearts(2)
			player:AddHearts(2)
			player_run_save.BunnyTransformationFirstTime = true
		end
		Mod.Game:GetHUD():ShowItemText("Bunny!")
		player:AddNullCostume(BUNNY.CONFIG.Costume.ID)
		Mod.SFXMan:Play(SoundEffect.SOUND_POWERUP_SPEWER)
		Mod.Spawn.Poof01(0, player.Position, player)
		player_run_save.BunnyTransformation = true
	elseif progress < BUNNY.NUM_ITEMS_NEEDED and player_run_save.BunnyTransformation then
		player:TryRemoveNullCostume(BUNNY.CONFIG.Costume.ID)
		player_run_save.BunnyTransformation = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, BUNNY.CheckTransformation, BUNNY.CONFIG)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, BUNNY.CheckTransformation, BUNNY.CONFIG)

---@param item CollectibleType
---@param player EntityPlayer
---@param firstTime boolean
function BUNNY:OnItemAdd(item, charge, firstTime, slot, varData, player)
	local itemConfig = Mod.ItemConfig:GetCollectible(item)
	if itemConfig and itemConfig:HasCustomTag("oxybunny") then
		player:AddNullItemEffect(BUNNY.ID)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BUNNY.OnItemAdd)

---@param player EntityPlayer
---@param item CollectibleType
---@param removeFromForm boolean
---@param innate boolean
function BUNNY:OnItemRemove(player, item, removeFromForm, innate)
	local itemConfig = Mod.ItemConfig:GetCollectible(item)
	if itemConfig
		and itemConfig:HasCustomTag("oxybunny")
		and removeFromForm
	then
		player:GetEffects():RemoveNullEffect(BUNNY.ID)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, BUNNY.OnItemRemove)

---@param player EntityPlayer
---@param tearParams TearParams
function BUNNY:CharmChance(player, tearParams)
	if BUNNY:HasTransformation(player) then
		local luck = Mod:GetTearModifierLuck(player)
		local chance = 1 / math.max(1, 10 - (luck / 3 ) )
		local roll = player:GetCollectibleRNG(Mod.Item.HOLSTER.ID):RandomFloat()
		if roll < chance then
			tearParams.TearFlags = Mod:AddBitFlags(tearParams.TearFlags, TearFlags.TEAR_CHARM)
			tearParams.TearColor = Mod.Character.OXY.CHARM_COLOR
			return tearParams
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, BUNNY.CharmChance)
