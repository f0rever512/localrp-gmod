ENT.Type 				= "anim"
ENT.Base 				= "ent_ammo_base"
if CLIENT then
    ENT.PrintName = language.GetPhrase('lrp_guns.small')
end

ENT.Spawnable 			= true
ENT.AdminSpawnable		= false
ENT.Category			= "LocalRP - Ammo"

AddCSLuaFile()

ENT.AmmoType 			= "ammo_small"
ENT.AmmoAmount 			= 50
ENT.AmmoModel			= "models/Items/BoxSRounds.mdl"