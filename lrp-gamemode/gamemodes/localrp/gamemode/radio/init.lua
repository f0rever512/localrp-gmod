util.AddNetworkString('lrp-radio.toggle')

local on = 'localrp/radio_on.wav'
local off = 'localrp/radio_off.wav'

net.Receive('lrp-radio.toggle', function(_, ply)
    local isStart = net.ReadBool()
    
    ply:SetNW2Bool('UsingRadio', isStart)
    ply:EmitSound(isStart and on or off, 40, 100)
end)

-- gov job hear only gov job, citizen (not gov) hear only citizen
hook.Add('PlayerCanHearPlayersVoice', 'lrp-radio.canHear', function(listener, talker)

	if ( listener:IsGov() and talker:IsGov() ) or ( not listener:IsGov() and not talker:IsGov() )
    and ( listener:GetRadioActive() and talker:GetRadioActive() and talker:GetNW2Bool('UsingRadio') ) then
        return true, false
    end

end)