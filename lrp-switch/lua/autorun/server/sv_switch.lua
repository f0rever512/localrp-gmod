CreateConVar('sv_lrp_switch_block', '0', FCVAR_ARCHIVE, 'Block on taking weapons from the blacklist')

resource.AddSingleFile('resource/localization/en/lrp_switch.properties')
resource.AddSingleFile('resource/localization/ru/lrp_switch.properties')

util.AddNetworkString('switchDelay')

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
    lrp_battering_ram = 1.5,
    lrp_shield = 1.5,
    lrp_stungun = 0.5,
}

local holdTypeTime = {
    normal = 0.75, -- default switch time
    revolver = 1,
    pistol = 1,
    duel = 1,
    smg = 1.4,
    ar2 = 1.8,

    grenade = 0.6,
    melee = 0.6,
    melee2 = 0.6,
    knife = 0.6,
    slam = 0.75,
    shotgun = 1.5,
    crossbow = 1.5,
    rpg = 2
}

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

local function getSwitchTime(ply, newWeapon)
    local weaponClass = newWeapon:GetClass()
    if specialTime[weaponClass] then
        switchTime = specialTime[weaponClass]
    else
        local newWepHoldType = newWeapon.Base == 'localrp_gun_base' and newWeapon.Sight or newWeapon:GetHoldType()
        switchTime = holdTypeTime[newWepHoldType] or holdTypeTime['normal']
    end

    return switchTime
end

local switchSound = 'weapons-new/shared/switch4.ogg'
local function switchAnim(ply, switchTime, silent)
    local id = 'switchDelay.anim' .. ply:SteamID64()

    -- first animation
    ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
    if not silent then
        ply:EmitSound(switchSound, 65)
    end
    
    timer.Create(id, 1.5, 0, function()
        if not IsValid(ply) or not timer.Exists(id) then
            timer.Remove(id)
            return
        end

        ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
        if not silent then
            ply:EmitSound(switchSound, 65)
        end
    end)

    timer.Create('switchDelay.animRemove' .. ply:SteamID64(), switchTime, 1, function()
        if timer.Exists(id) then
            timer.Remove(id)
        end
    end)
end

local function timerRemove(ply, id)
    if timer.Exists(id .. ply:SteamID64()) then
        timer.Remove(id .. ply:SteamID64())
    end
end

local function switchCancel(ply)
    timerRemove(ply, 'switchDelay.timer')
    timerRemove(ply, 'switchDelay.anim')
    timerRemove(ply, 'switchDelay.animRemove')
    
    -- We want the player to be able to switch again ofcourse.
    ply.switchBlock = false
    ply.isSwitching = false
    
    -- cancel switch on client
    net.Start('switchDelay')
    net.WriteBool(false)
    net.Send(ply)
end

local FAS_Temp_Fix = false

local playerMeta = FindMetaTable('Player')

function playerMeta:SwitchDelay(newWeapon, oldWeapon)
    self.isSwitching = true -- Player is switching weapon.
    self.switchBlock = true -- Player can't switch weapon now.

    local silent = self:GetInfoNum('cl_lrp_silent_switch', 0) == 1
    local switchTime = getSwitchTime(self, newWeapon) * (silent and 2 or 1)

    switchAnim(self, switchTime, silent)

    -- start switch on client
    net.Start('switchDelay')
    net.WriteBool(true)
    net.WriteFloat(tonumber(switchTime)) -- send time to client
    net.Send(self)

    timer.Create('switchDelay.timer' .. self:SteamID64(), switchTime, 1, function()
        if IsValid(self) and IsValid(newWeapon) and self:HasWeapon(newWeapon:GetClass()) and self:Alive() then
            self.switchBlock = false
            self:SelectWeapon(newWeapon:GetClass())
            if newWeapon.Base == 'localrp_gun_base' then
                self:SetAnimation(PLAYER_ATTACK1)
            end
            -- oldWeapon:CallOnClient('Holster', newWeapon)

            if FAS_Temp_Fix then
                self.WepSwitchAttempts = 0
                local function HasSwitched()
                    if newWeapon ~= self:GetActiveWeapon() then
                        self.isSwitching = true
                        self.switchBlock = true
                        
                        self.WepSwitchAttempts = self.WepSwitchAttempts + 1
                    
                        timer.Simple(0.02, function()
                            self.switchBlock = false
                            self:SelectWeapon(newWeapon:GetClass())
                        
                            -- We don't want it to get stuck in an infinite loop.
                            if self.WepSwitchAttempts < 100 then
                                HasSwitched()
                            else
                                switchCancel(self)
                            end
                        end)
                    else
                        switchCancel(self)
                    end
                end
                HasSwitched()
            else
                switchCancel(self)
            end
        else
            switchCancel(self)
        end
    end)
end

-- Allow the player to switch to a white listed weapon while switching. (This will not stop the switching to the other weapon)
local canSwitchWhileSwitching = false
hook.Add('PlayerSwitchWeapon', 'switchDelay', function(ply, oldWeapon, newWeapon)
    if GetConVar('sv_lrp_switch_block'):GetBool() and blackList[newWeapon:GetClass()] then return true end

    if noDelay[newWeapon:GetClass()] then -- Skip the weapon switch
        if not canSwitchWhileSwitching then
            if ply.isSwitching then
                return true
            end
        end
    else
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
    end
end)

hook.Add('KeyPress', 'lrp-switchCancel', function(ply, key)
    if key ~= IN_RELOAD then return end
    switchCancel(ply)
end)

hook.Add('StartCommand', 'switchDelay.removeKeys', function(ply, cmd)
    if not ply.isSwitching then return end
    cmd:RemoveKey(IN_ATTACK)
    cmd:RemoveKey(IN_ATTACK2)
end)

hook.Add('PlayerDeath', 'switchDelay.death', switchCancel)
hook.Add('PlayerSilentDeath', 'switchDelay.silentDeath', switchCancel)