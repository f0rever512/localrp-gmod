local util = util
local pairs = pairs
local net = net
local IsValid = IsValid

util.AddNetworkString('lrp-jobs.addJob')
util.AddNetworkString('lrp-jobs.addDefJob')
util.AddNetworkString('lrp-jobs.removeJob')
util.AddNetworkString('lrp-jobs.updateUI')
util.AddNetworkString('lrp-jobs.listView.addJob')
util.AddNetworkString('lrp-jobs.listView.removeJob')

local defJob = {
    name = 'New class',
    icon = 'icon16/status_offline.png',
    color = Color(255, 255, 255),
    models = {'models/player/Group01/male_01.mdl'},
    weapons = {''},
    ar = 0,
    gov = false,
}

local function updateTeams(table)
    for id, job in pairs(table) do
        team.SetUp(id, job.name, job.color)
    end
end

local function saveData()
    file.Write('lrp_classes.txt', util.TableToJSON(lrp_jobs, true))
end

local function updateMainMenu(jobs)
    net.Start('lrp-jobs.updateUI')
    net.WriteTable(jobs)
    net.Broadcast()
end

net.Receive('lrp-jobs.addJob', function(_, ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end

    local jobID = net.ReadUInt(6)
    local newJob = net.ReadTable()

    lrp_jobs[jobID] = newJob
    saveData()

    updateMainMenu(lrp_jobs)
    updateTeams(lrp_jobs)
end)

net.Receive('lrp-jobs.addDefJob', function(_, ply)

    if not IsValid(ply) or not ply:IsSuperAdmin() then return end

    local newID = 1
    while lrp_jobs[newID] do newID = newID + 1 end

    lrp_jobs[newID] = defJob
    saveData()

    net.Start('lrp-jobs.listView.addJob')
    net.WriteUInt(newID, 6)
    net.WriteTable(lrp_jobs[newID])
    net.Broadcast()

    updateMainMenu(lrp_jobs)
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

    net.Start('lrp-jobs.listView.removeJob')
    net.WriteUInt(jobID, 6)
    net.Broadcast()

    updateMainMenu(lrp_jobs)
    updateTeams(lrp_jobs)
    
end)