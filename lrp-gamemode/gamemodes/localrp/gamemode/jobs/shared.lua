AddCSLuaFile('sv_jobs.lua')
include('sv_jobs.lua')

local jobs = lrp_jobs -- Кеширование в локальной переменной для ускорения обращения

local plyMeta = FindMetaTable("Player")

function plyMeta:GetJob()
	local ply = self
	local plyTeam = self:Team()
	return jobs[plyTeam]
end

-- Создаем команды для каждой работы
for jobID, job in pairs(jobs) do
	team.SetUp(jobID, job.name, job.color)
end