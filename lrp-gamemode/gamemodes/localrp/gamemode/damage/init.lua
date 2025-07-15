local legBreakCvar = CreateConVar('sv_lrp_breaking_leg', 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Enable/disable breaking leg')
local drowningCvar = CreateConVar('sv_lrp_drowning', 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Enable / disable water drowning damage')

util.AddNetworkString('breakleg')
util.AddNetworkString('notifydmg')
util.AddNetworkString('bleeding')

local hitgroupNames = {
    ['HITGROUP_HAND'] = 'рука',
    [HITGROUP_HEAD] = 'голова',
    ['HITGROUP_NUTS'] = 'область таза',
    [HITGROUP_LEFTLEG] = 'левая нога',
    [HITGROUP_RIGHTLEG] = 'правая нога',
    [HITGROUP_LEFTARM] = 'левая рука',
    [HITGROUP_RIGHTARM] = 'правая рука',
    [HITGROUP_STOMACH] = 'область живота',
    [HITGROUP_CHEST] = 'область груди'
}

local allowHolster = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true,
    ["gmod_camera"] = true,
    ["localrp_hands"] = true
}

local function screenFade(pl, time)
    pl:ScreenFade(SCREENFADE.OUT, color_black, time, 0)
    timer.Simple(time, function()
        pl:ScreenFade(SCREENFADE.IN, color_black, time, time + 0.15)
    end)
end

local function breakLeg(ply, duration)
    if not legBreakCvar:GetBool() then return end
    net.Start('breakleg')
        net.WriteInt(duration, 5)
    net.Send(ply)
end

local function notifyDamage(ply, hitgroup)
    local hitgroupName = hitgroupNames[hitgroup]
    if hitgroupName then
        if math.random(1, 2) == 1 then
            ply:ViewPunch(Angle(math.random(-15, 15), math.random(-15, 15), math.random(-10, 10)))
            screenFade(ply, 0.1)
        end
        net.Start('notifydmg')
            net.WriteString(hitgroupName)
        net.Send(ply)
    end
end

local function calculateFallDamage(ply, speed)
    local damage = speed / 7.5
    if damage > ply:Health() / 2 and damage < ply:Health() then
        breakLeg(ply, 10)
        screenFade(ply, 0.1)
    end
    return damage
end

local function damageHands(ply, chance)
    if math.random(100) > chance then return end
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and (wep:GetMaxClip1() > -1 or wep:GetMaxClip2() > -1) then
        ply:SelectWeapon('localrp_hands')
    end
end

local function handleDrowning()
    if not drowningCvar:GetBool() then return end
    for _, v in pairs (player.GetAll()) do
        if v:Alive() then
            if v:WaterLevel() == 3 then
                v.drowning = (v.drowning or 0) + 1
            else
                v.drowning = nil
            end

            if v.drowning and v.drowning > 5 then
                if math.random(1, 3) == 3 then
                    v:EmitSound("player/pl_drown" .. math.random(2,3) .. ".wav", 100, math.random(100,120))
                end
            end
            
            if v.drowning and v.drowning > 9 then
                v:SetHealth(v:Health() - 5)
                if math.random(1, 2) == 2 then
                    screenFade(v, 0.2)
                end
                if v.drowning == 10 then
                    v:EmitSound("player/pl_drown1.wav")
                end
                if math.random(1,3) == 3 then
                    v:EmitSound("player/pl_drown" .. math.random(1,2) .. ".wav", 100, math.Clamp(v:Health() * 1.2, 70, 100))
                end
                if v:Health() <= 0 then
                    v:Kill()
                    v:EmitSound("player/pl_drown3.wav")
                end
            end
        end
    end
end

local function checkBones(ply, dmgpos)
    local bones = {
        {name = 'ValveBiped.Bip01_Pelvis', dist = 49, margin = 25, group = 'HITGROUP_NUTS'},
        {name = 'ValveBiped.Bip01_L_Hand', dist = 100, group = 'HITGROUP_HAND'},
        {name = 'ValveBiped.Bip01_R_Hand', dist = 100, group = 'HITGROUP_HAND'},
        {name = 'ValveBiped.Bip01_L_Calf', dist = 350, group = HITGROUP_LEFTLEG},
        {name = 'ValveBiped.Bip01_R_Calf', dist = 350, group = HITGROUP_RIGHTLEG},
        {name = 'ValveBiped.Bip01_Head1', dist = 80, group = HITGROUP_HEAD}
    }

    for _, bone in pairs(bones) do
        local index = ply:LookupBone(bone.name)
        if index then
            local pos = ply:GetBonePosition(index)
            local dist = dmgpos:DistToSqr(pos)
            if dist <= bone.dist and (not bone.margin or dist >= bone.margin) then
                return bone.group
            end
        end
    end

    return nil
end

local function damageHandler(ply, hitgroup, dmginfo)
    local dmgpos = dmginfo:GetDamagePosition()
    local hitgroup = checkBones(ply, dmgpos) or hitgroup

    if hitgroup == HITGROUP_HEAD then
        dmginfo:ScaleDamage(6)
    elseif hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
        dmginfo:ScaleDamage(1)
        damageHands(ply, 25)
    elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG then
        dmginfo:ScaleDamage(0.75)
        breakLeg(ply, 5)
    elseif hitgroup == HITGROUP_CHEST then
        dmginfo:ScaleDamage(2.5)
    elseif hitgroup == HITGROUP_STOMACH then
        dmginfo:ScaleDamage(1)
    elseif hitgroup == 'HITGROUP_NUTS' then
        dmginfo:ScaleDamage(1.5)
        breakLeg(ply, 5)
    elseif hitgroup == 'HITGROUP_HAND' then
        dmginfo:ScaleDamage(0.45)
        damageHands(ply, 50)
    end

    notifyDamage(ply, hitgroup)
    return dmginfo
end

local bleeding = {}

local function handleBleeding()
    for k = #bleeding, 1, -1 do
        local sid = bleeding[k]
        local ply = player.GetBySteamID(sid)

        if not IsValid(ply) then
            timer.Remove('lrp-dying' .. sid)
            table.remove(bleeding, k)
        elseif ply:Health() > 10 or not ply:Alive() then
            net.Start('bleeding')
            net.WriteBool(false)
            net.Send(ply)
            ply.bleeding = nil
            timer.Remove('lrp-dying' .. sid)
            table.remove(bleeding, k)
        end
    end
end

local function handleDying(ply, dmgInfo)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ply.bleeding then return end
    local left = ply:Health() - dmgInfo:GetDamage()
    if left <= 0 then return end
    if left <= 10 then
        local w = ply:GetActiveWeapon()
        if IsValid(w) and ply:HasWeapon(w:GetClass()) and not allowHolster[w:GetClass()] then
            ply:DropWeapon(w)
        end

        ply:ChatPrint('Вы истекаете кровью. Если вам не помогут, вы умрете')
        ply.bleeding = true
        table.insert(bleeding, ply:SteamID())
        net.Start('bleeding')
        net.WriteBool(true)
        net.Send(ply)

        timer.Create('lrp-dying' .. ply:SteamID(), 18, 0, function()
            ply:EmitSound(Sound('vo/npc/male01/moan0' .. math.random(1, 5) .. '.wav'))

            if ply:Health() <= 1 then
                local dmg = DamageInfo()
                dmg:SetDamage(1)
                dmg:SetAttacker(game.GetWorld())
                dmg:SetInflictor(game.GetWorld())
                ply:TakeDamageInfo(dmg)
            else
                ply:SetHealth(ply:Health() - 1)
            end
        end)
    end
end

hook.Add('Initialize', 'lrp-damage', function()
    timer.Create('lrp-damage.drowning', 1, 0, handleDrowning)
    timer.Create('lrp-dying', 1, 0, handleBleeding)

    hook.Add('ScalePlayerDamage', 'EnhancedPlayerDamage', damageHandler)
    hook.Add('EntityTakeDamage', 'lrp-dying', handleDying)
    hook.Add('GetFallDamage', 'EnhancedFallDamage', calculateFallDamage)

    hook.Add('CanPlayerEnterVehicle', 'lrp-dying', function(ply)
        if ply.bleeding then return false end
    end)
end)