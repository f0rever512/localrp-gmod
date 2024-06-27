ENT.Type 				= "anim"
ENT.Base 				= "ent_ammo_base"
if CLIENT then
    ENT.PrintName = 'Дробь'
end

ENT.Spawnable 			= true
ENT.AdminSpawnable		= false
ENT.Category			= "LocalRP - Ammo"

AddCSLuaFile()

ENT.AmmoType 			= "ammo_shot"
ENT.AmmoAmount 			= 20
ENT.AmmoModel			= "models/Items/BoxBuckshot.mdl"