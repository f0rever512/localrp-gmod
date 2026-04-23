include('shared.lua')
include('sh_leans.lua')

local outQuad = math.ease.OutQuad

SWEP.PrintName = 'LocalRP Gun'
SWEP.Author = 'Octothorp Team | forever512'
SWEP.Instructions = 'ПКМ + ЛКМ - Выстрелить\nСКМ - Сменить прицеливание\nALT - Проверить магазин\nЙ / У - Наклониться'
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

function SWEP:Holster()

    local ply = self:GetOwner()

    self:SetReady(false)
    self:SetReloading(false)
    self.aimProgress = 0
    ply:SetNW2Int('TFALean', 0)
	ply:ManipulateBoneAngles(ply:LookupBone('ValveBiped.Bip01_R_Hand'), Angle(0, 0, 0))

    return true

end

function SWEP:OnRemove()
    self:SetReady(false)
    self:SetReloading(false)
end

function SWEP:Reload() end

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
	local pos, dir, ang = wep:GetMuzzleInfo()
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

end

function SWEP:Think()

	self.visualRecoil = Lerp(FrameTime() * 10, self.visualRecoil or 0, 0)

	self:FingerAnimation()

end

function SWEP:FingerAnimation()

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local finger = ply:LookupBone('ValveBiped.Bip01_R_Finger11')
    if not finger then return end

    if self.FingerAnimStep == 0 then return end

	if self.Primary.Automatic and ply:KeyDown(IN_ATTACK) then
		self.FingerAnimStep = 1
	else
    	self.FingerAnimStep = math.Approach(self.FingerAnimStep, 0, FrameTime() * 5)
	end

    local ease = outQuad(self.FingerAnimStep)
    ply:ManipulateBoneAngles(finger, Angle(0, ease * -30, 0), false)

end

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

hook.Add('RenderScene', 'lrp-guns', function(pos, ang, fov)

	local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not (IsValid(wep) and wep.Base == 'localrp_gun_base' and wep.aimProgress and wep.aimProgress > 0) then
        return
    end

	local view = hook.Run('CalcView', ply, pos, ang, fov)
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

hook.Add('lrp-view.chTraceOverride', 'lrp-guns', function()
	local wep = LocalPlayer():GetActiveWeapon()
	if not IsValid(wep) or wep.Base ~= 'localrp_gun_base' or not wep:GetReady() then return end

	local pos, dir = wep:GetMuzzleInfo()
	return util.TraceLine({
		start = pos,
		endpos = pos + dir * 1600,
		filter = function(ent)
			return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
		end
	})
end)

hook.Add('lrp-view.chShouldDraw', 'lrp-guns', function(tr)
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or wep.Base ~= 'localrp_gun_base' then return end

	local tr = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = wep:GetMuzzleInfo(),
        filter = ply
    })

	if wep.aimProgress <= 0.5 and wep:GetReady() and not tr.Hit then
		return true
	end
end)

net.Receive('lrp-guns.muzzleFlash', function()

	local wep = net.ReadEntity()
	local wepPos = net.ReadVector()

	if not IsValid(wep) then return end

	local dlight = DynamicLight(wep:EntIndex())
	if dlight then
		dlight.pos = wepPos
		dlight.r = 255
		dlight.g = 145
		dlight.b = 10
		dlight.brightness = 1
		dlight.decay = 5000
		dlight.size = 200
		dlight.dietime = CurTime() + 0.2
		dlight.nomodel = true
	end

	if not ( wep == LocalPlayer():GetActiveWeapon() and wep.SightPos
		and wep.aimProgress and wep.aimProgress > 0 ) then

		local ef = EffectData()
		ef:SetEntity(wep)
		ef:SetAttachment(wep:LookupAttachment('muzzle'))
		ef:SetFlags(1)

		util.Effect('MuzzleFlash', ef)
	end

end)
