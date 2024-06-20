local addammo = {
    'ammo_air',
    'ammo_large',
    'ammo_shot',
    'ammo_small',
}

for _, ammo in pairs(addammo) do
    game.AddAmmoType({
        name = ammo,
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE_AND_WHIZ
    })
end