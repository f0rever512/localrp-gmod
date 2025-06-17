util.AddNetworkString('lrp-jobs.addJob')
util.AddNetworkString('lrp-jobs.removeJob')
util.AddNetworkString('lrp-jobs.updateUI')

local jobs = lrp_jobs

net.Receive('lrp-jobs.updateUI', function()
    net.Start('lrp-jobs.updateUI')
    net.Broadcast()
end)

net.Receive('lrp-jobs.addJob', function()
    local jobID = net.ReadUInt(6)
    local newJob = net.ReadTable()
    PrintTable(newJob)

    jobs[jobID] = {
        name = newJob.name,
        icon = newJob.icon,
        color = newJob.color,
        models = newJob.models,
        weapons = newJob.weapons,
        ar = newJob.ar,
        gov = newJob.gov,
    }

    for jobID, job in pairs(jobs) do
		team.SetUp(jobID, job.name, job.color)
	end
end)

net.Receive('lrp-jobs.removeJob', function()
    local jobID = net.ReadUInt(6)

    jobs[jobID] = nil

    for _, target in pairs(player.GetAll()) do
        if target:GetNW2Int('JobID') == jobID then
            target:SetNW2Int('JobID', 1)
            target:Spawn()
        end
    end

    for jobID, job in pairs(jobs) do
		team.SetUp(jobID, job.name, job.color)
	end
end)