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

cfg.useAnimCooldown = 1
cfg.useAnimWhitelist = {
    func_door = true,
    func_door_rotating = true,
    prop_door_rotating = true,
    func_movelinear = true,
}

cfg.pushForce = 300
cfg.pushCooldown = 3