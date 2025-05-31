CreateClientConVar('cl_lrp_push_hint', '1', true, false, 'Enable display push hint at crosshair')

local cfg = lrp_cfg

local dist = cfg.pushDist
local hintBlacklist = cfg.pushHintBlacklist

hook.Add('PostDrawTranslucentRenderables', 'lrp-gamemode.push', function()
    if not GetConVar('cl_lrp_push_hint'):GetBool() or hook.Run('dbg-view.chShouldDraw') then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() or ply:InVehicle() or ply:GetViewEntity() ~= ply then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or hintBlacklist[wep:GetClass()] or not wep.DrawCrosshair then return end

    local eyeTrace = ply:GetEyeTrace()
    local target = eyeTrace.Entity

    if not IsValid(target) or not target:IsPlayer() or target == ply then return end
    if not target:Alive() or target:GetMoveType() ~= MOVETYPE_WALK then return end

    if ply:GetPos():DistToSqr(target:GetPos()) > dist * dist then return end

    local aim = ply:EyeAngles():Forward()
    local pos = ply:GetShootPos()
    
    local endpos = pos + aim * 2000
    
    local tr = util.TraceLine({
        start = pos,
        endpos = endpos,
        filter = function(ent)
            return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
        end
    })

    local chPos, chAng = LocalToWorld(Vector(0, 0, 0), Angle(0, -90, 90), tr.HitPos or endpos, ply:EyeAngles())

    cam.Start3D2D(chPos, chAng, math.pow(tr.Fraction, 0.6) * 0.4)
    cam.IgnoreZ(true)
        draw.SimpleTextOutlined(lrp.lang('lrp_gm.push_hint'), 'lrp-postDraw.font', 40, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 230))
    cam.IgnoreZ(false)
    cam.End3D2D()
end)