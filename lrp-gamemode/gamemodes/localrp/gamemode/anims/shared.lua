local nextAnim = 0
local doorClass = {
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true
}

hook.Add("KeyPress", 'doorAnim', function( ply, key )
    if key ~= IN_USE then return end

	local timeLeft = nextAnim - CurTime()
	if timeLeft >= 0 then return end

	local eyetrace = ply:GetEyeTrace()
    if not IsValid(eyetrace.Entity) then return end

	if doorClass[eyetrace.Entity:GetClass()] and ply:GetShootPos():DistToSqr(eyetrace.HitPos) <= 90*90 then
		ply:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM, 228)
		nextAnim = CurTime() + 1
	end
end)

hook.Add("DoAnimationEvent", 'lrp-animations', function(ply , event , data)
	if event ~= PLAYERANIMEVENT_CUSTOM then return end

    animation = nil

	if data == 228 then
		animation = ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND
    elseif data == 229 then
		animation = ACT_GMOD_GESTURE_ITEM_DROP
	end

    ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, animation, true)
    return ACT_INVALID
end)