AddCSLuaFile('sv_jobs.lua')
include('sv_jobs.lua')

local jobs = lrp_jobs -- Кеширование в локальной переменной для ускорения обращения

function GM:CreateTeams()
	for jobID, job in pairs(jobs) do
		team.SetUp(jobID, job.name, job.color)
	end
end

local ply = FindMetaTable("Player")

function ply:GetJob()
	local plyJob = self:Team()
	
	return jobs[plyJob]
end