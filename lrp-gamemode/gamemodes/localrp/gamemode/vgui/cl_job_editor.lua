local lrp = lrp

local function createRow(parent, text, height)
    local row = vgui.Create('DPanel', parent)
    row:Dock(TOP)
    row:SetTall(height or 24)
    row:DockMargin(8, 0, 8, 8)
    row.Paint = nil

    local label = vgui.Create('DLabel', row)
    label:SetText(text)
    label:Dock(LEFT)
    label:SetWide(96)
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
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.525)
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

        net.Start('lrp-jobs.updateUI')
        net.SendToServer()
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

        local modelRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.models') .. ':', 72)
        local mdlEntry = vgui.Create('DTextEntry', modelRow)
        mdlEntry:Dock(FILL)
        mdlEntry:SetMultiline(true)
        mdlEntry:SetText(job.models and table.concat(job.models, '\n') or '')

        local wepRow = createRow(editPnl, lrp.lang('lrp_gm.class_editor.weapons') .. ':', 72)
        local wepEntry = vgui.Create('DTextEntry', wepRow)
        wepEntry:Dock(FILL)
        wepEntry:SetMultiline(true)
        wepEntry:SetText(job.weapons and table.concat(job.weapons, '\n') or '')

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
            local mdlStr = mdlEntry:GetValue() == '' and 'models/player/Group01/male_01.mdl' or mdlEntry:GetValue()
            local wepStr = wepEntry:GetValue()

            local jobAR = ar:GetValue()
            local jobGov = gov:GetChecked()

            -- update on client / to send to server
            jobs[jobID] = {
                name = name,
                icon = icon,
                color = color,
                models = string.Explode('\n', mdlStr),
                weapons = string.Explode('\n', wepStr),
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

        addJob()
        
    end

    function jobList:OnRowSelected(_, line)
        local id = line:GetColumnText(1)
        editJob(tonumber(id))
    end

    function jobList:OnRowRightClick(lineID, line)
        local id = tonumber(line:GetColumnText(1))
        if id == 1 then return end
        
        local menu = DermaMenu()
        
        menu:AddOption(lrp.lang('lrp_gm.shared.remove'), function()

            self:RemoveLine(lineID)
            jobs[id] = nil

            net.Start('lrp-jobs.removeJob')
            net.WriteUInt(id, 6)
            net.SendToServer()

            net.Start('lrp-jobs.updateUI')
            net.SendToServer()

            updateTeams(jobs)

            jobList:SelectItem(jobList:GetLine(lineID-1))

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
        local newID = 1
        while jobs[newID] do newID = newID + 1 end

        jobs[newID] = {}

        updateListView()
        jobList:SelectItem(jobList:GetLine(newID))
    end
end

concommand.Add('lrp_class_editor', openJobEditor)

hook.Add('lrp-jobs.init', 'lrp-jobs.init.editor', function(tbl)
    jobs = tbl
end)