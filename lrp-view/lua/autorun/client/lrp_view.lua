CreateClientConVar("lrp_view", "1", true, false)
CreateClientConVar('lrp_view_crosshair', 1, true, false)
CreateClientConVar('lrp_view_crosshair_color_r', 255, true, false)
CreateClientConVar('lrp_view_crosshair_color_g', 255, true, false)
CreateClientConVar('lrp_view_crosshair_color_b', 255, true, false)
CreateClientConVar("lrp_view_lock", "1", true, false)
CreateClientConVar("lrp_view_lock_max", '75', true, false)

local blackList = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true
}

local function inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * math.pow(t, 2) + b end
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

local function IsWepBlacklisted(list)
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) then
        return false
    end
    return list[wep:GetClass()]
end

local function CanViewWork()
    local ply = LocalPlayer()
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    return not ply or not IsValid(ply) or not eye or ply:GetViewEntity() ~= ply or IsValid(ply:GetNW2Entity('playerRagdollEntity')) or IsValid(ply:GetNWEntity("tazerviewrag")) or IsWepBlacklisted(blackList) or GetConVarNumber("lrp_view") == 0
end

hook.Add("CalcView", 'lrp-view', function(ply, pos, angles, fov)
    local head = ply:LookupBone("ValveBiped.Bip01_Head1")
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    if CanViewWork() then
        if eye then
            ply:ManipulateBoneScale(head, Vector(1, 1, 1))
        end
        return
    end

    local wep = ply:GetActiveWeapon()
    local pos, ang = eye.Pos, angles

    if ply:Alive() then
        if not ply:InVehicle() then
            ply:ManipulateBoneScale(head, Vector(0.01, 0.01, 0.01))
            if wep.Base == 'localrp_gun_base' then
                local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
                if hand then
                    local animIn = handview and wep:GetHoldType() == wep.Sight and wep:GetReady()
                    local aimProgress = math.Approach(wep.aimProgress or 0, animIn and 1 or 0, FrameTime() * (animIn and 1.25 or 2.5))
                    wep.aimProgress = aimProgress

                    local recoilCoef = ply:IsListenServerHost() and 10 or 5
                    visualRecoil = Lerp(FrameTime() * recoilCoef, visualRecoil or 0, wep.visualRecoil or 0)
                    
                    local aimPos = Vector(wep.AimPos.x, wep.AimPos.y, wep.AimPos.z + wep.AimPos.z * visualRecoil / 5)
                    local aimAng = Angle(wep:GetShootAng().p - (not wep.SightPos and (wep:GetShootAng().p * visualRecoil * 2.5) or 0), wep:GetShootAng().y, wep:GetShootAng().r)
                    local worldVector, worldAngle = LocalToWorld(aimPos, aimAng, hand.Pos, hand.Ang)
                    local easedProgress = inOutQuad(aimProgress, 0, 1, 1)
                    pos = LerpVector(easedProgress, pos, worldVector)
                    ang = LerpAngle(easedProgress, angles, worldAngle)
                else
                    handview = false
                end
            end
        else
            pos = eye.Pos - eye.Ang:Up() + eye.Ang:Forward() * 1.5
            ply:ManipulateBoneScale(head, Vector(1, 1, 1))
        end
    else
        local ragdoll = ply:GetRagdollEntity()
        if not ragdoll or not ragdoll:IsValid() then return end

        local eye = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
        
        pos, ang = eye.Pos, eye.Ang
    end

    local view = {
        origin = pos,
        angles = ang,
        fov = fov,
        drawviewer = true,
        znear = (wep.Base == 'localrp_gun_base' and wep:GetReady() and handview) and 1.5 or 3
    }
    return view
end)

hook.Add("CreateMove", 'lrp-view.lock', function(ucmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if GetConVarNumber("lrp_view") == 0 or GetConVarNumber("lrp_view_lock") <= 0 or not ply:Alive() then return end
    if ply:Alive() and IsValid(wep) and IsWepBlacklisted(blackList) then return end

    local EA = ucmd:GetViewAngles()
    local down = math.Clamp(-GetConVarNumber("lrp_view_lock_max") + 5, -90, -70)
    local up = math.Clamp(GetConVarNumber("lrp_view_lock_max"), 75, 90)

    if ply:InVehicle() then
        ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down + 40), up - 40), math.Clamp(EA.y, 0, 170), EA.r))
    else
        ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down), up), EA.y, EA.r))
    end
end)

hook.Add("HUDShouldDraw", 'lrp-view.hidecross', function(name)
    if name ~= "CHudCrosshair" then return end

    local ply = LocalPlayer()
    if ply and ply:IsValid() and ply:Alive() and ply.GetActiveWeapon then
        local wep = ply:GetActiveWeapon()
        if IsWepBlacklisted(blackList) or GetConVarNumber("lrp_view") == 0 then
            return true
        elseif GetConVarNumber("lrp_view") == 1 then
            return false
        end
    end
end)

hook.Add("PostDrawTranslucentRenderables", 'lrp-view.cross', function()
    local handmatentity = {
        player = true,
        func_door = true,
        func_door_rotating = true,
        prop_door_rotating = true,
        func_movelinear = true
    }

    local hl2wep = {
        weapon_357 = true,
        weapon_pistol = true,
        weapon_bugbait = true,
        weapon_crossbow = true,
        weapon_crowbar = true,
        weapon_frag = true,
        weapon_physcannon = true,
        weapon_ar2 = true,
        weapon_rpg = true,
        weapon_slam = true,
        weapon_shotgun = true,
        weapon_smg1 = true,
        weapon_stunstick = true
    }

    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if CanViewWork() or not wep or not IsValid(wep) or not ply:Alive() or ply:InVehicle() or GetConVarNumber("lrp_view_crosshair") == 0 then return end
    if IsValid(ply:GetNWEntity("tazerviewrag")) then return end -- for ragdoll view after stungun shot
    if hook.Run('dbg-view.chShouldDraw') then return end -- for lrp switch weapon
    
    if wep.Base == 'localrp_gun_base' then
        local e = {
            start = ply:GetShootPos(),
            endpos = wep:GetShootPos(),
            filter = ply
        }

        if util.TraceLine(e).Hit then return end
    end

    local crosshair_mat = Material("materials/lrp_dot.png")
    local hand_mat = Material("materials/lrp_hand.png")

    --local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    --local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

    local pos, aim
    if wep.Base == 'localrp_gun_base' or wep:GetClass() == 'lrp_stungun' then
        pos, aim = wep:GetShootPos()
    elseif wep.DrawCrosshair or IsWepBlacklisted(hl2wep) then
        pos, aim = ply:GetShootPos(), ply:EyeAngles():Forward() --eye.Pos
    else
        return
    end

    local tr = util.TraceLine({
        start = pos,
        endpos = pos + aim * 1800,
        filter = function(ent) return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA end
    })

    local tracehit = tr.Hit and tr.HitNormal or -aim
    local eyetrace = ply:GetEyeTrace()
    local Pos, Ang = LocalToWorld(Vector(0, 0, 0), Angle(0, 90, 90), tr.HitPos, tracehit:Angle())

    local clr_r, clr_g, clr_b = GetConVar('lrp_view_crosshair_color_r'):GetInt(), GetConVar('lrp_view_crosshair_color_g'):GetInt(), GetConVar('lrp_view_crosshair_color_b'):GetInt()
    local scale = math.pow(tr.Fraction, 0.6) * 0.3

    cam.Start3D2D(Pos, Ang, scale)
    cam.IgnoreZ(true)
    if IsValid(eyetrace.Entity) and ((wep:GetClass() == 'localrp_hands' and (wep:CanPickup(eyetrace.Entity) or handmatentity[eyetrace.Entity:GetClass()]))
    or (wep.DrawCrosshair and handmatentity[eyetrace.Entity:GetClass()]))
    and ply:GetShootPos():Distance(eyetrace.HitPos) < 100 then
        surface.SetDrawColor(clr_r, clr_g, clr_b, 225)
        surface.SetMaterial(hand_mat)
        surface.DrawTexturedRect(-45, -45, 75, 75)
    elseif (wep.Base == 'localrp_gun_base' and not handview and wep:GetReady()) or wep.DrawCrosshair or IsWepBlacklisted(hl2wep) or (wep:GetClass() == 'lrp_stungun' and wep:GetReady()) then
        surface.SetDrawColor(clr_r, clr_g, clr_b, 225)
        surface.SetMaterial(crosshair_mat)
        surface.DrawTexturedRect(-32, -32, 64, 64)
    end
    cam.IgnoreZ(false)
    cam.End3D2D()
end)

hook.Add("PostDrawHUD", 'lrp-view.blackscreen', function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

    if CanViewWork() or not hand or not ply:Alive() or ply:InVehicle() then return end

    if wep.Base == 'localrp_gun_base' and handview and wep:GetReady() then
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
            start = eye.Pos + eye.Ang:Forward() * 2.2,
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

    if ply:InVehicle() then return end
    if wep.Base ~= 'localrp_gun_base' then return end

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