ENT.Type 				= "anim"
ENT.Base 				= "ent_ammo_base"
if CLIENT then
    ENT.PrintName = 'Крупный калибр'
end

ENT.Spawnable 			= true
ENT.AdminSpawnable		= false
ENT.Category			= "LocalRP - Ammo"

AddCSLuaFile()

ENT.AmmoType 			= "ammo_large"
ENT.AmmoAmount 			= 60
ENT.AmmoModel			= "models/Items/BoxMRounds.mdl"