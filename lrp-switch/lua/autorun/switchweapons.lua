if SERVER then
    CreateConVar("lrp_silentswitch", 0, FCVAR_ARCHIVE, "Enables/disables silent switch weapon", 0, 1)
else
    CreateClientConVar('lrp_switchpos', '0', true, false)
end

-- Time to equip the weapon in seconds.
local EquipTime = 1

-- View model when player is switching weapons.
local ShouldViewModel = false

-- Key to cancel the switching. If you want to disable this change it to nil.
local SwitchingCancelKey = IN_RELOAD

-- Allow the player to switch to a white listed weapon while switching. (This will not stop the switching to the other weapon)
local CanSwitchToWsWhileSwitching = false

-- Send a chat message to the player when the weapon is switched.
local EnableSendChatMessage = false

local function SendChatMessage( ply, weaponName )
    if DarkRP then
        ply:ConCommand( "say /me достал " .. weaponName .. "!" )
    else
        ply:ChatPrint( "Switched to " .. weaponName .. "!" )
    end
end

local FAS_Temp_Fix = falsed

local whitelist = {
    "weapon_physgun",
    "gmod_tool",
    "gmod_camera",
    "localrp_hands",
    "localrp_flashlight",
    "localrp_cuff_handcuffed",
    "weapon_fists",
    "weapon_simfillerpistol"
}

local differenttime = {
    {"localrp_air_pistol", 0.7},
    {"localrp_air_revolver", 0.7},
    {"localrp_air_shotgun", 1},
    {"localrp_air_smg", 1},
    {"localrp_awp", 2},
    {'localrp_aug', 1.8},
    {'localrp_g3sg1', 2},
    {"localrp_m249para", 2.5},
    {"localrp_scout", 2},
    {'localrp_sg550', 2},
    {"localrp_taser", 0.75},
    {"localrp_grenade_smoke", 0.4},
    {"localrp_grenade_frag", 0.4},
    {"localrp_grenade_flash", 0.4}
}   

local lrpgunstime = {
    {'revolver', 1},
    {'pistol', 1},
    {'duel', 1},
    {'smg', 1.4},
    {'ar2', 1.8},

    {'grenade', 0.6},
    {'slam', 0.75},
    {'normal', 0.75},
    {'melee', 0.8},
    {'melee2', 0.8},
    {'knife', 0.8},
    {'shotgun', 1.5},
    {'crossbow', 1.5},
    {'rpg', 2}
}   

-- local ReducedTimeGroups = {
--     {"superadmin", 0.1}
-- }

local WeaponSwitch = {}

if SERVER then
    function GetEquipTime(ply, NewWeapon)
        
        NewEquipTime = EquipTime
    
        for _, holdtype in pairs(lrpgunstime) do
            for _, weapon in pairs(differenttime) do
                if NewWeapon:GetClass() != weapon[1] then
                    if NewWeapon.LRPGuns then
                        if NewWeapon.Sight == holdtype[1] then
                            NewEquipTime = holdtype[2]
                        end
                    else
                        if NewWeapon:GetHoldType() == holdtype[1] then
                           NewEquipTime = holdtype[2]
                        end
                    end
                end

                if NewWeapon:GetClass() == weapon[1] then
                    NewEquipTime = weapon[2]
                end
            end
        end
        
        -- for _, group in pairs(ReducedTimeGroups) do
        --     if group[1] == ply:GetUserGroup() then
        --         return NewEquipTime * group[2]
        --     end
        -- end
        
        return NewEquipTime
    end

    util.AddNetworkString("WepSwitch_EnableSwitch")
    util.AddNetworkString("WepSwitch_DisableSwitch")
    util.AddNetworkString("WepSwitch_Switching")
    util.AddNetworkString("WepSwitch_EnableSwitch_received")
    util.AddNetworkString("WepSwitch_SendSwitchingPly")

    function WeaponSwitch:DelayEquip(ply, weapon, oldweapon)
    
        ply.IsSwitchingWeapons = true -- Player is switching weapon.
        ply.CantSwitch = true -- Player can't switch weapon now.
        ply.SwitchingToWeapon = weapon
        ply.SwitchingFromWeapon = oldweapon

        if ply.SwitchingFromWeapon.LRPGuns then
            ply:GetActiveWeapon():SetReloading(false)
        end
        
        local NewEquipTime = GetEquipTime(ply, weapon)
        if GetConVarNumber("lrp_silentswitch") == 1 then
            NewEquipTime = NewEquipTime + 2.5
        end
        net.Start("WepSwitch_Switching")
            net.WriteString(weapon:GetClass())
            net.WriteString(tostring(NewEquipTime))
        net.Send(ply)
        
        if ShouldViewModel then
            net.Start("WepSwitch_SendSwitchingPly")
                net.WriteString(ply:SteamID())
                net.WriteBit(true)
            net.Broadcast()
        end
    
        timer.Create("Wep_Equip_Timer" .. ply:SteamID(), NewEquipTime, 1, function()
        
            if IsValid(ply) then
                
                if ShouldViewModel then
                    net.Start("WepSwitch_SendSwitchingPly")
                        net.WriteString(ply:SteamID())
                        net.WriteBit(false)
                    net.Broadcast()
                end
            
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
    
    net.Receive("WepSwitch_EnableSwitch_received", function(len, ply)
    
        ply.weaponName = net.ReadString() or ""

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
                                    net.Start("WepSwitch_DisableSwitch")
                                    net.Send(ply)
                                end
                                
                            end)
                            
                        else

                            -- Tell client to disable CanSwitch
                            net.Start("WepSwitch_DisableSwitch")
                            net.Send(ply)
                        
                        end
                    
                    end
                    
                    HasSwitched()
                    
                else
                
                    -- Tell client to disable CanSwitch
                    net.Start("WepSwitch_DisableSwitch")
                    net.Send(ply)
                
                end
            
            else
            
                -- Tell client to disable CanSwitch
                net.Start("WepSwitch_DisableSwitch")
                net.Send(ply)
                
            end
            
        else
        
            -- Tell client to disable CanSwitch
            net.Start("WepSwitch_DisableSwitch")
            net.Send(ply)
            
        end
        
    end)
    
    local function KeyPressed(ply, key)
        if key ~= SwitchingCancelKey then return end
        if ply.IsSwitchingWeapons then
        local delays = {}
            if timer.Exists("Wep_Equip_Timer" .. ply:SteamID()) then
                timer.Destroy("Wep_Equip_Timer" .. ply:SteamID())
            end
            
            ply.CantSwitch = false
            ply.IsSwitchingWeapons = false
        
            net.Start("WepSwitch_DisableSwitch")
            net.Send(ply)
            
            if ShouldViewModel then
                net.Start("WepSwitch_SendSwitchingPly")
                    net.WriteString(ply:SteamID())
                    net.WriteBit(false)
                net.Broadcast()
            end
            
        end
    end
    hook.Add("KeyPress", "WeaponSwitch_CancelSwitch", KeyPressed)
    
end

local CanSwitch, Switching, SwitchingToWeapon

if CLIENT then

    local NewEquipTime = EquipTime
    local TimerW = 0
    local FirstSwitch = true
    local WeaponName = ""

    CanSwitch, Switching = false, false
    SwitchingToWeapon = ""
    
    local function KeyPressed(ply, key)
        if key ~= IN_RELOAD then return end
        if ply.IsSwitchingWeapons then
        local delays = {}

            
        end
    end
    hook.Add("KeyPress", "WeaponSwitch_CancelSwitch1", KeyPressed)
    net.Receive("WepSwitch_Switching", function()

        SwitchingToWeapon = net.ReadString()
        NewEquipTime = tonumber(net.ReadString())
        
        -- Get the print name of the weapon.
        WeaponName = SwitchingToWeapon -- If there is no weapon found, just in case.
        for _, weapon in pairs(ents.FindByClass(SwitchingToWeapon)) do
            WeaponName = weapon:GetPrintName() or weapon.PrintName or WeaponName
        end
        
        if not WeaponName then
            WeaponName = "undefined"
        end
        
        Switching = true
        
        -- Reset the width of the timer bar.
        TimerW = 0
    end)

    hook.Add('CreateMove', 'CoolMovePro', function(cmd)
        if Switching then
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2)
        end
    end)

    dbgView = dbgView or {}

dbgView.disabledWeps = {
    gmod_camera = true,
    gmod_tool = true,
    weapon_physgun = true
}
local ply, anc, prevang, lookOffActive, blind = NULL, NULL, Angle(), false, false
local ply = LocalPlayer()
local chPosOff, chAngOff = Vector(0, 0, 0), Angle(0, 90, 90) --octoteam/icons/percent0.png
local sens, lastModel, lastVeh = GetConVar('sensitivity'):GetFloat(), '', NULL
local traceMaxs, traceMins = Vector(5, 5, 3), Vector(-5, -5, -3)
local angle_zero = Angle()

local function postDrawTranslucentRenderables()
	local ply = LocalPlayer()
    local override = hook.Run('dbg-view.chShouldDraw', ply)
    if override == nil then
        local wep, veh = ply:GetActiveWeapon(), ply:GetVehicle()
        if IsValid(wep) and not dbgView.disabledWeps[wep:GetClass()] and wep.DrawCrosshair then
            override = not IsValid(veh) or ply:GetAllowWeaponsInVehicle()
        end
    end

    if not override then
        return
    end

    local aim = ply:EyeAngles():Forward()
    local tr = hook.Run('dbg-view.chTraceOverride')
    --local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
    if not tr then
        local pos = ply:GetShootPos() --eyes.Pos
        local endpos = pos + aim * 2200
        tr = util.TraceLine({
            start = pos,
            endpos = endpos,
            filter = function(ent)
                return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
            end
        })
    end

    local _icon = hook.Run('dbg-view.chOverride', tr)
    local n = tr.Hit and tr.HitNormal or -aim
    if math.abs(n.z) > 0.98 then
        n:Add(-aim * 0.01)
    end
    local chPos, chAng = LocalToWorld(chPosOff, chAngOff, tr.HitPos or endpos, n:Angle())
    cam.Start3D2D(chPos, chAng, math.pow(tr.Fraction, 0.5) * (0.25))
    cam.IgnoreZ(true)
    if not hook.Run('dbg-view.chPaint', tr, _icon) then
        if _icon then
            surface.SetDrawColor(255, 255, 255, 150)
        end
    end
    cam.IgnoreZ(false)
    cam.End3D2D()

end
hook.Add('PostDrawTranslucentRenderables', 'dbg-view', postDrawTranslucentRenderables)

local delays = {}

surface.CreateFont('switchfont', {
    font = 'Calibri',
    size = 52,
    weight = 350,
    extended = true,
    antialias = true,
    shadow = false,
})

local cx, cy = 0, 0
local size1 = 45
local size2 = 40
local p1, p2 = {}, {}
for i = 1, 36 do
    local a1 = math.rad((i - 1) * -10 + 180)
    local a2 = math.rad(i * -10 + 180)
    p1[i] = {
        x = cx + math.sin(a1) * size1,
        y = cy + math.cos(a1) * size1
    }
    p2[i] = {
        {
            x = cx,
            y = cy
        },
        {
            x = cx + math.sin(a1) * size2,
            y = cy + math.cos(a1) * size2
        },
        {
            x = cx + math.sin(a2) * size2,
            y = cy + math.cos(a2) * size2
        },
    }
end
local override
hook.Add('dbg-view.chShouldDraw', 'octolib.delay', function()
    override = table.Count(delays) > 0
    if override then
        return true          
    end
end)

hook.Add('dbg-view.chPaint', 'octolib.delay', function(tr, icon)
    for id, data in pairs(delays) do
        local segs = math.min(math.ceil((CurTime() - data.start) / data.time * 36), 36)
        --local text = data.text .. ('.'):rep(math.floor(CurTime() * 2 % 4))
        --draw.SimpleText(text, 'switch-font-sh', 0 + 60, -20, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        --draw.SimpleText(text, 'switch-font', 0 + 60, -20, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if GetConVarNumber('lrp_switchpos') == 0 then
            draw.SimpleTextOutlined("R - Отмена", 'switchfont', 70, 0, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200))
        else
            draw.SimpleTextOutlined("R - Отмена", 'switchfont', 0, 80, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200))
        end

        draw.NoTexture()
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawPoly(p1)
        surface.SetDrawColor(255, 255, 255, 170)
        for i = 1, segs do
            surface.DrawPoly(p2[i])
        end
        return true
    end
end)

hook.Add('dbg-view.chOverride', 'octolib.delay', function(tr, icon)
    local ply = LocalPlayer()
    --local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
    if override and (not tr.Hit or tr.Fraction > 0.03) then
        local aim = (ply.viewAngs or ply:EyeAngles()):Forward()
        tr.HitPos =  ply:GetShootPos() + aim * 67,5 --eyes.Pos
        tr.HitNormal = -aim
        tr.Fraction = 0.03
    end
end)

    net.Receive("WepSwitch_EnableSwitch", function()
        
        local weapon = net.ReadString()
        
        if weapon == "NULL" then
            CanSwitch = false
            Switching = false
            return
        end
        
        CanSwitch = true
        
        net.Start("WepSwitch_EnableSwitch_received")
            net.WriteString( WeaponName or "" )
        net.SendToServer()
    end)

    net.Receive("WepSwitch_DisableSwitch", function()
        CanSwitch = false
        Switching = false
        FirstSwitch = false
        
    end)
    
    net.Receive("WepSwitch_SendSwitchingPly", function()
        local SteamID = net.ReadString()
        local bool = net.ReadBit()

        for _, ply in pairs(player.GetAll()) do
            if ply:SteamID() == SteamID then
                if bool == 1 then
                    ply.SwitchingWeapon = true
                else
                    ply.SwitchingWeapon = false
                end
            end
        end
        
    end)
    
    local CanChangeColor = 1
    
    local function PaintTimer()
        if Switching then
            local id = 1
            local time = NewEquipTime 
            local text = 'Смена оружия'
	        if (cd or 0) < CurTime() then
	            cd = CurTime() + time * 2
	            delays[id] = {
	                text = text,
	                start = CurTime(),
	                time = time,
	            }
	        end
        else
        	cd = 0
        	local id = 1
 			local time = NewEquipTime
 			delays[id] = nil
        end
    end

    hook.Add("DrawOverlay", "WeaponSwitch_Paint", PaintTimer)
    
end

local function IsWhitelisted(weapon)
    if table.HasValue(whitelist, weapon:GetClass()) then return true end
    return false
end

local function OnWeaponSwitch(ply, old, new)

    if IsWhitelisted(new) then -- Skip the weapon switch.
        
        if not CanSwitchToWsWhileSwitching then
        
            if SERVER then
                
                if ply.IsSwitchingWeapons then
                    return true
                end
                
            else
            
                if Switching then
                    return true
                end
                
            end
        end
        
    else
    
        if SERVER then
            if GetConVarNumber("lrp_silentswitch") == 0 then
                ply:EmitSound( "npc/combine_soldier/gear5.wav", 60, 100 )
            end

            ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
            ply:SetAnimation(PLAYER_ATTACK1)
            -- If player isn't switching these should both be false.
            
            if not ply.CantSwitch and not ply.IsSwitchingWeapons then
                WeaponSwitch:DelayEquip(ply, new, old)
            end

            -- Will be true after the timer succeeded, so we can switch the weapon.
            if not ply.CantSwitch then
                
                if EnableSendChatMessage then
                    if ply.weaponName and ply.weaponName != "" then
                        SendChatMessage( ply, ply.weaponName )
                        ply.weaponName = ""
                    end
                end
                
                ply.IsSwitchingWeapons = false
                return false
            else
                return true
            end
            
        else

            --LocalPlayer():EmitSound("physics/cardboard/cardboard_box_break1.wav",50)
            ply:EmitSound( "npc/combine_soldier/gear5.wav", 60, 100 )
            ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
        
            if not CanSwitch then
                return true
            end

            if SwitchingToWeapon == new:GetClass() then -- Should be, just to make sure.
                SwitchingToWeapon = ""
                CanSwitch = false
                return false
            else
                return true
            end
            
        end
    end
    
end
hook.Add("PlayerSwitchWeapon", "WeaponSwitch_Hook", OnWeaponSwitch)