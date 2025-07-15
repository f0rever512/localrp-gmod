SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = ''
SWEP.WorldModel = 'models/handfield_radio.mdl'
SWEP.UseHands = true

SWEP.Slot = 5
SWEP.SlotPos = 1

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

function SWEP:Initialize()
	self:SetHoldType('normal')
end

function SWEP:Think() end

function SWEP:SecondaryAttack() end

function SWEP:Reload() end