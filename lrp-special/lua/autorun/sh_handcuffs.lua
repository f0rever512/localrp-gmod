AddCSLuaFile()

//
// Config
local ProtectedJobs = {
	"TEAM_ADMIN", "TEAM_MOD", "TEAM_MODERATOR",
}

// 
// Utility
local function GetTrace( ply )
	local tr = util.TraceLine( {start=ply:EyePos(), endpos=ply:EyePos()+(ply:GetAimVector()*50), filter=ply} )
	if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
		local cuffed,wep = tr.Entity:IsHandcuffed()
		if cuffed then return tr,wep end
	end
end

//
// PLAYER extensions
local PLAYER = FindMetaTable( "Player" )
function PLAYER:IsHandcuffed()
	local wep = self:GetActiveWeapon()
	if IsValid(wep) and wep.IsHandcuffs then
		return true,wep
	end
	
	return false
end

//
// Override Movement
hook.Add( "SetupMove", "Cuffs Move Penalty", function(ply, mv, cmd)
	local cuffed, cuffs = ply:IsHandcuffed()
	if not (cuffed and IsValid(cuffs)) then return end
	
	mv:SetMaxClientSpeed( mv:GetMaxClientSpeed()*0.6 )
	
	if cuffs:GetRopeLength()<=0 then return end // No forced movement
	if not IsValid(cuffs:GetKidnapper()) then return end // Nowhere to move to
	
	local kidnapper = cuffs:GetKidnapper()
	if kidnapper==ply then return end
	
	local TargetPoint = (kidnapper:IsPlayer() and kidnapper:GetShootPos()) or kidnapper:GetPos()
	local MoveDir = (TargetPoint - ply:GetPos()):GetNormal()
	local ShootPos = ply:GetShootPos() + (Vector(0,0, (ply:Crouching() and 0)))
	local Distance = cuffs:GetRopeLength()
	
	local distFromTarget = ShootPos:Distance( TargetPoint )
	if distFromTarget<=(Distance+5) then return end
	if ply:InVehicle() then
		if SERVER and (distFromTarget>(Distance*3)) then
			ply:ExitVehicle()
		end
		
		return
	end
	
	local TargetPos = TargetPoint - (MoveDir*Distance)
	
	local xDif = math.abs(ShootPos[1] - TargetPos[1])
	local yDif = math.abs(ShootPos[2] - TargetPos[2])
	local zDif = math.abs(ShootPos[3] - TargetPos[3])
	
	local speedMult = 3+ ( (xDif + yDif)*0.5)^1.01
	local vertMult = math.max((math.Max(300-(xDif + yDif), -10)*0.08)^1.01  + (zDif/2),0)
	
	if kidnapper:GetGroundEntity()==ply then vertMult = -vertMult end
	
	local TargetVel = (TargetPos - ShootPos):GetNormal() * 10
	TargetVel[1] = TargetVel[1]*speedMult
	TargetVel[2] = TargetVel[2]*speedMult
	TargetVel[3] = TargetVel[3]*vertMult
	local dir = mv:GetVelocity()
	
	local clamp = 50
	local vclamp = 20
	local accel = 200
	local vaccel = 30*(vertMult/50)
	
	dir[1] = (dir[1]>TargetVel[1]-clamp or dir[1]<TargetVel[1]+clamp) and math.Approach(dir[1], TargetVel[1], accel) or dir[1]
	dir[2] = (dir[2]>TargetVel[2]-clamp or dir[2]<TargetVel[2]+clamp) and math.Approach(dir[2], TargetVel[2], accel) or dir[2]
	
	if ShootPos[3]<TargetPos[3] then
		dir[3] = (dir[3]>TargetVel[3]-vclamp or dir[3]<TargetVel[3]+vclamp) and math.Approach(dir[3], TargetVel[3], vaccel) or dir[3]
		
		if vertMult>0 then ply.Cuff_ForceJump=ply end
	end
	
	mv:SetVelocity( dir )
	
	if SERVER and mv:GetVelocity():Length()>=(mv:GetMaxClientSpeed()*10) and ply:IsOnGround() and CurTime()>(ply.Cuff_NextDragDamage or 0) then
		ply:SetHealth( ply:Health()-1 )
		if ply:Health()<=0 then ply:Kill() end
		
		ply.Cuff_NextDragDamage = CurTime()+0.1
	end
end)

//
// Vehicles
hook.Add( "CanPlayerEnterVehicle", "Cuffs PreventVehicle", function( ply )
	-- if ply:IsHandcuffed() then return false end
end)

//
// Internal Cuffs hooks
hook.Add( "CuffsCanHandcuff", "Cuff ProtectAdmin", function( ply, target )
	if IsValid(target) and target:IsPlayer() and ProtectedJobs then
		for i=1,#ProtectedJobs do
			if ProtectedJobs[i] and _G[ ProtectedJobs[i] ] and target:Team()==_G[ ProtectedJobs[i] ] then return false end
		end
	end
end)

if CLIENT then
	//
	// HUD
	local Col = {
		Text = Color(255,255,255), TextShadow=Color(0,0,0), Rope = Color(255,255,255),
		
		BoxBackground = Color(0, 80, 65,200), BoxMain = Color(0, 125, 100)
	}
	local matGrad = Material( "gui/gradient" )
	hook.Add( "HUDPaint", "Cuffs CuffedInteractPrompt", function()
		if LocalPlayer():IsHandcuffed() then return end
		
		local tr,cuff = GetTrace( LocalPlayer() )
		if not (tr and IsValid(cuff)) then return end
		
		local w,h = (ScrW()/2), (ScrH()/2)
		
		local TextPos = h+55
		
		draw.RoundedBox( 20, w-100, TextPos, 200, 20, Col.BoxBackground)
		
		render.SetScissorRect( w-100, TextPos, (w-100)+((cuff:GetCuffBroken()/100)*200), TextPos+20, true )
			draw.RoundedBox( 20, w-100,TextPos, 200,20, Col.BoxMain)
		render.SetScissorRect( 0,0,0,0, false )

		draw.SimpleText( "Игрок связан", "HandcuffsText", w, h+51, Col.Text, TEXT_ALIGN_CENTER )
		--[[TextPos = TextPos-25
		
		if IsValid(cuff:GetFriendBreaking()) then
			if cuff:GetFriendBreaking()==LocalPlayer() then
				draw.SimpleText( "Развязывание...", "HandcuffsText", w, TextPos, Col.Text, TEXT_ALIGN_CENTER )
				TextPos = TextPos-20
			end
		else
			local str = string.format( "%s - Развязать", (input.LookupBinding("+use") or "[USE]"):upper() )
			draw.SimpleText( str, "HandcuffsText", w, TextPos, Col.Text, TEXT_ALIGN_CENTER )
			TextPos = TextPos-20
		end
		
		if cuff:GetRopeLength()>0 then
			if IsValid(cuff:GetKidnapper()) then
				if cuff:GetKidnapper()==LocalPlayer() then
					local str = string.format( "%s - Перестать вести", (input.LookupBinding("+reload") or "[Reload]"):upper() )
					draw.SimpleText( str, "HandcuffsText", w+1, TextPos+1, Col.TextShadow, TEXT_ALIGN_CENTER )
					draw.SimpleText( str, "HandcuffsText", w, TextPos, Col.Text, TEXT_ALIGN_CENTER )
					TextPos = TextPos-20
				end
			else
				local str = string.format( "%s - Вести", (input.LookupBinding("+reload") or "[Reload]"):upper() )
				draw.SimpleText( str, "HandcuffsText", w, TextPos, Col.Text, TEXT_ALIGN_CENTER )
				TextPos = TextPos-20
			end
		end
		
		if cuff:GetCanBlind() then
			local str = string.format( "%s - %sкрыть глаза", (input.LookupBinding("+attack2") or "[PRIMARY FIRE]"):upper(), cuff:GetIsBlind() and "от" or "за" )
			draw.SimpleText( str, "HandcuffsText", w+1, TextPos+1, Col.TextShadow, TEXT_ALIGN_CENTER )
			draw.SimpleText( str, "HandcuffsText", w, TextPos, Col.Text, TEXT_ALIGN_CENTER )
			TextPos = TextPos-20
		end
		
		if cuff:GetCanGag() then
			local str = string.format( "%s - %sвязать рот", (input.LookupBinding("+attack") or "[PRIMARY FIRE]"):upper(), cuff:GetIsGagged() and "раз" or "за" )
			draw.SimpleText( str, "HandcuffsText", w+1, TextPos+1, Col.TextShadow, TEXT_ALIGN_CENTER )
			draw.SimpleText( str, "HandcuffsText", w, TextPos, Col.Text, TEXT_ALIGN_CENTER )
			TextPos = TextPos-20
		end]]
	end)
	
	//
	// Bind hooks
	hook.Add( "PlayerBindPress", "Cuffs CuffedInteract", function(ply, bind, pressed)
		if ply~=LocalPlayer() then return end
		
		if bind:lower()=="+attack" and pressed then
			if ply:KeyDown( IN_USE ) then
				local isDragging = false
				for _,c in pairs(ents.FindByClass("weapon_handcuffed")) do
					if c.GetRopeLength and c.GetKidnapper and c:GetRopeLength()>0 and c:GetKidnapper()==ply then
						isDragging=true
						break
					end
				end
				if isDragging then
					net.Start("Cuffs_TiePlayers") net.SendToServer()
					return true
				end
			end
			local tr,cuffs = GetTrace( ply )
			if tr and cuffs:GetCanGag() then
				net.Start( "Cuffs_GagPlayer" )
					net.WriteEntity( tr.Entity )
					net.WriteBit( not cuffs:GetIsGagged() )
				net.SendToServer()
				return true
			end
		elseif bind:lower()=="+attack2" and pressed then
			local tr,cuffs = GetTrace( ply )
			if tr and cuffs:GetCanBlind() then
				net.Start( "Cuffs_BlindPlayer" )
					net.WriteEntity( tr.Entity )
					net.WriteBit( not cuffs:GetIsBlind() )
				net.SendToServer()
				return true
			end
		elseif bind:lower()=="+reload" and pressed then
			local tr,cuffs = GetTrace( ply )
			if tr and cuffs:GetRopeLength()>0 then
				net.Start( "Cuffs_DragPlayer" )
					net.WriteEntity( tr.Entity )
					net.WriteBit( LocalPlayer()~=cuffs:GetKidnapper() )
				net.SendToServer()
				return true
			end
		elseif bind:lower()=="+use" and pressed then
			local tr,cuffs = GetTrace( ply )
			if tr then
				net.Start( "Cuffs_FreePlayer" )
					net.WriteEntity( tr.Entity )
				net.SendToServer()
				return true
			else
				local tr = util.TraceLine( {start=ply:EyePos(), endpos=ply:EyePos()+(ply:GetAimVector()*50), filter=ply} )
				if IsValid(tr.Entity) and tr.Entity:GetNWBool("Cuffs_TieHook") then
					net.Start("Cuffs_UntiePlayers") net.SendToServer()
				end
			end
		end
	end)
	
	//
	// Render
	local DragBone = "ValveBiped.Bip01_R_Hand"
	local DefaultRope = Material("cable/rope")
	hook.Add( "PostDrawOpaqueRenderables", "Cuffs DragRope", function()
		local allCuffs = ents.FindByClass( "weapon_handcuffed" )
		for i=1,#allCuffs do
			local cuff = allCuffs[i]
			if not (IsValid(cuff) and IsValid(cuff.Owner) and cuff.GetRopeLength and cuff:GetRopeLength()>0 and cuff.GetKidnapper and IsValid(cuff:GetKidnapper())) then continue end
			
			local kidnapper = cuff:GetKidnapper()
			--local kidPos = (kidnapper:IsPlayer() and kidnapper:GetPos() + Vector(0,0,37)) or kidnapper:GetPos()
			
			local pos = cuff.Owner:GetPos()
			local bone = cuff.Owner:LookupBone( DragBone )
			if bone then
				pos = cuff.Owner:GetBonePosition( bone )
				kidPos = kidnapper:GetBonePosition( bone ) or kidnapper:GetPos()
				if (pos.x==0 and pos.y==0 and pos.z==0) then pos = cuff.Owner:GetPos() end
			end
			
			if not cuff.RopeMat then cuff.RopeMat = DefaultRope end
			render.SetMaterial( cuff.RopeMat )
			render.DrawBeam( kidPos, pos, 0.7, 0, 5, Col.Rope )
			render.DrawBeam( pos, kidPos, -0.7, 0, 5, Col.Rope )
		end
	end)
	
	local HeadBone = "ValveBiped.Bip01_Head1"
	local RenderPos = {
		Blind = {Vector(3.5,4,2.6), Vector(3.8,5.8,0), Vector(3.5,4,-2.8), Vector(2.4,-1,-3.8), Vector(1.5,-3.5,0), Vector(2.4,-1,3.8)},
		Gag = {Vector(1.0,5.2,2), Vector(1.0,7.5,-0.1), Vector(1.0,4.5,-3), Vector(0,0,-2.4), Vector(-0.8,-3,0), Vector(0,0,3.4)},
	}
	hook.Add( "PostPlayerDraw", "Cuffs DrawGag", function( ply )
		if not IsValid(ply) then return end
		
		local cuffed, cuff = ply:IsHandcuffed()
		if not (cuffed and IsValid(cuff)) then return end
		
		render.SetMaterial( DefaultRope )
		if cuff:GetIsBlind() then
			local pos,ang
			local bone = cuff.Owner:LookupBone( HeadBone )
			if bone then
				pos, ang = cuff.Owner:GetBonePosition( bone )
			end
			if pos and ang then
				local firstpos = pos + (ang:Forward()*RenderPos.Blind[1].x) + (ang:Right()*RenderPos.Blind[1].y) + (ang:Up()*RenderPos.Blind[1].z)
				local lastpos = firstpos
				for i=2,#RenderPos.Blind do
					local newPos = pos + (ang:Forward()*RenderPos.Blind[i].x) + (ang:Right()*RenderPos.Blind[i].y) + (ang:Up()*RenderPos.Blind[i].z)
					render.DrawBeam( newPos, lastpos, 1.5, 0, 1, Col.Rope )
					lastpos = newPos
				end
				render.DrawBeam( lastpos, firstpos, 1.5, 0, 1, Col.Rope )
			end
		end
		if cuff:GetIsGagged() then
			local pos,ang
			local bone = cuff.Owner:LookupBone( HeadBone )
			if bone then
				pos, ang = cuff.Owner:GetBonePosition( bone )
			end
			if pos and ang then
				local firstpos = pos + (ang:Forward()*RenderPos.Gag[1].x) + (ang:Right()*RenderPos.Gag[1].y) + (ang:Up()*RenderPos.Gag[1].z)
				local lastpos = firstpos
				for i=2,#RenderPos.Gag do
					local newPos = pos + (ang:Forward()*RenderPos.Gag[i].x) + (ang:Right()*RenderPos.Gag[i].y) + (ang:Up()*RenderPos.Gag[i].z)
					render.DrawBeam( newPos, lastpos, 1.5, 0, 1, Col.Rope )
					lastpos = newPos
				end
				render.DrawBeam( lastpos, firstpos, 1.5, 0, 1, Col.Rope )
			end
		end
	end)
end