if SERVER then AddCSLuaFile() end

ENT.Type 				= 'anim'
ENT.Base 				= 'ent_ammo_base'
ENT.PrintName 			= 'Дробь'

ENT.Category 			= 'LocalRP - Ammo'
ENT.Spawnable 			= true
ENT.AdminOnly 			= false

ENT.AmmoType 			= 'ammo_shotgun'
ENT.AmmoAmount 			= 20
ENT.AmmoModel			= 'models/Items/BoxBuckshot.mdl'

game.AddAmmoType({
	name = ENT.AmmoType,
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE_AND_WHIZ,
})
