if SERVER then

	AddCSLuaFile()

else

	ENT.PrintName		= language.GetPhrase('lrp_guns.ammo.small')
	ENT.Category		= 'LocalRP - Ammo'

end

ENT.Type 				= 'anim'
ENT.Base 				= 'ent_ammo_base'
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
