lrp_jobs = lrp_jobs or {
	[1] = {
		name = "Гражданин",
		color = Color(255, 255, 255),
		model = "models/humans/modern/male_0%s_01.mdl",
		icon = 'user',
		panicButton = false,
		weapons = {
			'localrp_hands', 'weapon_physgun', 'gmod_tool', 'gmod_camera', 'lrp_medkit', 'localrp_flashlight'
		}
	},
	[2] = {
		name = "Бездомный",
		color = Color(125, 65, 55),
		model = "models/player/Group01/male_0%s.mdl",
		icon = 'user_gray',
		panicButton = false,
		weapons = {
			'localrp_hands', 'weapon_physgun', 'gmod_tool', 'gmod_camera', 'lrp_medkit', 'lrp_bottle'
		}
	},
	[3] = {
		name = 'Офицер полиции',
		color = Color(80, 80, 220),
		model = "models/player/policeofficer/male_0%s.mdl",
		icon = 'medal_gold_1',
		panicButton = true,
		weapons = {
			'localrp_hands', 'weapon_physgun', 'gmod_tool', 'gmod_camera', 'lrp_medkit', 'localrp_flashlight',
			"localrp_glock18", 'lrp_stungun', "localrp_cuff_police", "lrp_battering_ram", "lrp_nightstick"
		},
		ar = 15
	},
	[4] = {
		name = "Детектив",
		color = Color(80, 80, 220),
		model = "models/kerry/detective/male_0%s.mdl",
		icon = 'asterisk_yellow',
		panicButton = true,
		weapons = {
			'localrp_hands', 'weapon_physgun', 'gmod_tool', 'gmod_camera', 'lrp_medkit', 'localrp_flashlight',
			"localrp_fiveseven", "localrp_air_revolver", 'lrp_stungun', "localrp_cuff_police", "lrp_nightstick"
		},
		ar = 10
	},
	[5] = {
		name = 'Оперативник спецназа',
		color = Color(80, 80, 220),
		model = "models/player/plattsburg_swat/swat.mdl",
		icon = 'award_star_gold_1',
		panicButton = true,
		weapons = {
			'localrp_hands', 'weapon_physgun', 'gmod_tool', 'gmod_camera', 'lrp_medkit', 'localrp_flashlight',
			"localrp_m4a1s", "localrp_usps", 'lrp_stungun', "lrp_shield", "lrp_battering_ram", "localrp_cuff_police",
			"localrp_nightstick"
		},
		ar = 50
	},
	[6] = {
		name = 'Медик',
		color = Color(225, 120, 120),
		model = "models/player/Group03m/male_0%s.mdl",
		icon = 'pill',
		panicButton = false,
		weapons = {
			'localrp_hands', 'weapon_physgun', 'gmod_tool', 'gmod_camera', 'lrp_medkit', 'localrp_flashlight'
		}
	},
}