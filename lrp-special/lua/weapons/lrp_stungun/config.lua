-- Ragdoll physics effect, replaces old "ShouldRoll"
-- Set to either 0, 1 or 2
-- 0: No effect
-- 1: Original comical rolling around
-- 2: Ragdoll shaking
STUNGUN.PhysEffect = 2

-- Can you un-taze people with rightclick?
STUNGUN.CanUntaze = false

-- Should it display in thirdperson view for the tazed player? (if false, firstperson)
STUNGUN.Thirdperson = false

-- If above is true, should users be able to press crouch button (default ctrl) to switch between third and firstperson?
STUNGUN.AllowSwitchFromToThirdperson = false

-- Should people be able to pick a tazed player using physgun?
STUNGUN.AllowPhysgun = false

-- Should people be able to use toolgun on tazed players?
STUNGUN.AllowToolgun = false

-- Should tazed players take falldamage? (Warning: experimental, not recommended to have if players can pick them up using physgun.)
STUNGUN.Falldamage = true

-- How much damage the tazer also does
-- Set to 0 to disable
STUNGUN.StunDamage = 0

-- Should it display name and HP on tazed players?
STUNGUN.ShowPlayerInfo = false

-- Can the player be damaged while he's tazed?
STUNGUN.AllowDamage = true

-- Can the player suicide while he's paralyzed?
STUNGUN.ParalyzeAllowSuicide = false

-- Can the player suicide while he's mute?
STUNGUN.MuteAllowSuicide = false

-- Amount of seconds the player is immune to stuns after he just got up from being paralyzed. -1 to disable.
STUNGUN.Immunity = 3

-- Can people of same team stungun each other? Check further below (in the advanced section) for the check-function.
-- The check function is by default set to ignore police trying to taze police.
STUNGUN.AllowFriendlyFire = false

-- If the ragdoll version of the playermodel does not spawn correctly (incorrectly made model) then the ragdoll will be this model.
-- When done rolling around the player will get back his default model.
-- Set this to "nil" (without quotes) if you want to disable this default model and just make it not work.
STUNGUN.DefaultModel = Model("models/player/group01/male_01.mdl")

-- Default charge for the weapon, when the guy picks the gun up, should it be filled already or wait to be filled? 100 is max charge, 0 is uncharged.
SWEP.Charge = 100

-- Recharge rate. How many seconds it takes to fill the gun back up.
SWEP.RechargeTime = 4

--[[
There's two seperate times for this. This is so the player has a chance to escape but the robbers still have a chance to re-taze him.
Put the paralyzetime and mutetime at same to make the player able to talk exactly when he's able to get up.
Put the mutetime slightly higher than paralyze time to make him wait a few seconds before he's able to talk after he got up.
]]

-- How many seconds the player is rolling around as a ragdoll.
STUNGUN.ParalyzedTime = 8

-- How many seconds the player is mute/gagged = Unable to speak/chat.
STUNGUN.MuteTime = 8

-- How many seconds after the player has been unragdolled that he still won't be able to move.
STUNGUN.FreezeTime = 3

-- What teams are immune to the stungun? (if any).
local immuneteams = {}

--[[****************
ADVANCED SECTION
Contact me if you need help with any function.
*****************]]
-- If you've found that specific models appear to break it, add them here and they will turn into the default model instead.
STUNGUN.BrokenModels = {
	["models/test/model.mdl"] = true
}

local females = {
	["models/player/alyx.mdl"] = true,["models/player/p2_chell.mdl"] = true,
	["models/player/mossman.mdl"] = true,["models/player/mossman_arctic.mdl"] = true
}
function STUNGUN.PlayHurtSound(ply)
	local mdl = ply:GetModel()
	-- Female
	if females[mdl] or string.find(mdl, "female") then
		return "vo/npc/female01/pain0" .. math.random(1,9) .. ".wav"
	end

	-- Male
	return "vo/npc/male01/pain0" .. math.random(1,9) .. ".wav"
end

--[[
Custom same-team function.
]]
function STUNGUN.SameTeam(ply1, ply2)
	if ply1:Team() == 2 and ply2:Team() == 2 then return true end

	-- return (ply1:Team() == ply2:Team()) -- Probably dont want this in DarkRP, nor TTT, but maybe your custom TDM gamemode.
end

--[[
Custom Immunity function.
]]
function STUNGUN.IsPlayerImmune(ply)
	if type(immuneteams) == "table" and table.HasValue(immuneteams, ply:Team()) then return true end
	return false
end

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_DETECTIVE }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = false

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true