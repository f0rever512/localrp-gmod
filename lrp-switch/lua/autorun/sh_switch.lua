-- Time to equip the weapon in seconds.
EquipTime = 1

local whiteList = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true,
    localrp_hands = true,
    localrp_flashlight = true,
    localrp_cuff_handcuffed = true,
    lrp_lockpick = true,
    weapon_fists = true,
    weapon_simfillerpistol = true,
    weapon_simrepair = true,
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

local CanSwitch

-- Allow the player to switch to a white listed weapon while switching. (This will not stop the switching to the other weapon)
local CanSwitchToWsWhileSwitching = false
local function OnWeaponSwitch(ply, old, new)
    if blackList[new:GetClass()] then return true end

    if whiteList[new:GetClass()] then -- Skip the weapon switch
        if not CanSwitchToWsWhileSwitching then
            if SERVER and ply.IsSwitchingWeapons or isSwitching then
                return true
            end
        end
    else
        -- timer.Create('lrp-switchAnimation_' .. ply:SteamID64(), 0, 1, function()
		-- 	-- if CurTime() > CurTime() + 2 or not IsValid(self) then return timer.Destroy('lrp-switchAnimation_' .. ply:SteamID64()) end
        --     ply:EmitSound( "npc/combine_soldier/gear5.wav", 55, 100 )
		-- end)
        if SERVER then
            -- if GetConVarNumber("lrp_silentswitch") == 0 then
            --     ply:EmitSound( "npc/combine_soldier/gear5.wav", 55, 100 )
            -- end

            -- ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
            -- ply:SetAnimation(PLAYER_ATTACK1)
            -- If player isn't switching these should both be false.
            
            if not ply.switchBlock and not ply.IsSwitchingWeapons then
                ply:SwitchDelay(new, old)
            end

            -- Will be true after the timer succeeded, so we can switch the weapon.
            if not ply.switchBlock then
                ply.IsSwitchingWeapons = false
                return false
            else
                return true
            end
        else
            --LocalPlayer():EmitSound("physics/cardboard/cardboard_box_break1.wav",50)
            -- ply:EmitSound( "npc/combine_soldier/gear5.wav", 60, 100 )
            -- ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
        
            if not CanSwitch then
                return true
            end

            -- if SwitchingToWeapon == new:GetClass() then -- Should be, just to make sure.
            --     SwitchingToWeapon = ""
            --     CanSwitch = false
            --     return false
            -- else
            --     return true
            -- end
        end
    end
end

hook.Add('PlayerSwitchWeapon', 'lrp-switchWeapon', OnWeaponSwitch)

local switchCancelKey = IN_RELOAD
hook.Add('KeyPress', 'lrp-switchCancel', function(ply, key)
    if key ~= switchCancelKey then return end
    if SERVER then
        SwitchCancel(ply)
    else
        if isSwitching then
            local delays = {}
        end
    end
end)