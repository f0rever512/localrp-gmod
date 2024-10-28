include('shared.lua')
include('sh_leans.lua')

SWEP.PrintName = 'LocalRP Gun'
SWEP.Author = 'Octothorp Team | forever512'
SWEP.Instructions = 'ПКМ + ЛКМ - Выстрелить\nСКМ - Сменить прицеливание\nALT - Проверить магазин\nЙ / У - Наклониться'
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

CreateClientConVar('cl_lrp_sight_resolution', 512, true)
local sightMaterials = {}
local maskPoly, sightResolution, sightRT, sightMaterial

local function updateSettings()
	sightResolution = GetConVar('cl_lrp_sight_resolution'):GetInt()
	sightRT = GetRenderTarget('weaponSight-' .. sightResolution, sightResolution, sightResolution)
	if not sightMaterials[sightResolution] then
		sightMaterials[sightResolution] = CreateMaterial('weaponSight-' .. sightResolution, 'UnlitGeneric', {})
	end
	sightMaterial = sightMaterials[sightResolution]
	maskPoly = {}

	local x, y, r, seg = 0, 0, sightResolution / 2 - 1, 16
	maskPoly[#maskPoly + 1] = {x = x, y = y, u = 0.5, v = 0.5}
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		maskPoly[#maskPoly + 1] = {x = x + math.sin(a) * r, y = y + math.cos(a) * r, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5}
	end
end
updateSettings()
cvars.AddChangeCallback('cl_lrp_sight_resolution', updateSettings, 'octoweapons')

local isRenderingScope = false
local function renderScope(wep)
	isRenderingScope = true
	local pos, dir, ang = wep:GetShootPos()
	render.PushRenderTarget(sightRT)
	if util.TraceLine({
		start = pos - dir * 15,
		endpos = pos + dir * ((wep.SightZNear or 5) + 2),
		filter = LocalPlayer(),
	}).Hit then
		render.Clear(0,0,0, 255)
	else
		render.RenderView({
			origin = pos,
			angles = ang,
			fov = wep.SightFOV,
			znear = wep.SightZNear,
		})
	end
	render.PopRenderTarget()
	isRenderingScope = false
end

-- local function inOutQuad(t, b, c, d)
--     t = t / d * 2
--     if t < 1 then return c / 2 * math.pow(t, 2) + b end
--     return -c / 2 * ((t - 1) * (t - 3) - 1) + b
-- end

-- function SWEP:CalcView(ply, pos, ang, fov)

-- 	if not self.AimPos then return end

-- 	local animIn = handview and self:GetHoldType() == self.ActiveHoldType and self:GetNetVar('Ready')
-- 	local aimProgress = math.Approach(self.aimProgress or 0, animIn and 1 or 0, FrameTime() * (animIn and 1 or 3))
-- 	self.aimProgress = aimProgress
-- 	if aimProgress <= 0 then return end

-- 	local attID = ply:LookupAttachment('anim_attachment_rh')
-- 	if not attID then return end

-- 	if animIn then
-- 		aimProgress = math.Clamp(aimProgress - 0.4, 0, 1) / 0.6
-- 	end
-- 	local easedProgress = inOutQuad(aimProgress, 0, 1, 1)
-- 	local view = hook.Run("CalcView", LocalPlayer(), ply, pos, ang, fov)
-- 	local att = ply:GetAttachment(attID)
-- 	local tgtPos, tgtAng = LocalToWorld(self.AimPos, self.AimAng, att.Pos, att.Ang)
-- 	view.origin = LerpVector(easedProgress, view.origin, tgtPos)
-- 	view.angles = LerpAngle(easedProgress, view.angles, tgtAng) -- + dbgView.lookOff
-- 	view.znear = 1.5

-- 	return view

-- end

function SWEP:DrawWorldModel()

	self:DrawModel()
	if self.SightPos and self.aimProgress and self.aimProgress > 0 then
		local ply = self:GetOwner()
		local attID = ply:LookupAttachment('anim_attachment_rh')
		if not attID then return end

		local att = ply:GetAttachment(attID)
		local sightPos, sightAng = LocalToWorld(self.SightPos, self.SightAng, att.Pos, att.Ang)

		local minusHalfRes = sightResolution / -2
		cam.Start3D2D(sightPos, sightAng, self.SightSize / sightResolution / 0.9)
			cam.IgnoreZ(true)
			render.ClearStencil()
			render.SetStencilEnable(true)
			render.SetStencilTestMask(255)
			render.SetStencilWriteMask(255)
			render.SetStencilReferenceValue(42)

			-- draw mask
			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			surface.SetDrawColor(0,0,0, 1)
			draw.NoTexture()
			surface.DrawPoly(maskPoly)

			-- draw view
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilFailOperation(STENCIL_ZERO)
			render.SetStencilZFailOperation(STENCIL_ZERO)
			sightMaterial:SetTexture('$basetexture', sightRT)
			sightMaterial:SetFloat('$alpha', math.Clamp(math.Remap(self.aimProgress, 0.6, 1, 0, 1), 0, 1))
			surface.SetMaterial(sightMaterial)
			surface.DrawTexturedRect(minusHalfRes, minusHalfRes, sightResolution, sightResolution)
			surface.SetDrawColor(255,255,255)
			surface.SetMaterial(self.SightMat)
			surface.DrawTexturedRect(minusHalfRes, minusHalfRes, sightResolution, sightResolution)

			render.SetStencilEnable(false)
			cam.IgnoreZ(false)
		cam.End3D2D()
	end

	-- local pos, dir = self:GetShootPosAndDir()
	-- render.DrawLine(pos, pos + dir * 20, color_white, true)
	-- render.DrawWireframeSphere(pos, 1, 5, 5, color_white, true)

end

function SWEP:Reload() end

hook.Add('CreateMove', 'lrp-guns.createmove', function(cmd)
    local wep = LocalPlayer():GetActiveWeapon()

    if IsValid(wep) and wep.Base == 'localrp_gun_base' and wep:GetReady() then
		cmd:RemoveKey(IN_SPEED)
		cmd:RemoveKey(IN_JUMP)
		cmd:RemoveKey(IN_USE)
    end
end)

hook.Add('PreDrawEffects', 'octoweapons', function()
	if isRenderingScope then return end

	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid(wep) and wep.SightPos and wep.aimProgress > 0 then
		renderScope(wep)
	end
end)

-- hook.Add('dbg-view.chTraceOverride', 'octoweapons', function()
-- 	local wep = LocalPlayer():GetActiveWeapon()
-- 	if not IsValid(wep) or not wep.IsOctoWeapon then return end

-- 	local pos, dir = wep:GetShootPosAndDir()
-- 	return util.TraceLine({
-- 		start = pos,
-- 		endpos = pos + dir * 2000,
-- 		filter = function(ent)
-- 			return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
-- 		end
-- 	})
-- end)

hook.Add('RenderScene', 'octoweapons', function(pos, ang, fov)
	local view = hook.Run("CalcView", LocalPlayer(), pos, ang, fov)
	if not view then return end

	render.Clear(0, 0, 0, 255, true, true, true)
	render.RenderView({
		x				= 0,
		y				= 0,
		w				= ScrW(),
		h				= ScrH(),
		angles			= view.angles,
		origin			= view.origin,
		drawhud			= true,
		-- drawviewmodel	= false,
		dopostprocess	= true,
		drawmonitors	= true,
	})

	return true
end)

net.Receive('lrp-muzzleFlash', function()
	local wep = net.ReadEntity()
	if not IsValid(wep) then return end

	local dlight = DynamicLight(wep:EntIndex())
	if dlight then
		dlight.pos = wep:GetShootPos()
		dlight.r = 255
		dlight.g = 145
		dlight.b = 10
		dlight.brightness = 1
		dlight.decay = 5000
		dlight.size = 200
		dlight.dietime = CurTime() + 0.2
		dlight.nomodel = true
	end
end)