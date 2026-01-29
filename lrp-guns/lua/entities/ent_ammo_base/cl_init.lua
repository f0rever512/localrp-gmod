include('shared.lua')

ENT.PrintName 			= 'LRP Base Ammo'
ENT.Author 				= 'forever512'
ENT.Category 			= 'LocalRP - Ammo'

surface.CreateFont('lrp-guns.ammoFont', {
	font = 'Calibri',
	size = 60,
	weight = 400,
	antialias = true,
	extended = true
})

local boxPositions = {
	['_default'] = {
		offset = Vector(0, 0, 11.53),
		angles = Angle(0, 90, 0),
		size = { w = 350, h = 60 },
	},
	-- small
	['models/Items/BoxSRounds.mdl'] = {
		offset = Vector(0, 0, 11.53),
		angles = Angle(0, 90, 0),
		size = { w = 350, h = 60 },
	},
	-- large
	['models/Items/BoxMRounds.mdl'] = {
		offset = Vector(0, 0, 13.4),
		angles = Angle(0, 90, 0),
		size = { w = 380, h = 90 },
	},
	-- shotgun
	['models/Items/BoxBuckshot.mdl'] = {
		offset = Vector(0.5, 0.39, 5.8),
		angles = Angle(0, 90, 0),
		size = { w = 170, h = 60 },
	},
}

local fadeDist = 250
local maxRenderDist = 250
local boxColor = Color(0, 80, 65)

function ENT:Draw()

	self:DrawModel()

	local entPos = self:GetPos()

	local al = math.Clamp(1 - (entPos:DistToSqr(EyePos()) - fadeDist * fadeDist) / (maxRenderDist * maxRenderDist), 0, 1) * 240
	if al <= 0 then return end

	local boxInfo = boxPositions[self.AmmoModel] and boxPositions[self.AmmoModel] or boxPositions['_default']

	local boxPos, boxAngle = LocalToWorld(boxInfo.offset, boxInfo.angles, entPos, self:GetAngles())
	local x, y = boxInfo.size.w * -0.5, boxInfo.size.h * -0.5

	cam.Start3D2D(boxPos, boxAngle, 0.05)

		draw.RoundedBox(8, x, y, boxInfo.size.w, boxInfo.size.h, ColorAlpha(boxColor, al))
		draw.SimpleText(self.PrintName, 'lrp-guns.ammoFont', 0, -2, Color(255, 255, 255, al), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	cam.End3D2D()

end
