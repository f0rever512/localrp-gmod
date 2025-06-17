local jobs = lrp_jobs
local ply = FindMetaTable('Player')

function ply:NotifySound(text, duration, type, sound)
    if SERVER then
        net.Start('lrp-gamemode.notify')
            net.WriteString(text)
            net.WriteUInt(duration or 2, 4)
            net.WriteUInt(type or NOTIFY_GENERIC, 3)
            net.WriteString(sound or 'buttons/lightswitch2.wav')
        net.Send(self)
    else
        notification.AddLegacy(text, type or NOTIFY_GENERIC, duration or 2)
        surface.PlaySound(sound or 'buttons/lightswitch2.wav')
    end
end

function ply:PlayAnimation(animID)
    if SERVER then
        timer.Simple(0, function()
            self:DoAnimationEvent(animID)
        end)
    else
        net.Start('lrp-gamemode.anim')
        net.WriteUInt(animID, 12)
        net.SendToServer()
    end
end

function ply:GetJob()
	if self:Team() == 0 then
		return jobs[1]
	else
		return jobs[self:Team()]
	end
end