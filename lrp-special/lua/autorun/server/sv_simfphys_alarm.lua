local function alarm_start(ent)
    if ent:EngineActive() then return end
    if timer.Exists("ALARM_"..ent:EntIndex()) then return end

    ent:EmitSound("alarm.mp3")
    ent.alarm = true

    local index = ent:EntIndex()

    timer.Create("ALARM_"..index, 1, 30, function()
        if !IsValid(ent) then timer.Remove("ALARM_"..index) return end
        if !ent.alarm then timer.Remove("ALARM_"..index) ent:StopSound("alarm.mp3") ent:SetLightsEnabled(false) return end
        ent:SetLightsEnabled(true)

        timer.Simple(.5, function()
            if !IsValid(ent) then return end
            if !ent.alarm then return end
            ent:SetLightsEnabled(false)
        end)
    end)
    timer.Simple(30, function()
        if !IsValid(ent) then return end
        if !ent.alarm then ent:SetLightsEnabled(false) return end
        ent.alarm = false
    end)
end

hook.Add("EntityTakeDamage", "simfphys-alarm", function(ent, dmg)
    if !ent.IsSimfphyscar then return end
    if !dmg:GetAttacker():IsPlayer() then return end

    alarm_start(ent)

    local old = ent.OnRemove
    function ent:OnRemove()
        self:StopSound("alarm.mp3")
        old(self)
    end
end)