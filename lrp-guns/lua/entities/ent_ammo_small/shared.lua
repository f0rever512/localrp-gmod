if SERVER then AddCSLuaFile() end

ENT.Type 				= 'anim'
ENT.Base 				= 'ent_ammo_base'
ENT.PrintName 			= 'Малый калибр'

ENT.Category 			= 'LocalRP - Ammo'
ENT.Spawnable 			= true
ENT.AdminOnly 			= false

ENT.AmmoType 			= 'ammo_small'
ENT.AmmoAmount 			= 50
ENT.AmmoModel			= 'models/Items/BoxSRounds.mdl'

game.AddAmmoType({
	name = ENT.AmmoType,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE_AND_WHIZ,
})
