ENT.Type 				= "anim"
ENT.Base 				= "ent_ammo_base"
if CLIENT then
    ENT.PrintName = 'Пневматические'
end

ENT.Spawnable 			= true
ENT.AdminSpawnable		= false
ENT.Category			= "LocalRP - Ammo"

AddCSLuaFile()

ENT.AmmoType 			= "ammo_air"
ENT.AmmoAmount 			= 80
ENT.AmmoModel			= "models/Items/BoxSRounds.mdl"