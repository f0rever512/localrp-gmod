hook.Add('AddToolMenuTabs', 'lrp-gamemode.toolMenuTab', function()

    spawnmenu.AddToolTab('LocalRP', 'LocalRP', 'icon16/brick.png')

    spawnmenu.AddToolMenuOption('LocalRP', 'Client Options', 'cl_lrp_gamemode', 'Gamemode', nil, nil, function(pnl)
        pnl:Help(lrp.lang('lrp_gm.options.label_cl'))

        pnl:KeyBinder(lrp.lang('lrp_gm.options.radio_key'), 'cl_lrp_radio_key')

        pnl:CheckBox(lrp.lang('lrp_gm.options.push_text'), 'cl_lrp_push_hint')
    end)

    spawnmenu.AddToolMenuOption('LocalRP', 'Server Options', 'sv_lrp_gamemode', 'Gamemode', nil, nil, function(pnl)
        pnl:Help(lrp.lang('lrp_gm.options.label_sv'))

        pnl:TextEntry(lrp.lang('lrp_gm.options.respawn_time'), 'sv_lrp_respawn_time')
        pnl:CheckBox(lrp.lang('lrp_gm.options.breaking_leg'), 'sv_lrp_breaking_leg')
        pnl:CheckBox(lrp.lang('lrp_gm.options.drowning'), 'sv_lrp_drowning')

        pnl:CheckBox(lrp.lang('lrp_gm.options.noclip'), 'sbox_noclip')

        pnl:Button(lrp.lang('lrp_gm.options.class_editor'), 'lrp_class_editor')
        pnl:Button(lrp.lang('lrp_gm.options.class_reset'), 'lrp_class_reset')
    end)

end)