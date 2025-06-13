local jobs = lrp_jobs

local function createRow(parent, text, height)
    local row = vgui.Create('DPanel', parent)
    row:Dock(TOP)
    row:SetTall(height or 24)
    row:DockMargin(8, 8, 8, 0)
    row.Paint = nil

    local label = vgui.Create('DLabel', row)
    label:SetText(text)
    label:Dock(LEFT)
    label:SetWide(96)
    label:DockMargin(4, 0, 4, 0)
    label:SetContentAlignment(4)

    return row
end

local function createLabel(parent, text, dock, margin, inset)
    local label = vgui.Create('DLabel', parent)
    label:SetText(text)
    label:Dock(dock)

    if margin then label:DockMargin(unpack(margin)) end
    if inset then label:SetTextInset(unpack(inset)) end
    
    return label
end

local jobEditor
local saveBtn

local function openJobEditor()
    local ply = LocalPlayer()
    if not ply:IsSuperAdmin() then return end

    local scale = ScrW() >= 1600 and 1 or 0.7

    if IsValid(jobEditor) then jobEditor:Remove() end

    local frame = vgui.Create('DFrame')
    frame:SetTitle('Редактор классов')
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.5)
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
    jobList:AddColumn('Название'):SetWidth(160)
    jobList:AddColumn('Модели')
    jobList:AddColumn('Оружие')

    local function updateJobs()
        jobList:Clear()

        for id, job in SortedPairs(jobs) do
            jobList:AddLine(
                id,
                job.name or '',
                job.models and #job.models or 0,
                job.weapons and #job.weapons or 0
            )
        end
    end

    updateJobs()

    local rightPnl = vgui.Create('DPanel', frame)
    rightPnl:Dock(FILL)
    rightPnl:DockMargin(6, 0, 0, 0)

    local selectJob = vgui.Create('DLabel', rightPnl)
    selectJob:SetText('<– Выберите класс')
    selectJob:SetFont('lrp-mainMenu.medium-font')
    selectJob:Dock(FILL)
    selectJob:SetContentAlignment(5)

    local editPnl = vgui.Create('DScrollPanel', rightPnl)
    editPnl:Dock(FILL)

    local function editJob(jobId)
        selectJob:Remove()
        editPnl:Clear()

        local job = jobs[jobId] or {}

        local nameRow = createRow(editPnl, 'Название:')
        local nameEntry = vgui.Create('DTextEntry', nameRow)
        nameEntry:Dock(FILL)
        nameEntry:SetText(job.name or '')

        local iconRow = createRow(editPnl, 'Иконка:', 96)
        local setIcon = vgui.Create('DIconBrowser', iconRow)
        setIcon:Dock(FILL)
        setIcon:SelectIcon(job.icon or 'icon16/status_offline.png')

        local colorRow = createRow(editPnl, 'Цвет:', 128)
        local setColor = vgui.Create('DColorMixer', colorRow)
        setColor:Dock(FILL)
        setColor:SetPalette(true)
        setColor:SetAlphaBar(false)
        setColor:SetWangs(true)
        setColor:SetColor(job.color or Color(255, 255, 255))

        local modelRow = createRow(editPnl, 'Модели:', 72)
        local mdlEntry = vgui.Create('DTextEntry', modelRow)
        mdlEntry:Dock(FILL)
        mdlEntry:SetMultiline(true)
        mdlEntry:SetText(job.models and table.concat(job.models, '\n') or '')

        local wepRow = createRow(editPnl, 'Оружие:', 72)
        local wepEntry = vgui.Create('DTextEntry', wepRow)
        wepEntry:Dock(FILL)
        wepEntry:SetMultiline(true)
        wepEntry:SetText(job.weapons and table.concat(job.weapons, '\n') or '')

        if not IsValid(saveBtn) then
            saveBtn = vgui.Create('DButton', rightPnl)
            saveBtn:SetText('Сохранить')
            saveBtn:Dock(BOTTOM)
            saveBtn:DockMargin(8, 8, 8, 8)
            saveBtn:SetTall(32)
            saveBtn:SetIcon('icon16/disk.png')
        end

        function saveBtn:DoClick()
            local name = nameEntry:GetValue()
            local icon = setIcon:GetSelectedIcon()
            local color = setColor:GetColor()
            local modelsStr = mdlEntry:GetValue()
            local weaponsStr = wepEntry:GetValue()

            jobs[jobId] = {
                name = name,
                icon = icon,
                color = color,
                models = string.Explode('\n', modelsStr),
                weapons = string.Explode('\n', weaponsStr),
            }
            updateJobs()
        end
    end
    
    function jobList:OnRowSelected(_, line)
        local id = line:GetColumnText(1)
        editJob(tonumber(id))
    end

    function jobList:OnRowRightClick(lineID, line)
        local id = line:GetColumnText(1)
        local menu = DermaMenu()

        menu:AddOption('Удалить', function()
            jobs[tonumber(id)] = nil
            self:RemoveLine(lineID)
        end):SetIcon('icon16/delete.png')
        
        menu:Open()
    end

    local addBtn = vgui.Create('DButton', leftPnl)
    addBtn:Dock(BOTTOM)
    addBtn:DockMargin(8, 8, 8, 8)
    addBtn:SetText('Добавить новый класс')
    addBtn:SetTall(32)
    addBtn:SetIcon('icon16/add.png')
    function addBtn:DoClick()
        local newID = 1
        while jobs[newID] do newID = newID + 1 end

        jobs[newID] = {
            name = 'Новый класс',
            icon = 'icon16/status_offline.png',
            color = Color(255, 255, 255),
            models = {},
            weapons = {},
        }

        updateJobs()

        jobList:SelectItem(jobList:GetLine(newID))
    end
end

concommand.Add('lrp_class_editor', openJobEditor)