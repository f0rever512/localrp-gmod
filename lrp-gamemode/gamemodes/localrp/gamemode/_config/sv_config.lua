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

cfg.dropBlacklist = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true,
    localrp_hands = true,
}