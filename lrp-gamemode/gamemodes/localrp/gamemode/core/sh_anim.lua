local nextAnim = 0

hook.Add("KeyPress", 'doorAnim', function( ply, key )
	local doorClass = {
		"func_door",
		"prop_door_rotating",
		"func_movelinear"
	}
	local eyetrace = ply:GetEyeTrace()

	local timeLeft = nextAnim - CurTime()
	if timeLeft < 0 then
		if key == IN_USE then
			if IsValid(eyetrace.Entity) and table.HasValue(doorClass, eyetrace.Entity:GetClass()) and ply:GetShootPos():Distance(eyetrace.HitPos) <= 90 then
				ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, 228)
				nextAnim = CurTime() + 1
			end
		end
	end
end)

hook.Add("DoAnimationEvent", 'lrp-animations', function(ply , event , data)
	if event == PLAYERANIMEVENT_CUSTOM then
		if data == 228 then
			ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND, true)
			return ACT_INVALID
		end
		if data == 229 then
			ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_ITEM_DROP, true)
			return ACT_INVALID
		end
	end
end)