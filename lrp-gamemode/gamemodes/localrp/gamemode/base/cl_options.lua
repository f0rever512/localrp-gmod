hook.Add('AddToolMenuTabs', 'lrp-gamemode.toolMenuTab', function()

    spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')

    spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_lrp_gamemode', 'Gamemode', nil, nil, function(pnl)
        pnl:Help(lrp.lang('lrp_gm.options.label_cl'))

        pnl:KeyBinder(lrp.lang('lrp_gm.options.radio_key'), 'cl_lrp_radio_key')

        pnl:CheckBox(lrp.lang('lrp_gm.options.push_text'), 'lrp_pushtext')
    end)

    spawnmenu.AddToolMenuOption('LocalRP', 'Server Options', 'sv_lrp_gamemode', 'Gamemode', nil, nil, function(pnl)
        pnl:Help(lrp.lang('lrp_gm.options.label_sv'))

        pnl:TextEntry(lrp.lang('lrp_gm.options.respawn_time'), 'lrp_respawntime')
        pnl:CheckBox(lrp.lang('lrp_gm.options.leg_break'), 'lrp_legbreak')
        pnl:CheckBox(lrp.lang('lrp_gm.options.drowning'), 'lrp_drowning')

        pnl:CheckBox(lrp.lang('lrp_gm.options.noclip'), 'sbox_noclip')
    end)

end)