local util = util
local pairs = pairs
local net = net
local IsValid = IsValid

util.AddNetworkString('lrp-jobs.addJob')
util.AddNetworkString('lrp-jobs.removeJob')
util.AddNetworkString('lrp-jobs.updateUI')

local function updateTeams(table)
    for id, job in pairs(table) do
        team.SetUp(id, job.name, job.color)
    end
end

local function saveData()
    file.Write('lrp_classes.txt', util.TableToJSON(lrp_jobs, true))
end

net.Receive('lrp-jobs.updateUI', function()
    net.Start('lrp-jobs.updateUI')
    net.WriteTable(lrp_jobs)
    net.Broadcast()
end)

net.Receive('lrp-jobs.addJob', function(_, ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end

    local jobID = net.ReadUInt(6)
    local newJob = net.ReadTable()

    lrp_jobs[jobID] = newJob
    saveData()

    updateTeams(lrp_jobs)
end)

net.Receive('lrp-jobs.removeJob', function(_, ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end

    local jobID = net.ReadUInt(6)

    lrp_jobs[jobID] = nil
    saveData()

    for _, target in pairs(player.GetAll()) do
        -- if player has a deleted job
        if target:GetNW2Int('JobID') == jobID then
            target:SetNW2Int('JobID', 1)
            target:Spawn()
            
            target:NotifySound('Your class has been deleted', 4, NOTIFY_GENERIC)
        end
    end

    updateTeams(lrp_jobs)
end)