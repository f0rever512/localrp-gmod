include('lrp_sight.lua')

CreateClientConVar("lrp_view", "1", true, false)
CreateClientConVar('lrp_view_crosshair', 1, true, false)
CreateClientConVar('lrp_view_crosshair_color_r', 255, true, false)
CreateClientConVar('lrp_view_crosshair_color_g', 255, true, false)
CreateClientConVar('lrp_view_crosshair_color_b', 255, true, false)
CreateClientConVar("lrp_view_lock", "1", true, false)
CreateClientConVar("lrp_view_lock_max", '75', true, false)

local blackList = {
    'weapon_physgun',
    'gmod_tool',
    'gmod_camera'
}

local function wepclass(list)
    local wep = LocalPlayer():GetActiveWeapon()
    return table.HasValue(list, wep:GetClass())
end

hook.Add("CalcView", 'lrp-view', function(ply, pos, angles, fov)
    local head = ply:LookupBone("ValveBiped.Bip01_Head1")
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    if GetConVarNumber("lrp_view") == 0 then
        ply:ManipulateBoneScale(head, Vector(1, 1, 1))
        return
    end
    
    if not eye then return end

    local wep = ply:GetActiveWeapon()
    local org, angl = eye.Pos, angles
    if IsValid(ply) and IsValid(wep) and ply:Alive() then
        if wepclass(blackList) then
            return
        end
    end

    if ply:GetViewEntity() == ply then
        if ply:Alive() then
            if not ply:InVehicle() then
                org = eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up()
                ply:ManipulateBoneScale(head, Vector(1, 1, 1))
            else
                org = eye.Pos + eye.Ang:Forward() * 1.5
                ply:ManipulateBoneScale(head, Vector(0.2, 0.2, 0.2))
            end
            if IsValid(wep) and wep.LRPGuns then
                local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
                local worldVector, worldAngle = LocalToWorld(wep.AimPos, wep.AimAng, hand.Pos, hand.Ang)
                local function switchaiming(x, y)
                    local function inOutQuad(t, b, c, d)
                        t = t / d * 2
                        if t < 1 then return c / 2 * math.pow(t, 2) + b end
                        return -c / 2 * ((t - 1) * (t - 3) - 1) + b
                    end
                    if not wep:GetReady() or wep:GetReloading() then
                        coef = 2.5
                    elseif not handview then
                        coef = 1.6
                    end
                    local e = math.Approach(wep.aimProgress or x, y, FrameTime() * coef)
                    wep.aimProgress = e
                    local t = inOutQuad(e, 0, 1, 1)
                    org = LerpVector(t, eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up(), worldVector)
                    angl = LerpAngle(t, angles, worldAngle)
                end
                if hand then
                    if wep:GetReady() and handview then
                        ply:ManipulateBoneScale(head, Vector(0.3, 0.3, 0.3))
                        switchaiming(0, 1)
                    elseif not wep:GetReady() or not handview or wep:GetReloading() then
                        timer.Simple( 0.2, function()
                            ply:ManipulateBoneScale(head, Vector(1, 1, 1))
                        end)
                        switchaiming(1, 0)
                    end
                else
                    handview = false
                end
            end
        else
            local ragdoll = ply:GetRagdollEntity()
            if not ragdoll or not ragdoll:IsValid() then return end

            local eye = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
            if not eye then return end
            
            org, angl = eye.Pos, eye.Ang
        end

        local view = {
            origin = org,
            angles = angl,
            fov = fov,
            drawviewer = true,
            znear = 1
        }
        return view
    end
end)

hook.Add("CreateMove", 'lrp-view.lock', function(ucmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if GetConVarNumber("lrp_view") == 0 or GetConVarNumber("lrp_view_lock") <= 0 or not ply:Alive() then return end
    if ply:Alive() and IsValid(wep) and wepclass(blackList) then return end

    EA = ucmd:GetViewAngles()
    down = math.Clamp(-GetConVarNumber("lrp_view_lock_max") + 5, -90, -70)
    up = math.Clamp(GetConVarNumber("lrp_view_lock_max"), 75, 90)

    if not ply:InVehicle() then
        ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down), up), EA.y, EA.r))
    else
        ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down + 40), up - 40), math.Clamp(EA.y, 0, 170), EA.r))
    end
end)

hook.Add("HUDShouldDraw", 'lrp-view.hidecross', function(name)
    local ply = LocalPlayer()
    if ply and ply:IsValid() and ply:Alive() and ply.GetActiveWeapon then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wepclass(blackList) or GetConVarNumber("lrp_view") == 0 then
            if name == "CHudCrosshair" then
                return true
            end
        elseif GetConVarNumber("lrp_view") == 1 then
            if name == "CHudCrosshair" then
                return false
            end
        end
    end
end)

hook.Add("PostDrawTranslucentRenderables", 'lrp-view.cross', function()
    local handmatentity = {
        "player",
        "func_door",
        "func_door_rotating",
        "prop_door_rotating",
        "func_movelinear"
    }

    local hl2wep = {
        'weapon_357',
        'weapon_pistol',
        'weapon_bugbait',
        'weapon_crossbow',
        'weapon_crowbar',
        'weapon_frag',
        'weapon_physcannon',
        'weapon_ar2',
        'weapon_rpg',
        'weapon_slam',
        'weapon_shotgun',
        'weapon_smg1',
        'weapon_stunstick'
    }

    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if hook.Run('dbg-view.chShouldDraw') then return end
    
    if wep.LRPGuns then
        local e = {
            start = ply:GetShootPos(),
            endpos = wep:GetShootPos(),
            filter = ply
        }

        if util.TraceLine(e).Hit then return end
    end

    if GetConVarNumber("lrp_view_crosshair") == 0 or GetConVarNumber("lrp_view") == 0 then return end
    if not ply:Alive() then return end
    if not IsValid(wep) then return end
    if IsValid(wep) and wepclass(blackList) then return end

    local crosshair_mat = Material("materials/lrp_dot.png")
    local hand_mat = Material("materials/lrp_hand.png")

    --local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    --local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

    local pos, aim
    if not ply:InVehicle() then
        if IsValid(wep) then
            if wep.LRPGuns then
                pos, aim = wep:GetShootPos()
            elseif wep.DrawCrosshair or wepclass(hl2wep) then
                aim = ply:EyeAngles():Forward()
                pos = ply:GetShootPos() --eye.Pos
            else
                return
            end
        end
    end

    if not ply:InVehicle() and ply:GetViewEntity() == ply then
        local endpos = pos + aim * 1800
        local tr = util.TraceLine({
            start = pos,
            endpos = endpos,
            filter = function(ent)
                return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
            end
        })

        local tracehit = tr.Hit and tr.HitNormal or -aim
        local eyetrace = ply:GetEyeTrace()
        local Pos, Ang = LocalToWorld(Vector(0, 0, 0), Angle(0, 90, 90), tr.HitPos or endpos, tracehit:Angle())
        if IsValid(wep) then
            if IsValid(eyetrace.Entity) and ((wep:GetClass() == 'localrp_hands' and (wep:CanPickup(eyetrace.Entity) or table.HasValue(handmatentity, eyetrace.Entity:GetClass())))
            or (wep.DrawCrosshair and table.HasValue(handmatentity, eyetrace.Entity:GetClass())))
            and ply:GetShootPos():Distance(eyetrace.HitPos) < 100 then
                cam.Start3D2D(Pos, Ang, math.pow(tr.Fraction, 0.6) * 0.3)
                cam.IgnoreZ(true)
                    surface.SetDrawColor(GetConVar('lrp_view_crosshair_color_r'):GetInt(), GetConVar('lrp_view_crosshair_color_g'):GetInt(), GetConVar('lrp_view_crosshair_color_b'):GetInt(), 225)
                    surface.SetMaterial(hand_mat)
                    surface.DrawTexturedRect(-45, -45, 75, 75)
                cam.IgnoreZ(false)
                cam.End3D2D()
            elseif (wep.LRPGuns and not handview and ply:KeyDown(IN_ATTACK2) and not wep:GetReloading()) or wep.DrawCrosshair or table.HasValue(hl2wep, wep:GetClass()) then
                cam.Start3D2D(Pos, Ang, math.pow(tr.Fraction, 0.6) * 0.3)
                cam.IgnoreZ(true)
                    surface.SetDrawColor(GetConVar('lrp_view_crosshair_color_r'):GetInt(), GetConVar('lrp_view_crosshair_color_g'):GetInt(), GetConVar('lrp_view_crosshair_color_b'):GetInt(), 225)
                    surface.SetMaterial(crosshair_mat)
                    surface.DrawTexturedRect(-32, -32, 64, 64)
                cam.IgnoreZ(false)
                cam.End3D2D()
            end
        end
    end
end)

hook.Add("PostDrawHUD", 'lrp-view.blackscreen', function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if GetConVarNumber("lrp_view") == 0 then return end
    if ply:Alive() and IsValid(wep) and wepclass(blackList) then return end
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

    if not eye then return end

    if wep.LRPGuns and handview and ply:KeyDown(IN_ATTACK2) and ply:IsValid() and ply:Alive() and IsValid(ply) and IsValid(wep) and hand then
        local tr = {
            start = hand.Pos - hand.Ang:Forward() * 2,
            endpos = hand.Pos,
            mins = Vector(-1, -1, 0),
            maxs = Vector(1, 1, 1)
        }

        local hullTrace = util.TraceHull(tr)
        if hullTrace.Hit and hullTrace.Entity:GetClass() ~= "player" and hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" and LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then
            draw.RoundedBox(0, -1, -1, ScrW() + 1, ScrH() + 1, Color(0, 0, 0, 255))
        end
    else
        local tr = {
            start = eye.Pos + eye.Ang:Forward() * 2.2 - eye.Ang:Up(),
            endpos = eye.Pos,
            mins = Vector(-1, -1, 0),
            maxs = Vector(1, 1, 1)
        }
        local hullTrace = util.TraceHull(tr)
        if hullTrace.Hit and hullTrace.Entity:GetClass() ~= "player" and hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" and LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then
            draw.RoundedBox(0, -1, -1, ScrW() + 1, ScrH() + 1, Color(0, 0, 0, 255))
        end
    end
end)

hook.Add('CreateMove', 'lrp-view.handview', function(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not wep.LRPGuns then return end

    if input.WasMousePressed(109) and wep:GetReady() then
        if not handview then
            timer.Simple(0.2, function()
                handview = true
            end)
        elseif handview then
            timer.Simple(0.2, function()
                handview = false
            end)
        end
    end

    if handview and input.WasMousePressed(108) then
        handview = false
        timer.Simple(0.35, function()
            handview = true
        end)
    end
end)