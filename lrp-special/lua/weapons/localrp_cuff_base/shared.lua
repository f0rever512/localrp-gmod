AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.Category = "LocalRP - Special"
SWEP.Author = "my_hat_stinks"
SWEP.Instructions = ""

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.AdminSpawnable = false

SWEP.Slot = 3
SWEP.PrintName = "UnnamedHandcuff"

SWEP.ViewModelFOV = 60
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.UseHands = true
SWEP.DrawCrosshair = true

SWEP.Primary.Recoil = 1
SWEP.Primary.Damage = 5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.25

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipMax = -1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipMax = -1

SWEP.DeploySpeed = 1.5

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.AdminOnly = false

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD
SWEP.HoldType = "normal"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.AdminOnly = false

//
// Handcuff Vars
SWEP.CuffTime = 1.0 // Seconds to handcuff
SWEP.CuffSound = Sound( "buttons/lever7.wav" )

SWEP.CuffMaterial = "phoenix_storms/metalfloor_2-3"
SWEP.CuffRope = "cable/cable2"

SWEP.CuffStrength = 1
SWEP.CuffRegen = 1
SWEP.RopeLength = 0

SWEP.CuffReusable = false // Can reuse (ie, not removed on use)
SWEP.CuffRecharge = 0 // Time before re-use

SWEP.CuffBlindfold = false
SWEP.CuffGag = false

SWEP.CuffStrengthVariance = 0 // Randomise strangth
SWEP.CuffRegenVariance = 0 // Randomise regen

//
// Network Vars
function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "IsCuffing" )
	self:NetworkVar( "Entity", 0, "Cuffing" )
	self:NetworkVar( "Float", 0, "CuffTime" )
end

//
// Standard SWEP functions
function SWEP:PrimaryAttack()
	if self:GetIsCuffing() then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	
	if CLIENT then return end
	if self:GetCuffTime()>CurTime() then return end // On cooldown
	
	local tr = self:TargetTrace()
	if not tr then return end
	
	self:SetCuffTime( CurTime() + self.CuffTime )
	self:SetIsCuffing( true )
	self:SetCuffing( tr.Entity )

	sound.Play( self.CuffSound, self.Owner:GetShootPos(), 75, 100, 1 )
end
function SWEP:SecondaryAttack()
end
function SWEP:Reload()
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )

	self.Time = 0
	self.Range = 150
	self.Lock = true
	
end
function SWEP:Holster()
	if CLIENT and IsValid(self.Owner) and self.Owner==LocalPlayer() then
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		
		vm:SetMaterial( "" )
	end
	if IsValid(self.cmdl_RightCuff) then self.cmdl_RightCuff:Remove() end
	if IsValid(self.cmdl_LeftCuff) then self.cmdl_LeftCuff:Remove() end
	
	return true
end
SWEP.OnRemove = SWEP.Holster

//
// Handcuff
function SWEP:DoHandcuff( target )
	if not (target and IsValid(target)) then return end
	if target:IsHandcuffed() then return end
	if not IsValid(self.Owner) then return end
	
	local cuff = target:Give( "localrp_cuff_handcuffed" )
	cuff:SetCuffStrength( self.CuffStrength + (math.Rand(-self.CuffStrengthVariance,self.CuffStrengthVariance)) )
	cuff:SetCuffRegen( self.CuffRegen + (math.Rand(-self.CuffRegenVariance,self.CuffRegenVariance)) )
	
	cuff:SetCuffMaterial( self.CuffMaterial )
	cuff:SetRopeMaterial( self.CuffRope )
	
	cuff:SetKidnapper( self.Owner )
	cuff:SetRopeLength( self.RopeLength )
	
	cuff:SetCanBlind( self.CuffBlindfold )
	cuff:SetCanGag( self.CuffGag )
	
	cuff.CuffType = self:GetClass() or ""
	
	hook.Call( "OnHandcuffed", GAMEMODE, self.Owner, target, cuff )
	
	if not self.CuffReusable then
		if IsValid(self.Owner) then self.Owner:ConCommand( "lastinv" ) end
		self:Remove()
	end
end

//
// Think
function SWEP:Think()
	if SERVER then
		if self:GetIsCuffing() then
			self:SetHoldType("pistol")
			local tr = self:TargetTrace()
			if (not tr) or tr.Entity~=self:GetCuffing() then
				self:SetIsCuffing(false)
				self:SetCuffTime( 0 )
				return
			end
			
			if CurTime()>self:GetCuffTime() then
				self:SetIsCuffing( false )
				self:SetCuffTime( CurTime() + self.CuffRecharge )
				self:DoHandcuff( self:GetCuffing() )
			end
		end
		if !self:GetIsCuffing() then
			self:SetHoldType(self.HoldType)
		end
	end
end

//
// Get Target
function SWEP:TargetTrace()
	if not IsValid(self.Owner) then return end
	
	local tr = util.TraceLine( {start=self.Owner:GetShootPos(), endpos=(self.Owner:GetShootPos() + (self.Owner:GetAimVector()*50)), filter={self, self.Owner}} )
	if IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity~=self.Owner and not tr.Entity:IsHandcuffed() then
		if hook.Run( "CuffsCanHandcuff", self.Owner, tr.Entity )==false then return end
		return tr
	end
end

//
// HUD
local Col = {
	Text = Color(255,255,255),
	
	BoxBackground = Color(0, 80, 65,200), BoxMain = Color(0, 125, 100)
}
local matGrad = Material( "gui/gradient" )
function SWEP:DrawHUD()
	if not self:GetIsCuffing() then
		if self:GetCuffTime()<=CurTime() then return end
		
		local w,h = (ScrW()/2), (ScrH()/2)
		
		draw.RoundedBox( 20, w-100, h+55, 200, 20, Col.BoxBackground)
		
		local CuffingPercent = math.Clamp( ((self:GetCuffTime()-CurTime())/self.CuffRecharge), 0, 1 )
		render.SetScissorRect( w-100, h+55, (w-100)+(CuffingPercent*200), h+75, true )
			draw.RoundedBox( 20, w-100,h+55, 200,20, Col.BoxMain)
		render.SetScissorRect( 0,0,0,0, false )
		
		return
	end
	
	local w,h = (ScrW()/2), (ScrH()/2)
	
	draw.RoundedBox( 20, w-100, h+55, 200, 20, Col.BoxBackground)
	
	local CuffingPercent = math.Clamp( 1-((self:GetCuffTime()-CurTime())/self.CuffTime), 0, 1 )
	
	render.SetScissorRect( w-100, h+55, (w-100)+(CuffingPercent*200), h+75, true )
		draw.RoundedBox( 20, w-100,h+55, 200,20, Col.BoxMain)
	render.SetScissorRect( 0,0,0,0, false )

	draw.SimpleText( "Сковывание", "HandcuffsText", w, h+51, Col.Text, TEXT_ALIGN_CENTER )
end

//
// Rendering
local renderpos = {
	left = {pos=Vector(0,0,0), vel=Vector(0,0,0), gravity=1, ang=Angle(0,30,90)},
	right = {bone = "ValveBiped.Bip01_R_Hand", pos=Vector(3.2,2.1,0.4), ang=Angle(-2,0,80), scale = Vector(0.045,0.045,0.03)},
	rope = {l = Vector(0,0,2.0), r = Vector(2.3,-1.9,2.7)},
}
local CuffMdl = "models/hunter/tubes/tube2x2x1.mdl"
local RopeCol = Color(255,255,255)
function SWEP:ViewModelDrawn( vm )
	if not IsValid(vm) then return end
	
	vm:SetMaterial( "engine/occlusionproxy" )
	
	if not IsValid(self.cmdl_LeftCuff) then
		self.cmdl_LeftCuff = ClientsideModel( CuffMdl, RENDER_GROUP_VIEW_MODEL_OPAQUE )
		self.cmdl_LeftCuff:SetNoDraw( true )
		self.cmdl_LeftCuff:SetParent( vm )
		
		renderpos.left.pos = self.Owner:GetPos()
	end
	if not IsValid(self.cmdl_RightCuff) then
		self.cmdl_RightCuff = ClientsideModel( CuffMdl, RENDER_GROUP_VIEW_MODEL_OPAQUE )
		self.cmdl_RightCuff:SetNoDraw( true )
		self.cmdl_RightCuff:SetParent( vm )
	end
	
	-- local lpos, lang = self:GetBonePos( renderpos.left.bone, vm )
	local rpos, rang = self:GetBonePos( renderpos.right.bone, vm )
	if not (rpos and rang) then return end
	
	// Right
	local fixed_rpos = rpos + (rang:Forward()*renderpos.right.pos.x) + (rang:Right()*renderpos.right.pos.y) + (rang:Up()*renderpos.right.pos.z)
	self.cmdl_RightCuff:SetPos( fixed_rpos )
	local u,r,f = rang:Up(), rang:Right(), rang:Forward() // Prevents moving axes
	rang:RotateAroundAxis( u, renderpos.right.ang.y )
	rang:RotateAroundAxis( r, renderpos.right.ang.p )
	rang:RotateAroundAxis( f, renderpos.right.ang.r )
	self.cmdl_RightCuff:SetAngles( rang )
	
	local matrix = Matrix()
	matrix:Scale( renderpos.right.scale )
	self.cmdl_RightCuff:EnableMatrix( "RenderMultiply", matrix )
	
	self.cmdl_RightCuff:SetMaterial( self.CuffMaterial )
	self.cmdl_RightCuff:DrawModel()
	
	// Left
	if CurTime()>(renderpos.left.NextThink or 0) then
		local dist = renderpos.left.pos:Distance( fixed_rpos )
		if dist>100 then
			renderpos.left.pos = fixed_rpos
			renderpos.left.vel = Vector(0,0,0)
		elseif dist > 10 then
			local target = (fixed_rpos - renderpos.left.pos)*0.3
			renderpos.left.vel.x = math.Approach( renderpos.left.vel.x, target.x, 1 )
			renderpos.left.vel.y = math.Approach( renderpos.left.vel.y, target.y, 1 )
			renderpos.left.vel.z = math.Approach( renderpos.left.vel.z, target.z, 3 )
		end
		
		renderpos.left.vel.x = math.Approach( renderpos.left.vel.x, 0, 0.5 )
		renderpos.left.vel.y = math.Approach( renderpos.left.vel.y, 0, 0.5 )
		renderpos.left.vel.z = math.Approach( renderpos.left.vel.z, 0, 0.5 )
		-- if renderpos.left.vel:Length()>10 then renderpos.left.vel:Mul(0.1) end
		
		local targetZ = ((fixed_rpos.z - 10) - renderpos.left.pos.z) * renderpos.left.gravity
		renderpos.left.vel.z = math.Approach( renderpos.left.vel.z, targetZ, 3 )
		
		renderpos.left.pos:Add( renderpos.left.vel )
		
		-- renderpos.left.NextThink = CurTime()+0.01
	end
	
	self.cmdl_LeftCuff:SetPos( renderpos.left.pos )
	self.cmdl_LeftCuff:SetAngles( renderpos.left.ang )
	
	-- self.cmdl_LeftCuff:SetAngles( rang )
	local matrix = Matrix()
	matrix:Scale( renderpos.right.scale )
	self.cmdl_LeftCuff:EnableMatrix( "RenderMultiply", matrix )
	
	self.cmdl_LeftCuff:SetMaterial( self.CuffMaterial )
	self.cmdl_LeftCuff:DrawModel()
	
	// Rope
	if not self.RopeMat then self.RopeMat = Material(self.CuffRope) end
	
	render.SetMaterial( self.RopeMat )
	render.DrawBeam( renderpos.left.pos + renderpos.rope.l,
		rpos + (rang:Forward()*renderpos.rope.r.x) + (rang:Right()*renderpos.rope.r.y) + (rang:Up()*renderpos.rope.r.z),
		0.7, 0, 5, RopeCol )
end

SWEP.wrender = {
	left = {pos=Vector(0,0,0), vel=Vector(0,0,0), gravity=1, ang=Angle(0,30,90)},
	right = {bone = "ValveBiped.Bip01_R_Hand", pos=Vector(2.95,2.5,-0.2), ang=Angle(30,0,90), scale = Vector(0.044,0.044,0.044)},
	rope = {l = Vector(0,0,2), r = Vector(3,-1.65,1)},
}
function SWEP:DrawWorldModel()
	if not IsValid(self.Owner) then return end
	local wrender = self.wrender
	
	if not IsValid(self.cmdl_LeftCuff) then
		self.cmdl_LeftCuff = ClientsideModel( CuffMdl, RENDER_GROUP_VIEW_MODEL_OPAQUE )
		self.cmdl_LeftCuff:SetNoDraw( true )
	end
	if not IsValid(self.cmdl_RightCuff) then
		self.cmdl_RightCuff = ClientsideModel( CuffMdl, RENDER_GROUP_VIEW_MODEL_OPAQUE )
		self.cmdl_RightCuff:SetNoDraw( true )
	end
	
	local rpos, rang = self:GetBonePos( wrender.right.bone, self.Owner )
	if not (rpos and rang) then return end
	
	// Right
	local fixed_rpos = rpos + (rang:Forward()*wrender.right.pos.x) + (rang:Right()*wrender.right.pos.y) + (rang:Up()*wrender.right.pos.z)
	self.cmdl_RightCuff:SetPos( fixed_rpos )
	local u,r,f = rang:Up(), rang:Right(), rang:Forward() // Prevents moving axes
	rang:RotateAroundAxis( u, wrender.right.ang.y )
	rang:RotateAroundAxis( r, wrender.right.ang.p )
	rang:RotateAroundAxis( f, wrender.right.ang.r )
	self.cmdl_RightCuff:SetAngles( rang )
	
	local matrix = Matrix()
	matrix:Scale( wrender.right.scale )
	self.cmdl_RightCuff:EnableMatrix( "RenderMultiply", matrix )
	
	self.cmdl_RightCuff:SetMaterial( self.CuffMaterial )
	self.cmdl_RightCuff:DrawModel()
	
	// Left
	if CurTime()>(wrender.left.NextThink or 0) then
		local dist = wrender.left.pos:Distance( fixed_rpos )
		if dist>100 then
			wrender.left.pos = fixed_rpos
			wrender.left.vel = Vector(0,0,0)
		elseif dist > 10 then
			local target = (fixed_rpos - wrender.left.pos)*0.3
			wrender.left.vel.x = math.Approach( wrender.left.vel.x, target.x, 1 )
			wrender.left.vel.y = math.Approach( wrender.left.vel.y, target.y, 1 )
			wrender.left.vel.z = math.Approach( wrender.left.vel.z, target.z, 3 )
		end
		
		wrender.left.vel.x = math.Approach( wrender.left.vel.x, 0, 0.5 )
		wrender.left.vel.y = math.Approach( wrender.left.vel.y, 0, 0.5 )
		wrender.left.vel.z = math.Approach( wrender.left.vel.z, 0, 0.5 )
		-- if wrender.left.vel:Length()>10 then wrender.left.vel:Mul(0.1) end
		
		local targetZ = ((fixed_rpos.z - 10) - wrender.left.pos.z) * wrender.left.gravity
		wrender.left.vel.z = math.Approach( wrender.left.vel.z, targetZ, 3 )
		
		wrender.left.pos:Add( wrender.left.vel )
		
		-- wrender.left.NextThink = CurTime()+0
	end
	
	self.cmdl_LeftCuff:SetPos( wrender.left.pos )
	self.cmdl_LeftCuff:SetAngles( wrender.left.ang )
	
	local matrix = Matrix()
	matrix:Scale( wrender.right.scale )
	self.cmdl_LeftCuff:EnableMatrix( "RenderMultiply", matrix )
	
	self.cmdl_LeftCuff:SetMaterial( self.CuffMaterial )
	self.cmdl_LeftCuff:DrawModel()
	
	// Rope
	if not self.RopeMat then self.RopeMat = Material(self.CuffRope) end
	
	render.SetMaterial( self.RopeMat )
	render.DrawBeam( wrender.left.pos + wrender.rope.l,
		rpos + (rang:Forward()*wrender.rope.r.x) + (rang:Right()*wrender.rope.r.y) + (rang:Up()*wrender.rope.r.z),
		0.7, 0, 5, RopeCol )
end

//
// Bones
function SWEP:GetBonePos( bonename, vm )
	local bone = vm:LookupBone( bonename )
	if not bone then return end
	
	local pos,ang = Vector(0,0,0),Angle(0,0,0)
	local matrix = vm:GetBoneMatrix( bone )
	if matrix then
		pos = matrix:GetTranslation()
		ang = matrix:GetAngles()
	end
	
	if self.ViewModelFlip then ang.r = -ang.r end
	
	-- if pos.x==0 and pos.y==0 and pos.z==0 then print( bonename, vm ) end
	return pos, ang
end