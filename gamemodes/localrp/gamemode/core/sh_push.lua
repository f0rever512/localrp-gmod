if CLIENT then
	CreateClientConVar('lrp_pushtext', '1', true, true)

	hook.Add("PostDrawTranslucentRenderables", 'lrp-push.Text', function()
		local blacklist = {
			'weapon_physgun',
			'gmod_tool',
			'gmod_camera'
		}
	
		if GetConVarNumber('lrp_pushtext') == 0 then return end
		if GetConVarNumber("lrp_view") == 0 then return end
		if hook.Run('dbg-view.chShouldDraw') then return end

		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()

		if !ply:Alive() then return end

		if !wep.DrawCrosshair then return end

		if IsValid(ply) and IsValid(wep) then
			if table.HasValue(blacklist, wep:GetClass()) then return end
		end

		local pos = ply:GetShootPos()
		local aim = ply:EyeAngles():Forward()

		if !ply:InVehicle() then
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
			
			if ply and ply:IsValid() and ent and ent:IsValid() then
				if ply:IsPlayer() and ent:IsPlayer() then
					if ply:GetPos():Distance( ent:GetPos() ) <= 100 then
						if ent:Alive() and ent:GetMoveType() == MOVETYPE_WALK then
							cam.Start3D2D(Pos, Ang, math.pow(tr.Fraction, 0.9) * 0.08)
							cam.IgnoreZ(true)
								draw.SimpleTextOutlined( "E - Толкнуть", 'postdraw-font', 0, 60, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 200) )
							cam.IgnoreZ(false)
							cam.End3D2D()
						end
					end
				end
			end
		end
	end)
end

hook.Add( "KeyPress", 'lrp-push', function( ply, key )
	if key == IN_USE and not ply.push then
		local ent = ply:GetEyeTrace().Entity
		if ply and ply:IsValid() and ent and ent:IsValid() then
			if ply:IsPlayer() and ent:IsPlayer() then
				if ply:GetPos():Distance( ent:GetPos() ) <= 100 then
					if ent:Alive() and ent:GetMoveType() == MOVETYPE_WALK then
						ply:DoCustomAnimEvent( PLAYERANIMEVENT_CUSTOM , 228 )
						if SERVER then
							ply:EmitSound( "physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 100, 100 )
						end
						ent:SetVelocity(ply:EyeAngles():Forward() * 400)
						ent:ViewPunch(Angle(math.random(-15, 15), math.random(-15, 15), 0))
						ply.push = true
						timer.Simple(3, function() ply.push = false end)
					end	
				end
			end
		end
	end
end)