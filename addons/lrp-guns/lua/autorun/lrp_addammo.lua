local ammotable = {}
ammotable["ammo_air"] = "Пневматические"
ammotable["ammo_pist"] = "Пистолетные"
ammotable["ammo_smg"] = "Патроны для ПП"
ammotable["ammo_assault"] = "Винтовочные"
ammotable["ammo_snip"] = "Снайперские"
ammotable["ammo_shot"] = "Дробь"

for v, k in pairs(ammotable) do
    game.AddAmmoType({
        name = v,
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE_AND_WHIZ
    })
    if CLIENT then
        language.Add( v .. "_ammo", k )
    end
end