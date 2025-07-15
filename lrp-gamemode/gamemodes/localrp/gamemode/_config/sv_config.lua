lrp_cfg = lrp_cfg or {}

local cfg = lrp_cfg

cfg.walkSpeed = 80
cfg.runSpeed = 180

cfg.giveAmmo = {
    ammo_air = 150,
    ammo_large = 120,
    ammo_shot = 40,
    ammo_small = 150,
}

cfg.chatDist = 400

cfg.chatColor = {
    main = Color(255, 255, 255),
    ic = Color(255, 220, 70),
    ooc = Color(70, 160, 255),
}

cfg.useAnimCooldown = 1
cfg.useAnimWhitelist = {
    func_door = true,
    func_door_rotating = true,
    prop_door_rotating = true,
    func_movelinear = true,
}

cfg.pushForce = 300
cfg.pushCooldown = 3

cfg.defaultJob = {
    name = 'New class',
    icon = 'icon16/status_offline.png',
    color = Color(255, 255, 255),
    models = {'models/player/Group01/male_01.mdl'},
    weapons = {''},
    ar = 0,
    gov = false,
}