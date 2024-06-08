CreateClientConVar("lrp_view", "1", true, false)
CreateClientConVar('lrp_view_crosshair', 1, true, false)
CreateClientConVar('lrp_view_crosshair_color_r', 255, true, false)
CreateClientConVar('lrp_view_crosshair_color_g', 255, true, false)
CreateClientConVar('lrp_view_crosshair_color_b', 255, true, false)
CreateClientConVar("lrp_view_lock", "1", true, false)
CreateClientConVar("lrp_view_lock_max", "70", true, false)

BlackListWeapons = {
	'weapon_physgun',
	'gmod_tool',
	'gmod_camera'
}

HL2WEP = {
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

HandMaterialObjects = {
	"player",
	"prop_physics",
	"prop_ragdoll",
    "func_door",
	"func_door_rotating",
	"prop_door_rotating",
	"func_movelinear"
}

HandMaterialWeapons = {
	"localrp_hands",
	"localrp_cuff_rope",
	"localrp_cuff_police"
}

hook.Add('CreateMove', 'gunsview', function(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not wep.LRPGuns then return end

    -- if handview and wep:GetReloading() then
    --     handview = false
    --     timer.Simple(0.2, function()
    --         handview = true
    --     end)
    -- end
    
	if input.WasMousePressed(109) and ply:KeyDown( IN_ATTACK2 ) and wep:GetReloading() == false then
        if handview != true then
            timer.Simple(0.2, function()
                handview = true
            end)
        elseif handview != false then
            timer.Simple(0.2, function()
                handview = false
            end)
        end
    end
    --[[if ply:KeyReleased(IN_ATTACK2) then
        handview = false
    end]]
    if handview and input.WasMousePressed(108) and wep:GetReloading() == false then
        handview = false
        timer.Simple(0.35, function()
            handview = true
        end)
    end
end)

local function inOutQuad(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * math.pow(t, 2) + b end
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

hook.Add("CalcView", "lrpview", function(ply, pos, angles, fov)
	if GetConVarNumber("lrp_view") == 0 then
        ply:ManipulateBoneScale( ply:LookupBone( "ValveBiped.Bip01_Head1" ), Vector( 1, 1, 1 ) )
        return
    end
	if !ply:Alive() then return end

    local head = ply:LookupBone( "ValveBiped.Bip01_Head1" )
    
    --local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))

    if IsValid(eye) then return end

	local wep = ply:GetActiveWeapon()

	local org = eye.Pos
	local angl = ang

	if IsValid(ply) and IsValid(wep) then
        if table.HasValue(BlackListWeapons, wep:GetClass()) then 
            ply:ManipulateBoneScale(head, Vector( 1, 1, 1 ) )
            return
        end
    end

    if ply:GetViewEntity() == ply then
        if !ply:InVehicle() then
            if handview and wep.LRPGuns and ply:KeyDown( IN_ATTACK2 ) and ply:KeyDownLast( IN_ATTACK2 ) and wep:GetReloading() == false then
                ply:ManipulateBoneScale(head, Vector( 0.3, 0.3, 0.3 ) )
            else
                org = eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up()
                ply:ManipulateBoneScale(head, Vector( 1, 1, 1 ) )
            end
        else
            org = eye.Pos + eye.Ang:Forward() * 1.5 --+ eye.Ang:Up() * 1.5
            --angl = eye.Ang
            ply:ManipulateBoneScale(head, Vector( 0.2, 0.2, 0.2 ) )
        end

        if IsValid(wep) and wep.LRPGuns then
            if wep:GetReady() then
                if not wep.AimPos then
                    return
                end
                if handview then
                    local e = math.Approach(wep.aimProgress or 0, 1, FrameTime() * 1.3)
                    wep.aimProgress = e
                    local t = inOutQuad(e, 0, 1, 1)
                    
                    local handAtt = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
        
                    if IsValid(handAtt) then
                        local worldVector, worldAngle = LocalToWorld(wep.AimPos, wep.AimAng, handAtt.Pos, handAtt.Ang)

                        org = LerpVector(t, eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up(), worldVector)
                        angl = LerpAngle(t, angles, worldAngle)
                    end
                elseif !handview then
                    local e = math.Approach(wep.aimProgress or 1, 0, FrameTime() * 1.3)
                    wep.aimProgress = e
                    local t = inOutQuad(e, 0, 1, 1)

                    local handAtt = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

                    if IsValid(handAtt) then
                        local worldVector, worldAngle = LocalToWorld(wep.AimPos, wep.AimAng, handAtt.Pos, handAtt.Ang)

                        org = LerpVector(t, eye.Pos + eye.Ang:Forward() * 2 - eye.Ang:Up(), worldVector)
                        angl = LerpAngle(t, angles, worldAngle)
                    end
                end
                if IsValid(wep) and ply.CalcView then
                    local e = ply:CalcView(ply, pos, ang, fov)
                    if not e then
                        return
                    end
                    org = e.origin
                end
            end
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

hook.Add("CreateMove", "lrplockview", function(ucmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

	if GetConVarNumber("lrp_view") == 0 or GetConVarNumber("lrp_view_lock") <= 0 or not ply:Alive() then return end
    if ply:Alive() and IsValid(wep) and table.HasValue(BlackListWeapons, wep:GetClass()) then return end

	EA = ucmd:GetViewAngles()
    down = math.Clamp(-GetConVarNumber("lrp_view_lock_max") + 5, -90, -70)
    up = math.Clamp(GetConVarNumber("lrp_view_lock_max"), 75, 90)

	if !ply:InVehicle() then
		ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down), up), EA.y, EA.r))
	else
		ucmd:SetViewAngles(Angle(math.min(math.max(EA.p, down + 40), up - 40), math.Clamp(EA.y, 0, 170), EA.r))
	end
end)

hook.Add("CalcView", "DeathView", function( ply, origin, angles, fov )
    if GetConVarNumber("lrp_view") == 0 then return end
    if LocalPlayer():Alive() and table.HasValue(BlackListWeapons, ply:GetActiveWeapon():GetClass()) then return end

	local ragdoll = ply:GetRagdollEntity();
	
	if (not ragdoll or ragdoll == NULL or not ragdoll:IsValid() ) then return end

	local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )

	local view = {
		origin = eyes.Pos,
		angles = eyes.Ang,
		fov = fov,
	}

	return view
end)

hook.Add("PlayerSpawn", "RemoveDeath", function(ply)
    hook.Remove("CalcView", "DeathView", DeathView)
end)

hook.Add("HUDShouldDraw", "HideCross", function(name)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if ply:Alive() then
        if IsValid(wep) and table.HasValue(BlackListWeapons, wep:GetClass()) or GetConVarNumber("lrp_view") == 0 then
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

hook.Add("PostDrawTranslucentRenderables", "lrpcrosshair", function()
    local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()

    if hook.Run('dbg-view.chShouldDraw') then return end

    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    
    if (bSkybox) then return end

    if wep.LRPGuns then
        local e = {}
            e.start = ply:GetShootPos()
            e.endpos = wep:GetShootPos()
            e.filter = ply

        if util.TraceLine(e).Hit then return end
    end

	if GetConVarNumber("lrp_view_crosshair") == 0 or GetConVarNumber("lrp_view") == 0 then return end
	if !ply:Alive() then return end
    if !IsValid(wep) then return end
    if IsValid(wep) and table.HasValue(BlackListWeapons, wep:GetClass()) then return end

	local crosshair_mat = Material("materials/lrp_dot.png")
	local hand_mat = Material("materials/lrp_hand.png")

    --local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
    --local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
    
    if !ply:InVehicle() then
        if IsValid(wep) then
            if wep.LRPGuns and ply:KeyDown( IN_ATTACK2 ) and ply:KeyDownLast( IN_ATTACK2 ) and wep:GetReloading() == false then
                pos, aim = wep:GetShootPos()
            elseif wep.DrawCrosshair or table.HasValue(HL2WEP, wep:GetClass()) then
                aim = ply:EyeAngles():Forward()
                pos = ply:GetShootPos() --eyes.Pos
            else
                return
            end
        end
    end

    if !ply:InVehicle() and ply:GetViewEntity() == ply and IsValid(aim) then
        local endpos = pos + aim * 1800
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
        if IsValid(wep) then
            if table.HasValue(HandMaterialObjects, trace.Entity:GetClass()) and ply:GetShootPos():Distance(trace.HitPos) < 90 and table.HasValue(HandMaterialWeapons, wep:GetClass()) then
                cam.Start3D2D(Pos, Ang, math.pow(tr.Fraction, 0.6) * 0.3)
                cam.IgnoreZ(true)
                    surface.SetDrawColor(GetConVar('lrp_view_crosshair_color_r'):GetInt(), GetConVar('lrp_view_crosshair_color_g'):GetInt(), GetConVar('lrp_view_crosshair_color_b'):GetInt(), 225)
                    surface.SetMaterial(hand_mat)
                    surface.DrawTexturedRect(-45, -45, 75, 75)
                cam.IgnoreZ(false)
                cam.End3D2D()
            elseif (wep.LRPGuns and !handview and ply:KeyDown( IN_ATTACK2 ) and ply:KeyDownLast( IN_ATTACK2 ) and wep:GetReloading() == false) or wep.DrawCrosshair or table.HasValue(HL2WEP, wep:GetClass()) then
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

hook.Add("PostDrawHUD", "BlackScreen", function()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if GetConVarNumber("lrp_view") == 0 then return end
    if ply:Alive() and IsValid(wep) and table.HasValue(BlackListWeapons, ply:GetActiveWeapon():GetClass()) then return end
    local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
    local hand = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))

    if wep.LRPGuns and handview and ply:KeyDown( IN_ATTACK2 ) and ply:KeyDownLast( IN_ATTACK2 ) and ply:IsValid() and ply:Alive() and IsValid(ply) and IsValid(wep) and IsValid(hand) then

        local tr = {
            start = hand.Pos,
            endpos = hand.Pos,
            mins = Vector( -1, -1, 0 ),
            maxs = Vector( 1, 1, 1 )
        }

        local hullTrace = util.TraceHull( tr )

        if ( hullTrace.Hit && hullTrace.Entity:GetClass() ~= "player" && hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" && LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP ) then
            draw.RoundedBox(0, -1, -1, ScrW() + 1, ScrH() + 1, Color(0, 0, 0, 255))
        end
    else
        local tr = {
            start = eye.Pos + eye.Ang:Forward() * 2.2 - eye.Ang:Up(),
            endpos = eye.Pos,
            mins = Vector( -1, -1, 0 ),
            maxs = Vector( 1, 1, 1 )
        }
        local hullTrace = util.TraceHull( tr )
        if ( hullTrace.Hit && hullTrace.Entity:GetClass() ~= "player" && hullTrace.Entity:GetClass() ~= "gmod_sent_vehicle_fphysics_base" && LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP ) then
            draw.RoundedBox(0, -1, -1, ScrW() + 1, ScrH() + 1, Color(0, 0, 0, 255))
        end
    end
end)

local t = {}
local n, e, r, o
local function a()
    e = 360
    r = GetRenderTarget('weaponSight-' .. e, e, e)
    if not t[e] then
        t[e] = CreateMaterial('weaponSight-' .. e, 'UnlitGeneric', {})
    end
    o = t[e]
    n = {}
    local r, o, t, e = 0, 0, e / 2, 24
    n[#n+1] = {
        x = r,
        y = o,
        u = .5,
        v = .5
    }
    for a = 0, e do
        local e = math.rad( (a/e)*-360 )
        n[#n+1] = {
            x = r+math.sin(e)*t,
            y = o+math.cos(e)*t,
            u = math.sin(e)/2+.5,
            v = math.cos(e)/2+.5
        }
    end
end

a()

local a = false
local function i(wep)
    a = true
    local n, t, o = wep:GetShootPos()
    render.PushRenderTarget(r)
    if util.TraceLine({start=n-t*25,endpos=n+t*((wep.SightZNear or 5)+5),filter=LocalPlayer(),}).Hit then
        render.Clear(0,0,0,255)
    else
        render.RenderView({
            origin = n,
            angles = o,
            fov = wep.SightFOV,
            znear = wep.SightZNear,
        })
    end
    render.PopRenderTarget()
    a = false
end

hook.Add("PostDrawOpaqueRenderables", "Sight", function()
    if !handview then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if wep.SightPos and wep.aimProgress and wep.aimProgress > 0 and wep:GetReady() then
        local t = wep:GetOwner()
        local a = t:LookupAttachment('anim_attachment_rh')
        if not a then return end
        local t = t:GetAttachment(a)
        if IsValid(t) then
            local l, a = LocalToWorld(wep.SightPos, wep.SightAng, t.Pos, t.Ang)
            local t = e / -2
            cam.Start3D2D(l, a, wep.SightSize / e * 1.1)
                cam.IgnoreZ(true)
                render.ClearStencil()
                render.SetStencilEnable(true)
                render.SetStencilTestMask(255)
                render.SetStencilWriteMask(255)
                render.SetStencilReferenceValue(42)
                render.SetStencilCompareFunction(STENCIL_ALWAYS)
                render.SetStencilFailOperation(STENCIL_KEEP)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                render.SetStencilZFailOperation(STENCIL_KEEP)
                surface.SetDrawColor(0,0,0,1)
                draw.NoTexture()
                surface.DrawPoly(n)
                render.SetStencilCompareFunction(STENCIL_EQUAL)
                render.SetStencilFailOperation(STENCIL_ZERO)
                render.SetStencilZFailOperation(STENCIL_ZERO)
                o:SetTexture('$basetexture',r)
                o:SetFloat('$alpha',math.Clamp(math.Remap(wep.aimProgress,.1,1,0,1),0,1))
                surface.SetMaterial(o)
                surface.DrawTexturedRect(t,t,e,e)
                surface.SetDrawColor(255,255,255)
                surface.SetMaterial(LocalPlayer():GetActiveWeapon().SightMat)
                surface.DrawTexturedRect(t-10,t-10,e+20,e+20)
                render.SetStencilEnable(false)
                cam.IgnoreZ(false)
            cam.End3D2D()
        end
    end
end)

hook.Add('PreDrawEffects', 'predrawguns', function()
    if a then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) and wep.SightPos and LocalPlayer():KeyDown(IN_ATTACK2) and wep:GetReady() then
        i(wep)
    end
end)

hook.Add("RenderScene","renderguns",function(pos, angle, fov)
    if LocalPlayer():InVehicle() then return end
    if !LocalPlayer():Alive() then return end

    local view = hook.Run("CalcView", LocalPlayer(), pos, angle, fov)
    
    if not view then
        return
    end

    render.Clear(0, 0, 0, 255, true, true, true)
    
    render.RenderView({
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            angles = view.angles,
            origin = view.origin,
            drawhud = true,
            --drawviewmodel = false,
            dopostprocess = true,
            drawmonitors = true
        })

    return true
end)