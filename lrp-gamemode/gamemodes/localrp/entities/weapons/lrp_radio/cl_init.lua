include('shared.lua')

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Category = 'LocalRP - Gamemode'
SWEP.PrintName = 'Walkie Talkie'

SWEP.Author = 'forever512'
SWEP.Contact = 'https://github.com/f0rever512'
SWEP.Instructions = 'ЛКМ - Включить / выключить рацию'

local radioPos = Vector(1.3, 0.7, 1)
local radioAng = Angle(-140, -15, 100)

local wModel = ClientsideModel(SWEP.WorldModel)
wModel:SetSkin(1)
wModel:SetNoDraw(true)

function SWEP:DrawWorldModel()
    local ply = self:GetOwner()

    if IsValid(ply) then
        local attID = ply:LookupAttachment('anim_attachment_lh')
        if not attID then return end

        wModel:SetParent(ply, attID)
        wModel:SetLocalPos(radioPos)
        wModel:SetLocalAngles(radioAng)

        wModel:SetupBones()
        wModel:DrawModel()
    else
        self:DrawModel()
    end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	
    local value = GetConVar('cl_lrp_radio'):GetBool() and '0' or '1'
    RunConsoleCommand('cl_lrp_radio', value)

    local radioActive = not GetConVar('cl_lrp_radio'):GetBool()

    local msg = radioActive and 'Рация включена' or 'Рация выключена'
    local notifyType = radioActive and NOTIFY_GENERIC or NOTIFY_ERROR
    local sound = radioActive and 'npc/combine_soldier/vo/on2.wav' or 'npc/combine_soldier/vo/on1.wav'
    
    notification.AddLegacy(msg, notifyType, 2)
    surface.PlaySound(sound)
end