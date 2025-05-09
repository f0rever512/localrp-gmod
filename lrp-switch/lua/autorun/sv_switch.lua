AddCSLuaFile('sh_switch.lua')
include('sh_switch.lua')

if CLIENT then return end

util.AddNetworkString("WepSwitch_EnableSwitch")
util.AddNetworkString('lrp-switchDisable')
util.AddNetworkString("WepSwitch_Switching")
util.AddNetworkString("WepSwitch_EnableSwitch_received")

CreateConVar('sv_lrp_silentswitch', 0, FCVAR_ARCHIVE, 'Enable or disable silent switch weapon', 0, 1)

local blackList = {
    weapon_357 = true,
    weapon_pistol = true,
    weapon_crossbow = true,
    weapon_frag = true,
    weapon_ar2 = true,
    weapon_smg1 = true,
    weapon_shotgun = true,
    weapon_rpg = true,
}

local specialTime = {
    localrp_air_pistol = 0.7,
    localrp_air_revolver = 0.7,
    localrp_air_shotgun = 1,
    localrp_air_smg = 1,
    localrp_awp = 2,
    localrp_aug = 1.8,
    localrp_g3sg1 = 2,
    localrp_m249para = 2.5,
    localrp_scout = 2,
    localrp_sg550 = 2,
    localrp_tmp = 1.4,
    lrp_stungun = 0.5,
    localrp_grenade_smoke = 0.4,
    localrp_grenade_frag = 0.4,
    localrp_grenade_flash = 0.4,
    weapon_357 = 0,
    weapon_pistol = 0,
    weapon_crossbow = 5000,
    weapon_frag = 5000,
    weapon_ar2 = 5000,
    weapon_smg1 = 5000,
    weapon_shotgun = 5000,
    weapon_rpg = 5000
}

local holdTypeTime = {
    revolver = 1,
    pistol = 1,
    duel = 1,
    smg = 1.4,
    ar2 = 1.8,

    grenade = 0.6,
    slam = 0.75,
    normal = 0.75,
    melee = 0.6,
    melee2 = 0.6,
    knife = 0.6,
    shotgun = 1.5,
    crossbow = 1.5,
    rpg = 2
}

local function GetEquipTime(ply, newWeapon)
    local NewEquipTime = EquipTime

    local weaponClass = newWeapon:GetClass()
    if specialTime[weaponClass] then
        NewEquipTime = specialTime[weaponClass]
    else
        local newWepHoldType = newWeapon.Base == 'localrp_gun_base' and newWeapon.Sight or newWeapon:GetHoldType()
        if holdTypeTime[newWepHoldType] then
            NewEquipTime = holdTypeTime[newWepHoldType]
        end
    end

    return NewEquipTime
end

local function switchAnim(ply)
    -- first anim
    timer.Simple(0, function()
        ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
        ply:EmitSound('npc/combine_soldier/gear5.wav', 55, 100)
    end)
end

WeaponSwitch = {}
function WeaponSwitch:DelayEquip(ply, weapon, oldweapon)
    ply.IsSwitchingWeapons = true -- Player is switching weapon.
    ply.CantSwitch = true -- Player can't switch weapon now.
    ply.SwitchingToWeapon = weapon
    ply.SwitchingFromWeapon = oldweapon

    -- if blackList[weapon:GetClass()] then return end
    
    local NewEquipTime = GetEquipTime(ply, weapon)
    -- if GetConVarNumber('sv_lrp_silentswitch') == 1 then
    --     NewEquipTime = NewEquipTime + 2.5
    -- end
    
    -- timer.Create('lrp-switchAnimationStart_' .. ply:SteamID64(), 0.1, 1, function()
    --     ply:EmitSound( "npc/combine_soldier/gear5.wav", 55, 100 )
    --     ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
    -- end)

    switchAnim(ply)

    local animationDelay = NewEquipTime <= 1.4 and NewEquipTime or NewEquipTime / 2
    local animationRepeat = NewEquipTime <= 1.4 and 1 or 2
    timer.Create('lrp-switchAnimation_' .. ply:SteamID64(), animationDelay, animationRepeat, function()
        -- if CurTime() > CurTime() + 1 or not IsValid(self) then return timer.Destroy('lrp-switchAnimation_' .. ply:SteamID64()) end
        ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
        ply:EmitSound('npc/combine_soldier/gear5.wav', 55, 100)
    end)

    timer.Create('lrp-switchAnimationEnd_' .. ply:SteamID64(), NewEquipTime + 0.2, 1, function() ply:SetAnimation(PLAYER_ATTACK1) end)

    net.Start("WepSwitch_Switching")
        -- net.WriteString(weapon:GetClass())
        net.WriteString(tostring(NewEquipTime))
    net.Send(ply)

    timer.Create('lrp-switchTimer_' .. ply:SteamID64(), NewEquipTime, 1, function()
    
        if IsValid(ply) or ply:Alive() then
            net.Start("WepSwitch_EnableSwitch")
                if not IsValid(weapon) then
                    -- Weapon doesn't exist anymore, tell the client to do nothing.
                    net.WriteString("NULL")
                    -- We want the player to be able to switch again ofcourse.
                    ply.IsSwitchingWeapons = false
                    ply.CantSwitch = false
                else
                    -- Tell the client to enable weaponswitch.
                end
            net.Send(ply)
        end
        
    end)
end

local playerMeta = FindMetaTable('Player')
function playerMeta:DisableSwitch()
    net.Start('lrp-switchDisable')
    net.Send(self)
end

local FAS_Temp_Fix = false
net.Receive("WepSwitch_EnableSwitch_received", function(len, ply)
    -- ply.weaponName = net.ReadString() or ""
    -- Now switch the weapon.
    if IsValid(ply) and ply:Alive() then
        if IsValid(ply.SwitchingToWeapon) and ply:HasWeapon(ply.SwitchingToWeapon:GetClass()) then
            ply.CantSwitch = false
            ply:SelectWeapon(ply.SwitchingToWeapon:GetClass())
            --ply.SwitchingFromWeapon:CallOnClient("Holster", ply.SwitchingToWeapon)
            if FAS_Temp_Fix then
                ply.WepSwitchAttempts = 0
                local function HasSwitched()
                    if ply.SwitchingToWeapon ~= ply:GetActiveWeapon() then
                        ply.IsSwitchingWeapons = true
                        ply.CantSwitch = true
                        
                        ply.WepSwitchAttempts = ply.WepSwitchAttempts + 1
                    
                        timer.Simple(0.02, function()
                            ply.CantSwitch = false
                            ply:SelectWeapon(ply.SwitchingToWeapon:GetClass())
                        
                            -- We don't want it to get stuck in an infinite loop.
                            if ply.WepSwitchAttempts < 100 then
                                HasSwitched()
                            else
                                ply.CantSwitch = false
                                ply.IsSwitchingWeapons = false
                                -- Tell client to disable CanSwitch
                                ply:DisableSwitch()
                            end
                        end)
                    else
                        ply:DisableSwitch()
                    end
                end
                HasSwitched()
            else
                ply:DisableSwitch()
            end
        else
            ply:DisableSwitch()
        end
    else
        ply:DisableSwitch()
    end
end)

local function TimerRemove(ply, id)
    if timer.Exists(id .. ply:SteamID64()) then
        timer.Remove(id .. ply:SteamID64())
    end
end

function SwitchCancel(ply)
    if ply.IsSwitchingWeapons then
        local delays = {}
        TimerRemove(ply, 'lrp-switchTimer_')
        TimerRemove(ply, 'lrp-switchAnimation_')
        TimerRemove(ply, 'lrp-switchAnimationEnd_')
        
        ply.CantSwitch = false
        ply.IsSwitchingWeapons = false
    
        net.Start('lrp-switchDisable')
        net.Send(ply)
    end
end

hook.Add('PlayerDeath', 'lrp-switchDeathDisable', SwitchCancel)
hook.Add('PlayerSilentDeath', 'lrp-switchSilentDeathDisable', SwitchCancel)