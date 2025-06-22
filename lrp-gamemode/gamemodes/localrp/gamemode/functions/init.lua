util.AddNetworkString('lrp-gamemode.notify')
util.AddNetworkString('lrp-gamemode.anim')

local defWeps = lrp_cfg.defaultWeapons

local ply = FindMetaTable('Player')

function ply:DropWeaponAnim()
    local wep = self:GetActiveWeapon()

    if not IsValid(self) or not IsValid(wep) then return end

    if IsValid(wep) and defWeps[wep:GetClass()] or self:InVehicle() then
        self:NotifySound(self:InVehicle() and 'В автомобиле нельзя выбросить оружие' or 'Это оружие нельзя выбросить', 3, NOTIFY_ERROR)

        return
    end

    self:PlayAnimation(ACT_GMOD_GESTURE_ITEM_DROP)

    timer.Simple(1, function() self:DropWeapon(wep) end)
end

concommand.Add('lrp_dropweapon', function(ply, cmd, args) ply:DropWeaponAnim() end)

net.Receive('lrp-gamemode.anim', function(_, ply)
    local animID = net.ReadUInt(12)

    timer.Simple(0, function()
        ply:DoAnimationEvent(animID)
    end)
end)

function ply:GetJobTable()
    if self:Team() == 0 or self:Team() > #lrp_jobs then
		return lrp_jobs[1]
	else
		return lrp_jobs[self:Team()]
	end
end

-- enums
NOTIFY_GENERIC	= 0
NOTIFY_ERROR    = 1
NOTIFY_UNDO		= 2
NOTIFY_HINT		= 3
NOTIFY_CLEANUP	= 4