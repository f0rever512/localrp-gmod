util.AddNetworkString('lrp-radio.toggle')

local on = 'localrp/radio_on.wav'
local off = 'localrp/radio_off.wav'

net.Receive('lrp-radio.toggle', function(_, ply)
    local isStart = net.ReadBool()
    
    ply:SetNW2Bool('UsingRadio', isStart)
    ply:EmitSound(isStart and on or off, 40, 100)
end)

hook.Add('PlayerCanHearPlayersVoice', 'lrp-gamemode.voiceDist', function(listener, talker)
    local listenIsGov = listener:GetJobTable().gov
    local talkIsGov = talker:GetJobTable().gov

    if listener:GetInfoNum('cl_lrp_radio', 0) == 1 and talker:GetNW2Bool('UsingRadio') and listenIsGov and talkIsGov then
        return true, false
    end

    return listener:GetPos():DistToSqr(talker:GetPos()) <= 160000 and talker:Alive(), true
end)

hook.Add('PlayerCanSeePlayersChat', 'lrp-gamemode.chatDist', function(text, teamOnly, listener, talker)
    return listener:GetPos():DistToSqr(talker:GetPos()) <= 160000 and talker:Alive()
end)