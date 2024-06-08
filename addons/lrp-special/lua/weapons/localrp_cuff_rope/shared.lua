AddCSLuaFile()

SWEP.Base = "localrp_cuff_base"

SWEP.Category = "LocalRP - Special"
SWEP.Author = "my_hat_stinks"
SWEP.Instructions = "Е - Развязать\nК - Тащить за собой\nЛКМ - Завязать рот\nПКМ - Завязвать глаза\nУ + ЛКМ - Прикрепить к поверхности"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.AdminSpawnable = true

SWEP.Slot = 4
SWEP.PrintName = "Верёвка"

SWEP.CuffTime = 1.25
SWEP.CuffSound = Sound( "buttons/lever7.wav" )

SWEP.CuffMaterial = "models/props_pipes/GutterMetal01a"
SWEP.CuffRope = "cable/rope"
SWEP.CuffStrength = 1.5
SWEP.CuffRegen = 0.25
SWEP.RopeLength = 80
SWEP.CuffReusable = false

SWEP.CuffBlindfold = true
SWEP.CuffGag = true

SWEP.CuffStrengthVariance = 0.1 // Randomise strangth
SWEP.CuffRegenVariance = 0.1 // Randomise regen