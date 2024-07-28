util.AddNetworkString('lrp.menu-clGetModel') -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua
util.AddNetworkString('lrp.menu-svGetModel') -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua
util.AddNetworkString('lrp.menu-clGetSkin') -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua
util.AddNetworkString('lrp.menu-svGetSkin') -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua
util.AddNetworkString('lrp-sendData2') -- В будущем будем инициализировать где-то в другом месте, например: sv(sh)_nets.lua

lrp_jobs = lrp_jobs or {}
local jobs = lrp_jobs -- Кеширование в локальной переменной для ускорения обращения

local walkSpeed, runSpeed = 80, 180

local plyMeta = FindMetaTable("Player")

function plyMeta:SetJob(jobID)
	local job = jobs[jobID]
	if not job then return end

	self:SetTeam(jobID)
	self:SetHealth(100)
	self:SetArmor(job.ar or 0)
	self:SetMaxHealth(100)
	self:SetWalkSpeed(walkSpeed)
	self:SetRunSpeed(runSpeed)
	self:SetLadderClimbSpeed(140)

	net.Receive('lrp-sendData2', function(_, ply)
		local playerData = net.ReadTable()
		self:SetModel(string.format(job.model, playerData.model))
		self:SetSkin(playerData.skin)
	end)

	self:SetPlayerColor(Vector(job.color.r / 255, job.color.g / 255, job.color.b / 255))

	for _, weapon in ipairs(job.weapons) do
		self:Give(weapon)
	end
end

local function handleModelRequest(len, ply, responseNetString)
	local modelNum, jobID = net.ReadInt(5), net.ReadInt(4)
	net.Start(responseNetString)
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end

net.Receive('lrp.menu-clGetModel', function(len, ply)
	handleModelRequest(len, ply, 'lrp.menu-svGetModel')
end)

net.Receive('lrp.menu-clGetSkin', function(len, ply)
	handleModelRequest(len, ply, 'lrp.menu-svGetSkin')
end)
