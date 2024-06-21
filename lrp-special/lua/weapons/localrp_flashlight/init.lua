include('shared.lua')
AddCSLuaFile('shared.lua')

function SWEP:Think()
    if !self.Owner:FlashlightIsOn() then
        self:SetHoldType('normal')
    else
        self:SetHoldType('pistol')
    end
end

function SWEP:Holster()
    if self.Owner:FlashlightIsOn() then
        self.Owner:Flashlight(false)
    end

    return true
end

hook.Add( "PlayerSwitchFlashlight", "SwitchFlashlight", function( ply, enabled )
    if !ply:HasWeapon('localrp_flashlight') then
        return false
    end

    ply:AllowFlashlight(true)

    local wep = ply:GetActiveWeapon()

    if enabled and ply:HasWeapon('localrp_flashlight') and wep:GetClass() != 'localrp_flashlight' then
        if !wep.LRPGuns then
            ply:SelectWeapon('localrp_flashlight')
            ply:Flashlight(true)
        end
    end
end)