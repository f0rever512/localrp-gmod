local pushBlacklist = {
    ['weapon_physgun'] = true,
    ['gmod_tool'] = true,
    ['gmod_camera'] = true
} -- Позже вынести в отдельный конфиг-файл
halfVisibleColor = Color(0, 0, 0, 200)

CreateClientConVar('lrp_pushtext', '1', true, true)

hook.Add("PostDrawTranslucentRenderables", 'lrp-push.Text', function()
    if GetConVarNumber('lrp_pushtext') == 0 or GetConVarNumber("lrp_view") == 0 then return end
    if hook.Run('dbg-view.chShouldDraw') then return end

    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not ply:Alive() or not wep.DrawCrosshair or not IsValid(ply) or not IsValid(wep) then return end

    if pushBlacklist[wep:GetClass()] then return end

    local pos = ply:GetShootPos()
    local aim = ply:EyeAngles():Forward()

    if ply:InVehicle() then return end

    local endpos = pos + aim * 100
    tr = util.TraceLine({
        start = pos,
        endpos = endpos,
        filter = function(ent)
            return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
        end
    })
    
    local tracehit = tr.Hit and tr.HitNormal or -aim
    local trace = ply:GetEyeTrace()
    local Pos, Ang = LocalToWorld(Vector(0, 0, 0), Angle(0, 90, 90), tr.HitPos or endpos, tracehit:Angle())
    local ent = ply:GetEyeTrace().Entity
    
    if not ply:IsValid() or not ent:IsValid() then return end
    if not ply:IsPlayer() or not ent:IsPlayer() then return end
    if not ply:Alive() or not ent:Alive() or not ent:GetMoveType() ~= MOVETYPE_WALK then return end

    if ply:GetPos():DistToSqr( ent:GetPos() ) <= 100*100 then
        cam.Start3D2D(Pos, Ang, math.pow(tr.Fraction, 0.9) * 0.08)
        cam.IgnoreZ(true)
            draw.SimpleTextOutlined( "E - Толкнуть", 'postdraw-font', 0, 60, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, halfVisibleColor )
        cam.IgnoreZ(false)
        cam.End3D2D()
    end
end)