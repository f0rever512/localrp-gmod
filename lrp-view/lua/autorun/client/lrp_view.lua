--🐛

include('lrp_sight.lua')

local cvars = {
    view = CreateClientConVar("lrp_view", "1", true, false),
    crosshair = CreateClientConVar('lrp_view_crosshair', 1, true, false),
    crosshair_color_r = CreateClientConVar('lrp_view_crosshair_color_r', 255, true, false),
    crosshair_color_g = CreateClientConVar('lrp_view_crosshair_color_g', 255, true, false),
    crosshair_color_b = CreateClientConVar('lrp_view_crosshair_color_b', 255, true, false),
    view_lock = CreateClientConVar("lrp_view_lock", "1", true, false),
    view_lock_max = CreateClientConVar("lrp_view_lock_max", '75', true, false)
}

local blackList = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true
}

local function isWeaponBlacklisted(wep)
    if not IsValid(wep) then
        return false
    end
    return blackList[wep:GetClass()]
end

hook.Add("CalcView", 'lrp-view', function(ply, pos, angles, fov)
    if cvars.view:GetInt() == 0 then return end

    local head = ply:LookupBone("ValveBiped.Bip01_Head1")
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))

    if not eye then return end

    local wep = ply:GetActiveWeapon()
    local org, angl = eye.Pos, angles

    if not IsValid(ply) or not IsValid(wep) or not ply:Alive() then return end

    if isWeaponBlacklisted(wep) then return end

    if ply:GetViewEntity() == ply then
        if ply:InVehicle() then
            org = eye.Pos + eye.Ang:Forward() * 1.5
            ply:ManipulateBoneScale(head, Vector(0.2, 0.2, 0.2))
        else
            org = eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up()
            ply:ManipulateBoneScale(head, Vector(1, 1, 1))
        end

        if IsValid(wep) and wep.LRPGuns then
            local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
            if hand then
                local worldVector, worldAngle = LocalToWorld(wep.AimPos, wep.AimAng, hand.Pos, hand.Ang)
                local function switchAiming(x, y)
                    local t = math.Approach(wep.aimProgress or x, y, FrameTime() * 2)
                    wep.aimProgress = t
                    org = LerpVector(t, eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up(), worldVector)
                    angl = LerpAngle(t, angles, worldAngle)
                end

                if wep:GetReady() and handview then
                    ply:ManipulateBoneScale(head, Vector(0.3, 0.3, 0.3))
                    switchAiming(0, 1)
                else
                    timer.Simple(0.2, function() ply:ManipulateBoneScale(head, Vector(1, 1, 1)) end)
                    switchAiming(1, 0)
                end
            end
        end
    else
        local ragdoll = ply:GetRagdollEntity()
        if IsValid(ragdoll) then
            local eye = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
            if eye then
                org, angl = eye.Pos, eye.Ang
            end
        end
    end

    return {
        origin = org,
        angles = angl,
        fov = fov,
        drawviewer = true,
        znear = 1
    }
end)

hook.Add("CreateMove", 'lrp-view.lock', function(ucmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if cvars.view:GetInt() == 0 or cvars.view_lock:GetInt() <= 0 or not ply:Alive() then return end
    if isWeaponBlacklisted(wep) then return end

    local EA = ucmd:GetViewAngles()
    local down = math.Clamp(-cvars.view_lock_max:GetInt() + 5, -90, -70)
    local up = math.Clamp(cvars.view_lock_max:GetInt(), 75, 90)

    if ply:InVehicle() then
        ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down + 40), up - 40), math.Clamp(EA.y, 0, 170), EA.r))
    else
        ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down), up), EA.y, EA.r))
    end
end)

hook.Add("HUDShouldDraw", 'lrp-view.hidecross', function(name)
    if name ~= "CHudCrosshair" then return end

    local ply = LocalPlayer()
    if IsValid(ply) and ply:Alive() and ply.GetActiveWeapon then
        local wep = ply:GetActiveWeapon()
        if isWeaponBlacklisted(wep) or cvars.view:GetInt() == 0 then
            return true
        elseif cvars.view:GetInt() == 1 then
            return false
        end
    end
end)

hook.Add("PostDrawTranslucentRenderables", 'lrp-view.cross', function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not wep or not IsValid(wep) or not ply:Alive() or isWeaponBlacklisted(wep) or cvars.crosshair:GetInt() == 0 or cvars.view:GetInt() == 0 then return end

    local crosshair_mat = Material("materials/lrp_dot.png")
    local hand_mat = Material("materials/lrp_hand.png")

    local pos, aim = ply:GetShootPos(), ply:EyeAngles():Forward()
    if wep.LRPGuns then
        pos, aim = wep:GetShootPos()
    end

    if ply:InVehicle() then return end

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + aim * 1800,
        filter = function(ent) return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA end
    })

    local traceHit = tr.Hit and tr.HitNormal or -aim
    local Pos, Ang = LocalToWorld(Vector(0, 0, 0), Angle(0, 90, 90), tr.HitPos or pos + aim * 1800, traceHit:Angle())

    local clr_r, clr_g, clr_b = cvars.crosshair_color_r:GetInt(), cvars.crosshair_color_g:GetInt(), cvars.crosshair_color_b:GetInt()
    local scale = math.pow(tr.Fraction, 0.6) * 0.3

    cam.Start3D2D(Pos, Ang, scale)
    cam.IgnoreZ(true)
    if ply:GetEyeTrace().Entity and ply:GetEyeTrace().Entity:GetPos():Distance(ply:GetShootPos()) < 100 then
        surface.SetDrawColor(clr_r, clr_g, clr_b, 225)
        surface.SetMaterial(hand_mat)
        surface.DrawTexturedRect(-45, -45, 75, 75)
    elseif (wep.LRPGuns and not handview and ply:KeyDown(IN_ATTACK2) and not wep:GetReloading()) then
        surface.SetDrawColor(clr_r, clr_g, clr_b, 225)
        surface.SetMaterial(crosshair_mat)
        surface.DrawTexturedRect(-32, -32, 64, 64)
    end
    cam.IgnoreZ(false)
    cam.End3D2D()
end)

hook.Add("PostDrawHUD", 'lrp-view.blackscreen', function()
    if cvars.view:GetInt() == 0 then return end

    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) or isWeaponBlacklisted(wep) then return end

    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    if not eye then return end

    local tr = {
        start = eye.Pos + eye.Ang:Forward() * 2.2 - eye.Ang:Up(),
        endpos = eye.Pos,
        mins = Vector(-1, -1, 0),
        maxs = Vector(1, 1, 1)
    }
    local hullTrace = util.TraceHull(tr)
    if hullTrace.Hit and hullTrace.Entity:GetClass() ~= "player" and hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
        draw.RoundedBox(0, -1, -1, ScrW() + 1, ScrH() + 1, Color(0, 0, 0, 255))
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
