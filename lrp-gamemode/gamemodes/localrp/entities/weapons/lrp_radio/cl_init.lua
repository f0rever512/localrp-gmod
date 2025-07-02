include('shared.lua')

local lrp = localrp

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Category = 'LocalRP - Gamemode'
SWEP.PrintName = lrp.lang('lrp_gm.radio_name')

SWEP.Author = 'forever512'
SWEP.Contact = 'https://github.com/f0rever512'
SWEP.Instructions = lrp.lang('lrp_gm.radio_instructions')

local radioPos = Vector(1.3, 0.7, 1)
local radioAng = Angle(-140, -15, 100)

local wModel = ClientsideModel(SWEP.WorldModel)
wModel:SetSkin(1)
wModel:SetNoDraw(true)

function SWEP:DrawWorldModel()

    local ply = self:GetOwner()
    local attID = ply:LookupAttachment('anim_attachment_lh')

    if not IsValid(ply) or attID <= 0 then return end

    wModel:SetParent(ply, attID)
    wModel:SetLocalPos(radioPos)
    wModel:SetLocalAngles(radioAng)

    wModel:SetupBones()
    wModel:DrawModel()
    
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	
    local value = GetConVar('cl_lrp_radio'):GetBool() and '0' or '1'
    RunConsoleCommand('cl_lrp_radio', value)

    local radioActive = not GetConVar('cl_lrp_radio'):GetBool()

    local msg = radioActive and lrp.lang('lrp_gm.radio_on') or lrp.lang('lrp_gm.radio_off')
    local notifyType = radioActive and NOTIFY_GENERIC or NOTIFY_ERROR
    
    self:GetOwner():NotifySound(msg, 2, notifyType, '')

    net.Start('lrp-radio.toggleSound')
    net.WriteBool(radioActive)
    net.SendToServer()
end