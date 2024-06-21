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
    n[#n + 1] = {
        x = r,
        y = o,
        u = .5,
        v = .5
    }
    for a = 0, e do
        local e = math.rad((a / e) * -360)
        n[#n + 1] = {
            x = r + math.sin(e) * t,
            y = o + math.cos(e) * t,
            u = math.sin(e) / 2 + .5,
            v = math.cos(e) / 2 + .5
        }
    end
end

a()

local a = false
local function i(wep)
    a = true
    local n, t, o = wep:GetShootPos()
    render.PushRenderTarget(r)
    if util.TraceLine({ start = n - t * 25, endpos = n + t * ((wep.SightZNear or 5) + 5), filter = LocalPlayer() }).Hit then
        render.Clear(0, 0, 0, 255)
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

hook.Add("PostDrawOpaqueRenderables", 'lrp-view.sight', function()
    if not handview then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if wep.SightPos and wep.aimProgress and wep.aimProgress > 0 and wep:GetReady() then
        local t = wep:GetOwner()
        local a = t:LookupAttachment('anim_attachment_rh')
        if not a then return end
        local t = t:GetAttachment(a)
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
        surface.SetDrawColor(0, 0, 0, 1)
        draw.NoTexture()
        surface.DrawPoly(n)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilFailOperation(STENCIL_ZERO)
        render.SetStencilZFailOperation(STENCIL_ZERO)
        o:SetTexture('$basetexture', r)
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
end)

hook.Add('PreDrawEffects', 'lrp-view.predrawsight', function()
    if a then return end
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.SightPos and ply:KeyDown(IN_ATTACK2) and wep:GetReady() and handview then
        i(wep)
    end
end)

hook.Add("RenderScene", 'lrp-view.rendersight', function(pos, angle, fov)
    local ply = LocalPlayer()
    if ply:InVehicle() then return end
    if not ply:Alive() then return end

    local view = hook.Run("CalcView", ply, pos, angle, fov)
    
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