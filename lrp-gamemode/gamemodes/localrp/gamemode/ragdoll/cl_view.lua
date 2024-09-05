hook.Add("CalcView", 'lrp-ragdoll.view', function(ply, pos, angles, fov)
	if ply:GetRagdoll() then
		local rag = ply:GetNW2Entity('playerRagdollEntity')
		local bid = rag:LookupBone("ValveBiped.Bip01_Head1")
		if bid then
			local pos, ang = rag:GetBonePosition(bid)
			local pos = pos + ang:Forward() * 3 + ang:Right() * 3			
			rag:ManipulateBoneScale(bid, Vector(1, 1, 1))
			ang:RotateAroundAxis(ang:Up(), -90)
			ang:RotateAroundAxis(ang:Forward(), -90)

			local view = {
				origin = pos,
				angles = ang,
				drawviewer = true,
			}
			return view
		end
	end
end)