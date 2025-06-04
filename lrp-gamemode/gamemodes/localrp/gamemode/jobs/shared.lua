local jobs = lrp_jobs -- Кеширование в локальной переменной для ускорения обращения

function GM:CreateTeams()
	for jobID, job in pairs(jobs) do
		team.SetUp(jobID, job.name, job.color)
	end
end

local ply = FindMetaTable('Player')

function ply:GetJob()
	if self:Team() == 0 then
		return jobs[1]
	else
		return jobs[self:Team()]
	end
end