local jobs = {}
local cfg = lrp_cfg

local respawnDelay = 10
local nextRespawn = 0

local clr = cfg.colors

local defPlayerData = {
    job = 1,
    model = 1,
    skin = 0,
}

local function loadPlayerData()
    return file.Exists('lrp_player_data.txt', 'DATA') and
    util.JSONToTable( file.Read('lrp_player_data.txt', 'DATA') ) or defPlayerData
end

local playerData = loadPlayerData()

local function createPanel(parent, dock, width, height, margin, paintFunc)
    local panel = vgui.Create('DPanel', parent)
    
    if dock then
        panel:Dock(dock)
    end

    if width then panel:SetWide(width) end
    if height then panel:SetTall(height) end
    if margin then panel:DockMargin(unpack(margin)) end
    if paintFunc then
        panel.Paint = function(self, w, h)
            paintFunc(self, w, h)
        end
    end

    return panel
end

local function createLabel(parent, text, font, color, dock, margin, inset)
    local label = vgui.Create('DLabel', parent)
    label:SetText(text)
    label:SetFont(font)
    label:SetTextColor(color)
    label:Dock(dock)

    if margin then label:DockMargin(unpack(margin)) end
    if inset then label:SetTextInset(unpack(inset)) end
    
    return label
end

local function ease(t, b, c, d)
	t = t / d;
	return -c * t * (t - 2) + b
end

-- local lastCursorPos = { ScrW() * 0.5, ScrH() * 0.5 }

local blurMat = Material('pp/blurscreen')
local corner = 8

local function playerMenu()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if not jobs[playerData.job] then
        playerData.job = 1
        file.Write('lrp_player_data.txt', util.TableToJSON(playerData))
    end

    local blur = vgui.Create('DPanel')
	blur:SetSize(ScrW(), ScrH())
	blur:MakePopup()
	blur:SetVisible(false)
    blur.openTime = 0

    function blur:Paint(w, h)
		local a = ease(self.isClosing and (math.max(self.isClosing - CurTime(), 0) / 0.3) or (1 - math.max(self.openTime + 0.3 - CurTime(), 0) / 0.3), 0, 0.8, 1)
		self.al = a

		local colMod ={
			['$pp_colour_addr'] = 0,
			['$pp_colour_addg'] = 0,
			['$pp_colour_addb'] = 0,
			['$pp_colour_mulr'] = 0,
			['$pp_colour_mulg'] = 0,
			['$pp_colour_mulb'] = 0,
			['$pp_colour_brightness'] = -0.2 * a,
			['$pp_colour_contrast'] = 1 + 0.5 * a,
			['$pp_colour_colour'] = 1 - a,
		}

        DrawColorModify(colMod)

        surface.SetDrawColor(255, 255, 255, 255 * a)
        surface.SetMaterial(blurMat)

        for i = 1, 3 do
            blurMat:SetFloat('$blur', a * i * 2)
            blurMat:Recompute()

            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(-1, -1, w + 2, h + 2)
        end

		draw.NoTexture()
		surface.SetDrawColor(0, 45, 35, a * 200)
		surface.DrawRect(-1, -1, w + 2, h + 2)
	end

    local mainPanel = createPanel(blur, nil, ScrW() * 0.5, ScrH() * 0.8, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, clr.main)
    end)
    mainPanel:SetPos(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.52 - mainPanel:GetTall() / 2)
    
    local top = createPanel(mainPanel, TOP, nil, 40, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
    end)

    local close = vgui.Create('DButton', top)
    close:Dock(RIGHT)
    close:SetText('')
    close:SetWide(top:GetTall())
    
    function close:DoClick()
        blur:Hide()
    end

    function close:Paint(w, h)
        local posX, posY = w / 4, h / 4
        local sizeX, sizeY = w / 2, h / 2
    
        draw.RoundedBox(8, posX, posY + 1, sizeX, sizeY, Color(20, 210, 180))

        draw.SimpleText(utf8.char(0xf00d), 'lrp-mainMenu.iconLarge', sizeX, sizeY,
        Color(0, 0, 0, (self.Hovered or self.Depressed) and 180 or 140), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    createLabel(top, lrp.lang('lrp_gm.main_menu.title'), 'lrp-mainMenu.large-font', color_white, FILL, nil, {12, 0})

    local fill = createPanel(mainPanel, FILL, nil, nil, {6, 0, 6, 6}, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, clr.second)
    end)

    local infoPanel = createPanel(fill, FILL, nil, nil, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
    end)

    local modelPanel = vgui.Create('DModelPanel', infoPanel)
    modelPanel:Dock(RIGHT)
    modelPanel:SetSize(mainPanel:GetWide() * 0.3, 0)
    modelPanel:SetModel(jobs[playerData.job].models[playerData.model])
    modelPanel:SetFOV(24)
    modelPanel:SetCamPos(Vector(60, 0, 60))
    modelPanel.Entity:SetSkin(playerData.skin)
    modelPanel.Angles = angle_zero
    
    function modelPanel:DragMousePress()
        self.PressX, self.PressY = input.GetCursorPos()
        self.Pressed = true
    end

    function modelPanel:DragMouseRelease() self.Pressed = false end

    function modelPanel:LayoutEntity(ent)
        if self.bAnimated then self:RunAnimation() end

        if self.Pressed then
            local mx, my = input.GetCursorPos()
            self.Angles = self.Angles - Angle(0, ( (self.PressX or mx) - mx ) * 0.5, 0)

            self.PressX, self.PressY = mx, my
        end

        ent:SetAngles(self.Angles)
    end

    createLabel(infoPanel, lrp.lang('lrp_gm.main_menu.nickname'), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 12, 0, 0}, {16, 0})
    createLabel(infoPanel, ply:GetName(), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 12, 0, 0}, {32, 0})

    createLabel(infoPanel, lrp.lang('lrp_gm.main_menu.indicators'), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local hpAr = createLabel(infoPanel, lrp.lang('lrp_gm.main_menu.hp_ar', ply:Health(), ply:Armor()), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 12, 0, 0}, {32, 0})

    createLabel(infoPanel, lrp.lang('lrp_gm.main_menu.class'), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local jobComboB = vgui.Create('DComboBox', infoPanel)
    jobComboB:Dock(TOP)
    jobComboB:DockMargin(32, 12, 32, 0)
    jobComboB:SetIcon('icon16/status_offline.png')
    jobComboB:SetSortItems(false)

    local function updateJobs()
        jobComboB:Clear()

        for _, job in SortedPairs(jobs) do
            jobComboB:AddChoice(job.name, nil, false, job.icon)
        end

        jobComboB:SetValue(jobs[playerData.job].name)
    end

    updateJobs()

    createLabel(infoPanel, lrp.lang('lrp_gm.main_menu.model'), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local empty = createPanel(infoPanel, TOP, nil, nil, {32, 12, 32, 0}, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
    end)
    local modelComboB = vgui.Create('DComboBox', empty)
    modelComboB:Dock(FILL)
    modelComboB:DockMargin(0, 0, 16, 0)
    modelComboB:SetIcon('icon16/bricks.png')

    local function updateModels()
        modelComboB:Clear()

        for _, model in pairs(jobs[playerData.job].models) do
            modelComboB:AddChoice(model, nil, false)
        end

        modelComboB:SetValue(jobs[playerData.job].models[playerData.model])
    end

    updateModels()

    createLabel(infoPanel, lrp.lang('lrp_gm.main_menu.skin'), 'lrp-mainMenu.medium-font', color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local skinSlider = vgui.Create('DNumSlider', infoPanel)
    skinSlider:Dock(TOP)
    skinSlider:DockMargin((mainPanel:GetWide() * -0.5) + 64, 12, 0, 0)
    skinSlider:SetMin(0)
    skinSlider:SetMax(modelPanel.Entity:SkinCount() - 1)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(playerData.skin)
    function skinSlider:OnValueChanged(value)
        playerData.skin = math.modf(value)

        modelPanel.Entity:SetSkin(playerData.skin)
    end

    local empty = createPanel(empty, RIGHT, 24, nil, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, clr.defbtn)
    end)

    local upBtn = vgui.Create('DButton', empty)
    upBtn:SetText('')
    upBtn:Dock(TOP)
    upBtn:SetTall(modelComboB:GetTall() * 0.5)
    function upBtn:Paint(w, h)
        local col = Color(255, 255, 255, 50)

        if self.Hovered or self.Depressed or self:IsSelected() then
            col.a = 255
        end
        
        draw.SimpleText(utf8.char(0xf077), 'lrp-mainMenu.icons', w / 2, h / 2 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local downBtn = vgui.Create('DButton', empty)
    downBtn:SetText('')
    downBtn:SetTall(modelComboB:GetTall() * 0.5)
    downBtn:Dock(BOTTOM)
    function downBtn:Paint(w, h)
        local col = Color(255, 255, 255, 50)

        if self.Hovered or self.Depressed or self:IsSelected() then
            col.a = 255
        end
        
        draw.SimpleText(utf8.char(0xf078), 'lrp-mainMenu.icons', w / 2, h / 2 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function selectModel(id)
        local models = jobs[playerData.job].models
        if not models or not models[id] then return end
        
        playerData.model = id

        modelComboB:SetValue(models[id])

        modelPanel:SetModel(models[id] or 'models/player.mdl')
        modelPanel.Entity:SetSkin(playerData.skin)
        timer.Simple(0, function()
            if not IsValid(modelPanel.Entity) then return end

            local skinCount = modelPanel.Entity:SkinCount() or 1

            skinSlider:SetMax(skinCount - 1)

            if playerData.skin > (skinCount - 1) then
                modelPanel.Entity:SetSkin(0)
                skinSlider:SetValue(0)

                playerData.skin = 0
            end
        end)
    end

    function upBtn:DoClick()
        local models = jobs[playerData.job].models
        if not models then return end

        local id = (playerData.model or 1) - 1

        if id < 1 then id = #models end

        selectModel(id)
    end

    function downBtn:DoClick()
        local models = jobs[playerData.job].models
        if not models then return end
        
        local id = (playerData.model or 1) + 1

        if id > #models then id = 1 end

        selectModel(id)
    end


    function modelComboB:OnSelect(index, text, data)
        selectModel(index)
    end

    function jobComboB:OnSelect(index, text, data)
        playerData.job = index

        selectModel(1)
        skinSlider:SetValue(0)

        -- update model list
        modelComboB:Clear()
        modelComboB:SetValue(jobs[playerData.job].models[1])
        for _, model in pairs(jobs[playerData.job].models) do
            modelComboB:AddChoice(model, nil, false, 'icon16/bricks.png')
        end
    end

    local spawnBtn = vgui.Create('DButton', infoPanel)
    spawnBtn:Dock(BOTTOM)
    spawnBtn:DockMargin(16, 0, 16, 16)
    spawnBtn:SetText(lrp.lang('lrp_gm.main_menu.respawn'))
    spawnBtn:SetFont('lrp-mainMenu.large-font')
    spawnBtn:SetTall(40)

    function spawnBtn:DoClick()
        if nextRespawn > CurTime() then return end

        file.Write('lrp_player_data.txt', util.TableToJSON(playerData))

        net.Start('lrp-gamemode.sendData')
        net.WriteTable(playerData)
        net.SendToServer()

        net.Start('lrp-respawn')
        net.SendToServer()

        blur:Hide()

        self.oldText = self:GetText()
        nextRespawn = CurTime() + respawnDelay

        spawnBtn:SetText( lrp.lang('lrp_gm.main_menu.respawn_delay', respawnDelay) )
        timer.Create('lrp-mainMenu.respawnTimer', 1, respawnDelay, function()
            local timeLeft = math.ceil(nextRespawn - CurTime())
            if timeLeft > 0 then
                spawnBtn:SetText( lrp.lang('lrp_gm.main_menu.respawn_delay', timeLeft) )
            else
                spawnBtn:SetText(self.oldText)
                timer.Remove('lrp-mainMenu.respawnTimer')
            end
        end)
    end

    function blur:Think()
		if self:IsVisible() and gui.IsGameUIVisible() then
			self:Hide()
		end
	end

    function blur:Show()
		if self.isClosing then return end

		self.openTime = CurTime()
		self:SetVisible(true)

        hpAr:SetText(lrp.lang('lrp_gm.main_menu.hp_ar', ply:Health(), ply:Armor()))

        -- if lastCursorPos[1] and lastCursorPos[2] then
        --     gui.SetMousePos(lastCursorPos[1], lastCursorPos[2])
        -- end

        mainPanel:MoveTo(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.5 - mainPanel:GetTall() / 2, 0.25, 0)
        mainPanel:SetAlpha(0)
        mainPanel:AlphaTo(255, 0.25, 0)
        modelPanel:Show()
	end

	function blur:Hide()
		if self.isClosing then return end

        -- lastCursorPos[1], lastCursorPos[2] = gui.MousePos()

        CloseDermaMenus()
        mainPanel:AlphaTo(0, 0.25, 0)
        mainPanel:MoveTo(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.52 - mainPanel:GetTall() / 2, 0.25, 0)
        
        timer.Simple(0.2, function()
            modelPanel:Hide()
        end)

		gui.HideGameUI()
        
		self.isClosing = CurTime() + 0.3
		timer.Simple(0.25, function()
            modelPanel.Angles = angle_zero
            
			self.isClosing = nil
			self:SetVisible(false)
		end)
	end

	function blur:Toggle()
        if gui.IsGameUIVisible() then return end
        
		if self:IsVisible() then
			self:Hide()
		else
			self:Show()
		end
	end

    net.Receive('lrp-playerMenu.open', function()
        if IsValid(blur) then
			blur:Toggle()
		end
    end)

    function blur:OnKeyCodeReleased(key)
		if input.LookupKeyBinding(key) == 'gm_showhelp' then
			blur:Hide()
		end
	end

    net.Receive('lrp-jobs.updateUI', function()

        jobs = net.ReadTable()

        if not jobs[playerData.job] then
            playerData.job = 1
            file.Write('lrp_player_data.txt', util.TableToJSON(playerData))
        end

        updateJobs()
        updateModels()
        
    end)

end

function GM:InitPostEntity()
    net.Start('lrp-gamemode.sendData')
    net.WriteTable( loadPlayerData() )
    net.WriteBool(true) -- send data only for initialization
    net.SendToServer()

    net.Start('lrp-jobs.requestData')
    net.SendToServer()
end

hook.Add('lrp-jobs.init', 'lrp-jobs.init.mainMenu', function(tbl)
    jobs = tbl
    playerMenu()
end)

cvars.AddChangeCallback('gmod_language', function()
    playerMenu()
end, 'lrp-playerMenu.lang')