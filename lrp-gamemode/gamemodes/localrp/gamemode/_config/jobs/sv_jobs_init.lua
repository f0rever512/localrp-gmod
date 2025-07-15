local defaultJobs = {

    [1] = {
        name = 'Гражданин',
        icon = 'icon16/user.png',
        color = Color(255, 255, 255),

        models = {
            'models/humans/modern/male_01_01.mdl',
            'models/humans/modern/male_01_02.mdl',
            'models/humans/modern/male_01_03.mdl',
            'models/humans/modern/male_02_01.mdl',
            'models/humans/modern/male_02_02.mdl',
            'models/humans/modern/male_02_03.mdl',
            'models/humans/modern/male_03_01.mdl',
            'models/humans/modern/male_03_02.mdl',
            'models/humans/modern/male_03_03.mdl',
            'models/humans/modern/male_03_04.mdl',
            'models/humans/modern/male_03_05.mdl',
            'models/humans/modern/male_03_06.mdl',
            'models/humans/modern/male_03_07.mdl',
            'models/humans/modern/male_04_01.mdl',
            'models/humans/modern/male_04_02.mdl',
            'models/humans/modern/male_04_03.mdl',
            'models/humans/modern/male_04_04.mdl',
            'models/humans/modern/male_05_01.mdl',
            'models/humans/modern/male_05_02.mdl',
            'models/humans/modern/male_05_03.mdl',
            'models/humans/modern/male_05_04.mdl',
            'models/humans/modern/male_05_05.mdl',
            'models/humans/modern/male_06_01.mdl',
            'models/humans/modern/male_06_02.mdl',
            'models/humans/modern/male_06_03.mdl',
            'models/humans/modern/male_06_04.mdl',
            'models/humans/modern/male_06_05.mdl',
            'models/humans/modern/male_07_01.mdl',
            'models/humans/modern/male_07_02.mdl',
            'models/humans/modern/male_07_03.mdl',
            'models/humans/modern/male_07_04.mdl',
            'models/humans/modern/male_07_05.mdl',
            'models/humans/modern/male_07_06.mdl',
            'models/humans/modern/male_08_01.mdl',
            'models/humans/modern/male_08_02.mdl',
            'models/humans/modern/male_08_03.mdl',
            'models/humans/modern/male_08_04.mdl',
            'models/humans/modern/male_09_01.mdl',
            'models/humans/modern/male_09_02.mdl',
            'models/humans/modern/male_09_03.mdl',
            'models/humans/modern/male_09_04.mdl',
            -- female
            'models/humans/modern/female_01.mdl',
            'models/humans/modern/female_02.mdl',
            'models/humans/modern/female_03.mdl',
            'models/humans/modern/female_04.mdl',
            'models/humans/modern/female_06.mdl',
            'models/humans/modern/female_07.mdl',
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight'
        },
    },

    [2] = {
        name = 'Медик',
        icon = 'icon16/pill.png',
        color = Color(225, 120, 120),

        models = {
            'models/kerry/plats_medical_01.mdl',
            'models/kerry/plats_medical_02.mdl',
            'models/kerry/plats_medical_03.mdl',
            'models/kerry/plats_medical_04.mdl',
            'models/kerry/plats_medical_05.mdl',
            'models/kerry/plats_medical_06.mdl',
            'models/kerry/plats_medical_07.mdl',
            'models/kerry/plats_medical_08.mdl',
            'models/kerry/plats_medical_09.mdl',
            'models/kerry/plats_medical_10.mdl',
            'models/kerry/plats_medical_11.mdl',
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight'
        },
    },

    [3] = {
        name = 'Полицейский',
        icon = 'icon16/shield.png',
        color = Color(80, 80, 220),

        models = {
            'models/player/policeofficer/male_01.mdl',
            'models/player/policeofficer/male_02.mdl',
            'models/player/policeofficer/male_03.mdl',
            'models/player/policeofficer/male_04.mdl',
            'models/player/policeofficer/male_05.mdl',
            'models/player/policeofficer/male_06.mdl',
            'models/player/policeofficer/male_08.mdl',
            'models/player/policeofficer/male_09.mdl',
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight', 'localrp_glock18', 'lrp_stungun', 'localrp_cuff_police',
            'lrp_battering_ram', 'lrp_nightstick', 'lrp_radio',
        },

        ar = 20,
        gov = true,
    },

    [4] = {
        name = 'Детектив',
        icon = 'icon16/award_star_gold_1.png',
        color = Color(80, 80, 220),

        models = {
            'models/kerry/detective/male_01.mdl',
            'models/kerry/detective/male_02.mdl',
            'models/kerry/detective/male_03.mdl',
            'models/kerry/detective/male_04.mdl',
            'models/kerry/detective/male_05.mdl',
            'models/kerry/detective/male_06.mdl',
            'models/kerry/detective/male_07.mdl',
            'models/kerry/detective/male_08.mdl',
            'models/kerry/detective/male_09.mdl',
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight', 'localrp_fiveseven', 'localrp_air_revolver', 'lrp_stungun',
            'localrp_cuff_police', 'lrp_nightstick', 'lrp_radio',
        },

        ar = 10,
        gov = true,
    },

    [5] = {
        name = 'Спецназовец',
        icon = 'icon16/gun.png',
        color = Color(80, 80, 220),

        models = {
            'models/css_seb_swat/css_seb.mdl',
            'models/css_seb_swat/css_swat.mdl',
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight', 'localrp_m4a1s', 'localrp_usps', 'lrp_stungun', 'lrp_shield',
            'lrp_battering_ram', 'localrp_cuff_police', 'lrp_nightstick', 'lrp_radio',
        },

        ar = 50,
        gov = true,
    },

}

util.AddNetworkString('lrp-jobs.requestData')
util.AddNetworkString('lrp-jobs.sendTable')

lrp_jobs = file.Exists('lrp_classes.txt', 'DATA') and
util.JSONToTable( file.Read('lrp_classes.txt', 'DATA') )
or defaultJobs

function GM:CreateTeams()
    for id, job in pairs(lrp_jobs) do
        team.SetUp(id, job.name, job.color)
    end
end

-- send jobs after InitPostEntity()
net.Receive('lrp-jobs.requestData', function(_, ply)

    net.Start('lrp-jobs.sendTable')
    net.WriteTable(lrp_jobs)
    net.Send(ply)

end)

concommand.Add('lrp_class_reset', function(ply)

    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    lrp_jobs = table.Copy(defaultJobs)
    file.Write('lrp_classes.txt', util.TableToJSON(lrp_jobs, true))

    net.Start('lrp-jobs.sendTable')
    net.WriteTable(lrp_jobs)
    net.Broadcast()

    net.Start('lrp-jobs.updateUI')
    net.WriteTable(lrp_jobs)
    net.Broadcast()

    for _, target in pairs(player.GetAll()) do
        -- if player has a deleted job
        if target:GetNW2Int('JobID') > 6 then
            target:SetNW2Int('JobID', 1)
            target:Spawn()
            
            target:NotifySound('Your class has been deleted', 4, NOTIFY_GENERIC)
        end
    end

end)