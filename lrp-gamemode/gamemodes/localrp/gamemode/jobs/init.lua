AddCSLuaFile('sv_jobs.lua')
include('sv_jobs.lua')

util.AddNetworkString('lrp.menu-clGetModel')
util.AddNetworkString('lrp.menu-svGetModel')
util.AddNetworkString('lrp.menu-clGetSkin')
util.AddNetworkString('lrp.menu-svGetSkin')
util.AddNetworkString('lrp-sendData2')

local walk = 80
local run = 180

local jobs = lrp_jobs

local ply = FindMetaTable("Player")
function ply:SetJob(jobID)
	if not jobs[jobID] then return end

	self:SetTeam(jobID)
	self:SetHealth(100)
	self:SetArmor(jobs[jobID].ar or 0)
	self:SetMaxHealth(100)
	self:SetWalkSpeed(walk)
	self:SetRunSpeed(run)
	self:SetLadderClimbSpeed(140)
	if not self:IsBot() then
		net.Receive('lrp-sendData2', function(len, ply)
			local playerData = net.ReadTable()
			
			self:SetModel(string.format(jobs[jobID].model, playerData.model))
			self:SetSkin(playerData.skin)
		end)
	else
		self:SetModel(string.format(jobs[jobID].model, 1))
		self:SetSkin(0)
	end
	self:SetPlayerColor(Vector(jobs[jobID].color.r / 255, jobs[jobID].color.g / 255, jobs[jobID].color.b / 255))

	for _, weapon in pairs(jobs[jobID].weapons) do
		self:Give(weapon)
	end
end

net.Receive('lrp.menu-clGetModel', function(len, ply)
	local modelNum = net.ReadInt(5)
	local jobID = net.ReadInt(4)
	
	net.Start('lrp.menu-svGetModel')
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end)

net.Receive('lrp.menu-clGetSkin', function(len, ply)
	local modelNum = net.ReadInt(5)
	local jobID = net.ReadInt(4)
	
	net.Start('lrp.menu-svGetSkin')
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end)