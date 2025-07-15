local lrp = localrp
local defWeapons = lrp_cfg.defaultWeapons

local function createRow(parent, text, height)
    local row = vgui.Create('DPanel', parent)
    row:Dock(TOP)
    row:SetTall(height or 24)
    row:DockMargin(8, 0, 8, 8)
    row.Paint = nil

    local label = vgui.Create('DLabel', row)
    label:SetText(text)
    label:Dock(LEFT)
    label:SetWide(80)
    label:DockMargin(4, 0, 4, 0)
    label:SetContentAlignment(4)

    return row
end

local function updateTeams(table)
    for id, job in pairs(table) do
        team.SetUp(id, job.name, job.color)
    end
end

local jobEditor
local saveBtn
local jobs = {}

local function openJobEditor()
    local ply = LocalPlayer()
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local scale = ScrW() >= 1600 and 1 or 0.7

    if IsValid(jobEditor) then jobEditor:Remove() end

    local frame = vgui.Create('DFrame')
    frame:SetTitle(lrp.lang('lrp_gm.class_editor.title'))
    frame:SetSize(ScrW() * 0.405, ScrH() * 0.7)
    frame:SetSizable(true)
    frame:SetMinWidth(frame:GetWide())
    frame:SetMinHeight(frame:GetTall())
    frame:Center()
    frame:MakePopup()
    jobEditor = frame

    local leftPnl = vgui.Create('DPanel', frame)
    leftPnl:Dock(LEFT)
    leftPnl:SetWide(300 * scale)

    local jobList = vgui.Create('DListView', leftPnl)
    jobList:Dock(FILL)
    jobList:SetMultiSelect(false)
    jobList:AddColumn('ID'):SetWidth(48)
    jobList:AddColumn(lrp.lang('lrp_gm.class_editor.name')):SetWidth(160)
    jobList:AddColumn(lrp.lang('lrp_gm.class_editor.models'))
    jobList:AddColumn(lrp.lang('lrp_gm.class_editor.weapons'))

    local function updateListView()
        jobList:Clear()

        for id, job in SortedPairs(jobs) do
            jobList:AddLine(
                id,
                job.name or lrp.lang('lrp_gm.class_editor.new_class'),
                job.models and #job.models or 0,
                job.weapons and #job.weapons or 0
            )
        end
    end

    updateListView()

    local rightPnl = vgui.Create('DPanel', frame)
    rightPnl:Dock(FILL)
    rightPnl:DockMargin(6, 0, 0, 0)
    rightPnl:DockPadding(0, 8, 0, 0)

    local selectHint = vgui.Create('DLabel', rightPnl)
    selectHint:SetText(lrp.lang('lrp_gm.class_editor.choose'))
    selectHint:SetFont('lrp-mainMenu.medium-font')
    selectHint:Dock(FILL)
    selectHint:SetContentAlignment(5)

    local editPnl = vgui.Create('DScrollPanel', rightPnl)
    editPnl:Dock(FILL)

    local function editJob(jobID)

        selectHint:Remove()
        editPnl:Clear()

        local job = jobs[jobID] or {}

        local nameRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.name') .. ':')
        local nameEntry = vgui.Create('DTextEntry', nameRow)
        nameEntry:Dock(FILL)
        nameEntry:SetText(job.name or lrp.lang('lrp_gm.class_editor.new_class'))

        local iconRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.icon'), 96)
        local setIcon = vgui.Create('DIconBrowser', iconRow)
        setIcon:Dock(FILL)
        setIcon:SelectIcon(job.icon or 'icon16/status_offline.png')

        local colorRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.color'), 128)
        local setColor = vgui.Create('DColorMixer', colorRow)
        setColor:Dock(FILL)
        setColor:SetPalette(true)
        setColor:SetAlphaBar(false)
        setColor:SetColor(job.color or Color(255, 255, 255))

        local mdlRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.models') .. ':', 192)
        local mdlScroll = vgui.Create('DScrollPanel', mdlRow)
        mdlScroll:Dock(FILL)

        local mdlLayout = vgui.Create('DIconLayout', mdlScroll)
        mdlLayout:Dock(FILL)

        local selectedModels = {}
        if job.models then
            for _, mdl in pairs(job.models) do
                selectedModels[mdl] = true
            end
        end

        for name, mdl in SortedPairs( player_manager.AllValidModels() ) do
            local icon = vgui.Create('SpawnIcon', mdlLayout)
            icon:SetModel(mdl)
            icon:SetSize(64, 64)
            icon:SetTooltip(name)

            function icon:PaintOver(w, h)
                if selectedModels[mdl] then
                    surface.SetDrawColor(20, 180, 110)
                    surface.DrawOutlinedRect(0, 0, w-2, h-2, 2)
                end
            end

            function icon:DoClick()
                selectedModels[mdl] = not selectedModels[mdl] and true or nil
            end

            function icon:OpenMenu()
                local menu = DermaMenu()
                
                menu:AddOption('#spawnmenu.menu.copy', function() SetClipboardText(mdl) end):SetIcon('icon16/page_copy.png')
                menu:Open()
            end
        end

        local wepRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.weapons') .. ':', 136)
        local wepScroll = vgui.Create('DScrollPanel', wepRow)
        wepScroll:Dock(FILL)

        local selectedWeapons = {}
        if job.weapons then
            for _, wep in pairs(job.weapons) do
                if wep ~= '' then
                    selectedWeapons[wep] = true
                end
            end
        end

        local wepList = weapons.GetList()
        for _, wep in pairs(wepList) do
            if not wep.Spawnable then continue end
            
            local class = wep.ClassName

            if defWeapons[class] then continue end

            local btn = vgui.Create('DButton', wepScroll)
            btn:Dock(TOP)
            btn:DockMargin(0, 1, 0, 1)
            btn:SetTall(32)
            btn:SetText('')

            local defButton = vgui.GetControlTable('DButton').Paint
            function btn:Paint(w, h)
                if selectedWeapons[class] then
                    draw.RoundedBox(8, 0, 0, w, h, Color(10, 135, 80))
                else
                    defButton(self, w, h)
                end
            end

            local icon = vgui.Create('DImage', btn)
            icon:Dock(LEFT)
            icon:DockMargin(4, 4, 8, 4)
            icon:SetWide(24)
            icon:SetImage(wep.IconOverride or 'entities/' .. class .. '.png', 'icon16/bricks.png')

            local name = vgui.Create('DLabel', btn)
            name:Dock(FILL)
            name:SetText(wep.PrintName or class)
            name:SetFont('lrp.jobEditor.small-font')
            name:SizeToContents()

            function btn:DoClick()
                selectedWeapons[class] = not selectedWeapons[class] and true or nil
            end
        end

        local additionsRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.adds'), 44)

        local ar = vgui.Create('DNumSlider', additionsRow)
        ar:Dock(FILL)
        ar:SetText(lrp.lang('lrp_gm.class_editor.armor'))
        ar:SetMin(0)
        ar:SetMax(100)
        ar:SetDecimals(0)
        ar:SetDefaultValue(0)
        ar:SetValue(job.ar or 0)

        local gov = vgui.Create('DCheckBoxLabel', additionsRow)
        gov:Dock(BOTTOM)
        gov:SetText(lrp.lang('lrp_gm.class_editor.gov'))
        gov:SetChecked(job.gov or false)

        if not IsValid(saveBtn) then
            saveBtn = vgui.Create('DButton', rightPnl)
            saveBtn:SetText(lrp.lang('lrp_gm.shared.save'))
            saveBtn:Dock(BOTTOM)
            saveBtn:DockMargin(8, 8, 8, 8)
            saveBtn:SetTall(32)
            saveBtn:SetIcon('icon16/disk.png')
        end

        local function addJob()

            local name = nameEntry:GetValue()
            local icon = setIcon:GetSelectedIcon()
            local color = setColor:GetColor()
            local jobAR = ar:GetValue()
            local jobGov = gov:GetChecked()

            local jobModels = {}
            for id in pairs(selectedModels) do table.insert(jobModels, id) end

            if #jobModels == 0 then
                jobModels = {'models/player/Group01/male_01.mdl'}
            end
            
            -- remove default model
            if #jobModels > 1 then
                for i=1, #jobModels do
                    if jobModels[i] == 'models/player/Group01/male_01.mdl' then
                        table.remove(jobModels, i)
                    end
                end
            end
            
            local jobWeapons = {}
            for id in pairs(selectedWeapons) do table.insert(jobWeapons, id) end

            -- update on client / to send to server
            jobs[jobID] = {
                name = name,
                icon = icon,
                color = color,
                models = jobModels,
                weapons = jobWeapons,
                ar = math.modf(jobAR),
                gov = jobGov,
            }

            -- update on server
            net.Start('lrp-jobs.addJob')
            net.WriteUInt(jobID, 6)
            net.WriteTable(jobs[jobID])
            net.SendToServer()

            updateTeams(jobs)

        end

        function saveBtn:DoClick()
            addJob()

            updateListView()
            jobList:SelectItem(jobList:GetLine(jobID))
        end
        
    end

    function jobList:OnRowSelected(_, line)
        local id = line:GetColumnText(1)
        editJob(tonumber(id))
    end

    function jobList:OnRowRightClick(_, line)
        local id = tonumber(line:GetColumnText(1))
        if id == 1 then return end
        
        local menu = DermaMenu()
        
        menu:AddOption(lrp.lang('lrp_gm.shared.remove'), function()

            net.Start('lrp-jobs.removeJob')
            net.WriteUInt(id, 6)
            net.SendToServer()

        end):SetIcon('icon16/delete.png')
        
        menu:Open()
    end

    local addBtn = vgui.Create('DButton', leftPnl)
    addBtn:Dock(BOTTOM)
    addBtn:DockMargin(8, 8, 8, 8)
    addBtn:SetText(lrp.lang('lrp_gm.class_editor.add_new_class'))
    addBtn:SetTall(32)
    addBtn:SetIcon('icon16/add.png')
    function addBtn:DoClick()
        net.Start('lrp-jobs.addDefJob')
        net.SendToServer()
    end

    net.Receive('lrp-jobs.listView.addJob', function()

        if not IsValid(jobEditor) then return end

        local jobID = net.ReadUInt(6)
        local newJob = net.ReadTable()

        jobs[jobID] = newJob

        updateListView()
        jobList:SelectItem(jobList:GetLine(jobID))
        updateTeams(jobs)

    end)

    net.Receive('lrp-jobs.listView.removeJob', function()

        if not IsValid(jobEditor) then return end

        local jobID = net.ReadUInt(6)

        jobs[jobID] = nil
        jobList:RemoveLine(jobID)

        jobList:SelectItem(jobList:GetLine(jobID-1))
        updateTeams(jobs)

    end)
end

concommand.Add('lrp_class_editor', openJobEditor)

hook.Add('lrp-jobs.init', 'lrp-jobs.init.editor', function(tbl)
    jobs = tbl
end)