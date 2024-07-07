include("shared.lua")

SWEP.PrintName = 'Электрошокер'
SWEP.Slot = 5
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

net.Receive("tazestartview", function()
	local rag = net.ReadEntity()
	LocalPlayer().viewrag = rag
end)
net.Receive("tazeendview", function()
	LocalPlayer().viewrag = nil
end)

hook.Add("PlayerBindPress", "Tazer", function(ply,bind,pressed)
	if IsValid(ply:GetNWEntity("tazerviewrag")) and STUNGUN.Thirdperson and STUNGUN.AllowSwitchFromToThirdperson then
		if bind == "+duck" then
			if ply.thirdpersonview == nil then
				ply.thirdpersonview = false
			end

			ply.thirdpersonview = not ply.thirdpersonview
		end
	end
end)

local dist = 200
local view = {}
hook.Add("CalcView", "Tazer", function(ply, origin, angles, fov)
	local rag = ply:GetNWEntity("tazerviewrag")
	if IsValid(rag) then
		local bid = rag:LookupBone("ValveBiped.Bip01_Head1")
		if bid then
			local dothirdperson = false
			if STUNGUN.Thirdperson then
				if STUNGUN.AllowSwitchFromToThirdperson then
					dothirdperson = ply.thirdpersonview
				else
					dothirdperson = true
				end
			end

			if dothirdperson then
				local ragpos = rag:GetBonePosition(bid)

				local pos = ragpos - (ply:GetAimVector() * dist)
				local ang = (ragpos - pos):Angle()

				-- Do a traceline so he can't see through walls
				local trdata = {}
				trdata.start = ragpos
				trdata.endpos = pos
				trdata.filter = rag
				local trres = util.TraceLine(trdata)
				if trres.Hit then
					pos = trres.HitPos + (trres.HitWorld and trres.HitNormal * 3 or vector_origin)
				end

				view.origin = pos
				view.angles = ang
			else
				rag:ManipulateBoneScale(bid, Vector(0.5, 0.5, 0.5))
				local pos,ang = rag:GetBonePosition(bid)
				pos = pos + ang:Forward() * 7
				ang:RotateAroundAxis(ang:Up(), -90)
				ang:RotateAroundAxis(ang:Forward(), -90)
				pos = pos + ang:Forward() * 1

				view.origin = pos
				view.angles = ang
			end

			view.drawviewer = false

			return view
		end
	end
end)

local minpos, minang = Vector(-16384, -16384, -16384), Angle(0,0,0)
hook.Add("CalcViewModelView", "Stungun", function(wep)
	if IsValid(wep.Owner) and IsValid(wep.Owner:GetNWEntity("tazerviewrag")) then
		return minpos, minang
	end
end)

--[[
Effects
]]
hook.Add("OnEntityCreated", "StungunRagdoll", function(ent)
	if ent:IsRagdoll() then
		local ply = ent:GetDTEntity(1)

		if IsValid(ply) and ply:IsPlayer() then
			-- Only copy any decals if this ragdoll was recently created
			if ent:GetCreationTime() > CurTime() - 1 then
				ent:SnatchModelInstance(ply)
			end

			-- Copy the color for the PlayerColor matproxy
			local playerColor = ply:GetPlayerColor()
			ent.GetPlayerColor = function()
				return playerColor
			end
		end
	end
end)

hook.Add("EntityRemoved", "StungunRagdoll", function(ent)
	if ent:IsRagdoll() then
		local ply = ent:GetDTEntity(1)

		if IsValid(ply) and ply:IsPlayer() then
			ply:SnatchModelInstance(ent)
		end
	end
end)

local function IsOnScreen(pos)
	return pos.x > 0 and pos.x < w and pos.y > 0 and pos.y < h
end

local function GrabPlyInfo(ply)
	return ply:Nick(), (team.GetColor(ply:Team()) or Color(255,255,255)), "TargetID"
end

hook.Add("HUDPaint", "Tazer", function()
	-- Draws info about crouch able to switch between third and firstperson
	if STUNGUN.Thirdperson and STUNGUN.AllowSwitchFromToThirdperson and IsValid(LocalPlayer():GetNWEntity("tazerviewrag")) then
		local txt = string.format("Press %s to switch between third and firstperson view.", input.LookupBinding("+duck"))
		draw.SimpleText(txt, "TargetID", ScrW() / 2 + 1, 10 + 1, Color(0,0,0,255), 1)
		draw.SimpleText(txt, "TargetID", ScrW() / 2, 10, Color(200,200,200,255), 1)
	end

	-- Draws custom targetids on rags
	if not STUNGUN.ShowPlayerInfo then return end

	local targ = LocalPlayer():GetEyeTrace().Entity
	if IsValid(targ) and IsValid(targ:GetNWEntity("plyowner")) and LocalPlayer():GetPos():Distance(targ:GetPos()) < 400 then
		local pos = targ:GetPos():ToScreen()
		if IsOnScreen(pos) then
			local ply = targ:GetNWEntity("plyowner")
			local nick,nickclr,font = GrabPlyInfo(ply)
			if not nick then return end -- Someone doesn't want us to draw his info.

			draw.DrawText(nick, font, pos.x-1, pos.y - 51, Color(0,0,0), 1)
			draw.DrawText(nick, font, pos.x, pos.y - 50, nickclr, 1)

			local hp = (ply.newhp and ply.newhp or ply:Health())
			local txt = hp .. "%"

			draw.DrawText(txt, "TargetID", pos.x-1, pos.y - 31, Color(0,0,0), 1)
			draw.DrawText(txt, "TargetID", pos.x, pos.y - 30, Color(255,255,255,200), 1)
		end
	end
end)

-- For some reason, when they're ragdolled their hp isn't sent properly to the clients.
net.Receive("tazersendhealth", function()
	local ent = net.ReadEntity()
	local newhp = net.ReadInt(32)
	ent.newhp = newhp
end)

--[[
Handcuffs support!
]]

local lrender = {
	normal = {
		bone  = "ValveBiped.Bip01_Neck1",
		pos   = Vector(2,1.8,0),
		ang   = Angle(70,90,90),
		scale = Vector(0.06,0.06,0.05),
	},
	alt = { -- Eeveelotions models
		bone  = "Neck",
		pos   = Vector(1,0.5,-0.2),
		ang   = Angle(100,90,90),
		scale = Vector(0.082,0.082,0.082),
	},
}
local LeashHolder = "ValveBiped.Bip01_R_Hand"
local CuffMdl = "models/hunter/tubes/tube2x2x1.mdl"
local DefaultRope = "cable/cable2"
local function LEASHDrawWorldModel(self)
	if not IsValid(self.Owner) then return end

	if not IsValid(self.cmdl_LeftCuff) then
		self.cmdl_LeftCuff = ClientsideModel( CuffMdl, RENDER_GROUP_VIEW_MODEL_OPAQUE )
		if not IsValid( self.cmdl_LeftCuff ) then return end
		self.cmdl_LeftCuff:SetNoDraw( true )
		-- self.cmdl_LeftCuff:SetParent( vm )
	end

	local tbl = lrender.normal
	local lpos, lang = self:GetBonePos( tbl.bone, self.Owner )
	if not (lpos) then
		tbl = lrender.alt
		lpos, lang = self:GetBonePos( tbl.bone, self.Owner )
		if not (lpos) then return end
	end

	self.cmdl_LeftCuff:SetPos( lpos + (lang:Forward() * tbl.pos.x) + (lang:Right() * tbl.pos.y) + (lang:Up() * tbl.pos.z) )
	local u,r,f = lang:Up(), lang:Right(), lang:Forward() -- Prevents moving axes
	lang:RotateAroundAxis( u, tbl.ang.y )
	lang:RotateAroundAxis( r, tbl.ang.p )
	lang:RotateAroundAxis( f, tbl.ang.r )
	self.cmdl_LeftCuff:SetAngles( lang )

	local matrix = Matrix()
	matrix:Scale( tbl.scale )
	self.cmdl_LeftCuff:EnableMatrix( "RenderMultiply", matrix )

	self.cmdl_LeftCuff:SetMaterial( self:GetCuffMaterial() or "" )
	self.cmdl_LeftCuff:DrawModel()

	if self:GetRopeMaterial() != self.LastMatStr then
		self.RopeMat = Material( self:GetRopeMaterial() )
		self.LastMatStr = self:GetRopeMaterial()
	end
	if not self.RopeMat then self.RopeMat = Material(DefaultRope) end

	local ropestart = lpos
	local kidnapper = self:GetKidnapper()
	local ropeend = (kidnapper:IsPlayer() and kidnapper:GetPos() + Vector(0,0,37)) or kidnapper:GetPos()
	if kidnapper != LocalPlayer() or (hook.Call("ShouldDrawLocalPlayer", GAMEMODE, LocalPlayer())) then
		local lBone = kidnapper:LookupBone(LeashHolder)

		if lBone then
			local newPos = kidnapper:GetBonePosition( lBone )
			if newPos and (newPos.x != 0 and newPos.y != 0 and newPos.z != 0) then
				ropeend = newPos
			end
		end
	end

	render.SetMaterial( self.RopeMat )
	render.DrawBeam( ropestart, ropeend, 0.7, 0, 5, Color(255,255,255) )
	render.DrawBeam( ropeend, ropestart, -0.7, 0, 5, Color(255,255,255) )
end

local plymeta = FindMetaTable("Player")
hook.Add("PostDrawOpaqueRenderables", "STUNGUN_CUFFS", function()
	if not plymeta.IsHandcuffed then hook.Remove("PostDrawOpaqueRenderables", "STUNGUN_CUFFS") return end

	for k,v in pairs(ents.FindByClass("prop_ragdoll")) do
		if not v:GetNWString("cuffs_ropemat") or
			not v:GetNWString("cuffs_cuffmat") or
			not isbool(v:GetNWBool("cuffs_isleash")) or
			not IsValid(v:GetNWEntity("cuffs_kidnapper")) then continue end

		if not v.swep then
			local leashowner = v:GetNWEntity("cuffs_kidnapper")
			local isleash = v:GetNWBool("cuffs_isleash")

			v.swep = {
				cuffmat = v:GetNWString("cuffs_cuffmat"),
				ropemat = v:GetNWString("cuffs_ropemat"),
				GetBonePos = weapons.Get("weapon_handcuffed").GetBonePos,
				GetCuffMaterial = function(self) return self.cuffmat end,
				GetRopeMaterial = function(self) return self.ropemat end,
				GetIsLeash = function() return isleash end,
				GetKidnapper = function() return leashowner end,
				Owner = v
			}

			if isleash then
				v.swep.DrawWorldModel = LEASHDrawWorldModel
			else
				v.swep.DrawWorldModel = weapons.Get("weapon_handcuffed").DrawWorldModel
			end
		end

		v.swep:DrawWorldModel()
	end
end)

function SWEP:Initialize() end

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:OnDrop()
	self:Holster()
end

net.Receive("tazerondrop",function()
	local swep = net.ReadEntity()
	swep:OnDrop()
end)