-- Allow the player to switch to a white listed weapon while switching. (This will not stop the switching to the other weapon)
local canSwitchWhileSwitching = false

local noDelay = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true,
    localrp_hands = true,
    localrp_flashlight = true,
    lrp_lockpick = true,
    weapon_handcuffed = true,
    weapon_fists = true,
    weapon_simfillerpistol = true,
    weapon_simrepair = true,
    weapon_simremote = true,
}

local blackList = {
    weapon_357 = true,
    weapon_ar2 = true,
    weapon_bugbait = true,
    weapon_crossbow = true,
    weapon_crowbar = true,
    weapon_frag = true,
    weapon_physcannon = true,
    weapon_pistol = true,
    weapon_rpg = true,
    weapon_shotgun = true,
    weapon_slam = true,
    weapon_smg1 = true,
    weapon_stunstick = true,
}

hook.Add('PlayerSwitchWeapon', 'switchDelay', function(ply, oldWeapon, newWeapon)
    if SERVER and (GetConVar('sv_lrp_switch_block'):GetBool() and blackList[newWeapon:GetClass()]) then return true end

    if noDelay[newWeapon:GetClass()] then -- Skip the weapon switch
        if not canSwitchWhileSwitching then
            if SERVER and ply.isSwitching or Switching then
                return true
            end
        end
    else
        if SERVER then
            if not ply.switchBlock and not ply.isSwitching then
                ply:SwitchDelay(newWeapon, oldWeapon)
            end

            -- Will be true after the timer succeeded, so we can switch the weapon.
            if not ply.switchBlock then
                ply.isSwitching = false
                return false
            else
                return true
            end
        else
            if not isSwitching then
                return true
            end
        end
    end
end)