util.AddNetworkString('breakleg')
util.AddNetworkString('notifydmg')
util.AddNetworkString('bleeding')

hook.Add('Initialize', 'lrp-damage', function()
	local function screenfade(pl, time)
		pl:ScreenFade( SCREENFADE.OUT, color_black, time, 0 )
		timer.Simple( time, function()
			pl:ScreenFade( SCREENFADE.IN, color_black, time, time + 0.15 )
		end)
	end

	timer.Create('drowndamage', 1, 0, function()
        if not GetConVar('lrp_drowning'):GetBool() then return end
		for k, v in pairs ( player.GetAll() ) do
			if not v:IsValid() then return end 
			
			if v:WaterLevel( ) == 3 and v:Alive() then
				if v.drowning == nil or v.drowning == 0 then
					v.drowning = 0
				end
				v.drowning = v.drowning + 1
			else
				v.drowning = nil
			end

			if v.drowning != nil and v.drowning > 5 and v:Alive() then
				if math.random(1,5) == 5 then
					v:EmitSound("player/pl_drown" .. math.random(2,3) .. ".wav", 100, math.random(100,120) )
				end
			end
			
			if v.drowning != nil and v.drowning > 9 and v:Alive() then 
				v:SetHealth( v:Health() - 10 )
				if math.random(1, 2) == 1 then
					screenfade(v, 0.2)
				end
				if v.drowning == 10 then
					v:EmitSound("player/pl_drown1.wav")
				end
				if math.random(1,3) == 3 then
					v:EmitSound("player/pl_drown" .. math.random(1,2) .. ".wav", 100, math.Clamp( v:Health() * 1.2, 70, 100 ) )
				end
				if v:Health() <= 0 then
					v:SetHealth(0)
					v:Kill() 
					v:EmitSound("player/pl_drown3.wav")
				end
			end
		end
	end)

	local function breakLeg(ply, duration)
		if not GetConVar('lrp_legbreak'):GetBool() then return end
		
		net.Start('breakleg')
			net.WriteInt(duration, 5)
		net.Send(ply)
		
		timer.Create('breakLeg_' .. ply:SteamID(), duration, 1, function()
			return
		end)
	end

	local function fall(ply,speed)
		local damage = speed / 7.5
		if (damage > ply:Health() / 2 and damage < ply:Health()) then
			breakLeg(ply, 10)
			screenfade(ply, 0.1)
		end
		return damage
	end

	function damageHands(ply, chance)
		if not ply:IsPlayer() then return false end
		if math.random(100) > chance then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end

        if wep:GetMaxClip1() > -1 or wep:GetMaxClip2() > -1 then
			--ply:DropWeapon(wep)
            ply:SelectWeapon('localrp_hands')
        end
	end

	local hitgroupNames = {
		['HITGROUP_HAND'] = 'рука',
		[HITGROUP_HEAD] = 'голова',
		['HITGROUP_NUTS'] = 'область таза', --'голову'
		[HITGROUP_LEFTLEG] = 'левая нога',
		[HITGROUP_RIGHTLEG] = 'правая нога',
		[HITGROUP_LEFTARM] = 'левая рука',
		[HITGROUP_RIGHTARM] = 'правая рука',
		[HITGROUP_STOMACH] = 'область живота',
		[HITGROUP_CHEST] = 'область груди'
	}

	local function notifyDamage(ply, hitgroup)
		local hitgroupName = hitgroupNames[hitgroup]
		if hitgroupName then
			if math.random(1, 2) == 1 then
				ply:ViewPunch(Angle(math.random(-15, 15), math.random(-15, 15), math.random(-10, 10)))
				screenfade(ply, 0.1)
			end
            net.Start('notifydmg')
				net.WriteString(hitgroupName)
	        net.Send(ply)
		end
	end

	local function Damage(ply, hitgroup, dmginfo)
		local dmgpos = dmginfo:GetDamagePosition()

		local PelvisIndx = ply:LookupBone('ValveBiped.Bip01_Pelvis')
		if (PelvisIndx == nil) then return dmginfo end --Maybe Hitgroup still works, need testing
		local PelvisPos = ply:GetBonePosition( PelvisIndx )
		local NutsDistance = dmgpos:DistToSqr(PelvisPos)

		local LHandIndex = ply:LookupBone('ValveBiped.Bip01_L_Hand')
		local LHandPos = ply:GetBonePosition( LHandIndex )
		local LHandDistance = dmgpos:DistToSqr(LHandPos)

		local RHandIndex = ply:LookupBone('ValveBiped.Bip01_R_Hand')
		local RHandPos = ply:GetBonePosition(RHandIndex)
		local RHandDistance = dmgpos:DistToSqr(RHandPos)

		local LHandIndex = ply:LookupBone('ValveBiped.Bip01_L_Hand')
		local LHandPos = ply:GetBonePosition( LHandIndex )
		local LHandDistance = dmgpos:DistToSqr(LHandPos)

		local RCalfIndex = ply:LookupBone('ValveBiped.Bip01_R_Calf')
		local RCalfPos = ply:GetBonePosition(RCalfIndex)
		local RCalfDistance = dmgpos:DistToSqr(RCalfPos)

		local LCalfIndex = ply:LookupBone('ValveBiped.Bip01_L_Calf')
		local LCalfPos = ply:GetBonePosition(LCalfIndex)
		local LCalfDistance = dmgpos:DistToSqr(LCalfPos)

		local HeadIndex = ply:LookupBone('ValveBiped.Bip01_Head1')
		local HeadPos = ply:GetBonePosition(HeadIndex) + Vector(0,0,3)
		local HeadDistance = dmgpos:DistToSqr(HeadPos)

		if (LHandDistance < 100 || RHandDistance < 100 ) then
			hitgroup = 'HITGROUP_HAND'
		elseif HeadDistance < 80 then
			hitgroup = HITGROUP_HEAD
		elseif (NutsDistance <= 49 && NutsDistance >= 25) then
			hitgroup = 'HITGROUP_NUTS'
		elseif LCalfDistance < 350 then
			hitgroup = HITGROUP_LEFTLEG
		elseif RCalfDistance < 350 then
			hitgroup = HITGROUP_RIGHTLEG
		end

		if (hitgroup == HITGROUP_HEAD) then
			dmginfo:ScaleDamage(5)
		elseif (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) then
			dmginfo:ScaleDamage(1)
			damageHands(ply, 25)
		elseif (hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG) then
			dmginfo:ScaleDamage(0.75)
			if ply:IsPlayer() then breakLeg(ply, 5) end
		elseif (hitgroup == HITGROUP_CHEST) then
			dmginfo:ScaleDamage(3)
		elseif (hitgroup == HITGROUP_STOMACH) then
			dmginfo:ScaleDamage(1)
		elseif (hitgroup == 'HITGROUP_NUTS') then
			dmginfo:ScaleDamage(1.5)
			if ply:IsPlayer() then breakLeg(ply, 5) end
		elseif (hitgroup == 'HITGROUP_HAND') then
			dmginfo:ScaleDamage(0.45)
			damageHands(ply, 50)
		end

		notifyDamage(ply, hitgroup)
	end

	hook.Add('ScalePlayerDamage', 'EnhancedPlayerDamage', Damage)
	hook.Add('GetFallDamage', 'EnhancedFallDamage', fall)

	local bleeding = {}
	local allowHolster = {
		weapon_physgun = true,
		gmod_tool = true,
		gmod_camera = true,
		localrp_hands = true
	}

	timer.Create('lrp-dying', 1, 0, function()
		for k = #bleeding, 1, -1 do
			local sid = bleeding[k]
			local ply = player.GetBySteamID(sid)

			if not IsValid(ply) then
				timer.Remove('lrp-dying' .. sid)
				table.remove(bleeding, k)
			elseif ply:Health() > 10 or not ply:Alive() then
				net.Start('bleeding')
					net.WriteBool(false)
				net.Send(ply)
				ply.bleeding = nil
				timer.Remove('lrp-dying' .. sid)
				table.remove(bleeding, k)
			end
		end
	end)

	local function dying(ply, dmgInfo)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if ply.bleeding then return end
		local left = ply:Health() - dmgInfo:GetDamage()
		if left <= 0 then return end
		if left <= 10 then
			local w = ply:GetActiveWeapon()
			if IsValid(w) and ply:HasWeapon(w:GetClass()) and not allowHolster[w:GetClass()] then
				ply:DropWeapon(w)
			end

            ply:ChatPrint('Вы истекаете кровью. Если вам не помогут, вы умрете')
			ply.bleeding = true
			bleeding[#bleeding + 1] = ply:SteamID()
			net.Start('bleeding')
				net.WriteBool(true)
			net.Send(ply)

			timer.Create('lrp-dying' .. ply:SteamID(), 18, 0, function()
				-- 	ply:EmitSound(Sound('vo/npc/female01/moan0' .. math.random(1,5) .. '.wav'))
				ply:EmitSound(Sound('vo/npc/male01/moan0' .. math.random(1,5) .. '.wav'))

				if ply:Health() <= 1 then
					local dmg = DamageInfo()
					dmg:SetDamage(1)
					dmg:SetDamageType(dmg:GetDamageType())
					dmg:SetAttacker(game.GetWorld())
					dmg:SetInflictor(game.GetWorld())
					ply:TakeDamageInfo(dmg)
				else
					ply:SetHealth(ply:Health() - 1)
				end
			end)
		end
	end
	local function cant(ply)
		if ply.bleeding then return false end
	end

	hook.Add('EntityTakeDamage', 'lrp-dying', dying)
	hook.Add('CanPlayerEnterVehicle', 'lrp-dying', cant)
end)

CreateConVar('lrp_legbreak', 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Enable/disable breaking leg')
CreateConVar('lrp_drowning', 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, 'Enable/disable drowning')