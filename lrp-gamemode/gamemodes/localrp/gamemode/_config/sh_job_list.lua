lrp_jobs = lrp_jobs or {

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
        name = 'Бездомный',
        icon = 'icon16/user_gray.png',
        color = Color(125, 65, 55),

        models = {
            'models/player/Group01/male_01.mdl',
            'models/player/Group01/male_02.mdl',
            'models/player/Group01/male_03.mdl',
            'models/player/Group01/male_04.mdl',
            'models/player/Group01/male_05.mdl',
            'models/player/Group01/male_06.mdl',
            'models/player/Group01/male_07.mdl',
            'models/player/Group01/male_08.mdl',
            'models/player/Group01/male_09.mdl',
        },

        weapons = {
            'lrp_medkit', 'lrp_bottle'
        },
    },
    
    [3] = {
        name = 'Офицер полиции',
        icon = 'icon16/medal_gold_1.png',
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

        ar = 15,
        gov = true,
        panicButton = true,
    },

    [4] = {
        name = 'Детектив',
        icon = 'icon16/asterisk_yellow.png',
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
        panicButton = true,
    },

    [5] = {
        name = 'Оперативник спецназа',
        icon = 'icon16/award_star_gold_1.png',
        color = Color(80, 80, 220),

        models = {
            'models/player/plattsburg_swat/swat.mdl'
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight', 'localrp_m4a1s', 'localrp_usps', 'lrp_stungun', 'lrp_shield',
            'lrp_battering_ram', 'localrp_cuff_police', 'localrp_nightstick', 'lrp_radio',
        },

        ar = 50,
        gov = true,
        panicButton = true,
    },

    [6] = {
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
        },

        weapons = {
            'lrp_medkit', 'localrp_flashlight'
        },
    },

}