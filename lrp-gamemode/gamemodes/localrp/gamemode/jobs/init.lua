AddCSLuaFile('sv_jobs.lua')
include('sv_jobs.lua')

util.AddNetworkString('lrp.menu-clGetModel')
util.AddNetworkString('lrp.menu-svGetModel')
util.AddNetworkString('lrp.menu-clGetSkin')
util.AddNetworkString('lrp.menu-svGetSkin')
-- util.AddNetworkString('lrp-sendData2')

local jobs = lrp_jobs

net.Receive('lrp.menu-clGetModel', function(_, ply)
	local modelNum = net.ReadInt(5)
	local jobID = net.ReadInt(4)
	
	net.Start('lrp.menu-svGetModel')
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end)

net.Receive('lrp.menu-clGetSkin', function(_, ply)
	local modelNum = net.ReadInt(5)
	local jobID = net.ReadInt(4)
	
	net.Start('lrp.menu-svGetSkin')
	net.WriteString(string.format(jobs[jobID].model, modelNum))
	net.Send(ply)
end)