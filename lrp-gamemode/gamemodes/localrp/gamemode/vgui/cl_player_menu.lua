local jobs = lrp_jobs

local nextRespawn = 0

local jobData = 1
local modelData = 1
local skinData = 0

local clr = {
    main = Color(0, 80, 65),
    second = Color(5, 60, 50),
    defbtn = Color(0, 125, 100),
    hovbtn = Color(0, 185, 150)
}

local playerData = {
    job = jobData,
    model = modelData,
    skin = skinData
}

-- net.Receive('lrp-loadData', function()
--     local data = LoadPlayerData()
--     if data then
--         net.Start('lrp-sendData')
--         net.WriteTable(data)
--         net.SendToServer()

--         net.Start('lrp-sendData2')
--         net.WriteTable(data)
--         net.SendToServer()
--     end
-- end)

-- net.Receive('lrp-gamemode.requestData', function()
--     local data = file.Exists('lrp_player_data.txt', 'DATA') and
--         util.JSONToTable( file.Read('lrp_player_data.txt', 'DATA') ) or playerData

--     net.Start('lrp-gamemode.getData')
--     net.WriteTable(data)
--     net.SendToServer()

--     net.Start('lrp-sendData2')
--     net.WriteTable(data)
--     net.SendToServer()
-- end)

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
		surface.SetDrawColor(0, 45, 35, a * 250)
		surface.DrawRect(-1, -1, w + 2, h + 2)
	end

    local mainPanel = createPanel(blur, nil, ScrW() * 0.5, ScrH() * 0.8, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, clr.main)
    end)
    mainPanel:SetPos(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.52 - mainPanel:GetTall() / 2)
    -- mainPanel:MakePopup()
    
    local top = createPanel(mainPanel, TOP, nil, 40, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
    end)

    local close = vgui.Create('DButton', top)
    close:Dock(RIGHT)
    close:SetText('')
    close:SetWide(40)
    
    function close:DoClick()
        blur:Hide()
    end

    function close:Paint(w, h)
        local color = self:IsHovered() and clr.defbtn or clr.main

        surface.SetDrawColor(color)
        surface.SetMaterial(Material('icon16/cross.png'))
        surface.DrawTexturedRect(8, 8, w - 16, h - 16)
    end

    createLabel(top, 'LocalRP Menu - Настройки игрока', 'lrp-playerMenu.large-font', color_white, FILL, nil, {12, 0})

    local fill = createPanel(mainPanel, FILL, nil, nil, {6, 0, 6, 6}, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, clr.second)
    end)

    local infoPanel = createPanel(fill, FILL, nil, nil, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
    end)

    local modelPanel = vgui.Create("DModelPanel", infoPanel)
    modelPanel:Dock(RIGHT)
    modelPanel:SetSize(mainPanel:GetWide() * 0.3, 0)
    modelPanel:SetModel(ply:GetModel())
    modelPanel:SetFOV(24)
    modelPanel:SetCamPos(Vector(60, 0, 60))
    modelPanel.LayoutEntity = function() end
    modelPanel.Entity:SetSkin(ply:GetSkin())

    createLabel(infoPanel, 'Никнейм игрока', "lrp.menu-medium", color_white, TOP, {0, 12, 0, 0}, {16, 0})
    createLabel(infoPanel, ply:GetName(), "lrp.menu-medium", color_white, TOP, {0, 12, 0, 0}, {32, 0})

    createLabel(infoPanel, 'Здоровье / броня игрока', "lrp.menu-medium", color_white, TOP, {0, 36, 0, 0}, {16, 0})
    createLabel(infoPanel, ply:Health() .. ' здоровья / ' .. ply:Armor() .. ' брони', "lrp.menu-medium", color_white, TOP, {0, 12, 0, 0}, {32, 0})

    createLabel(infoPanel, 'Класс игрока', "lrp.menu-medium", color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local jobComboB = vgui.Create("DComboBox", infoPanel)
    jobComboB:Dock(TOP)
    jobComboB:DockMargin(32, 12, mainPanel:GetWide() * 0.3, 0)
    jobComboB:SetValue(team.GetName(ply:Team()))
    jobComboB:SetIcon('icon16/status_offline.png')
    jobComboB:SetSortItems(false)
    for _, job in ipairs(jobs) do
        jobComboB:AddChoice(job.name, nil, false, 'icon16/' .. job.icon .. '.png')
    end

    createLabel(infoPanel, 'Модель игрока', "lrp.menu-medium", color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local modelSlider = vgui.Create("DNumSlider", infoPanel)
    modelSlider:Dock(TOP)
    modelSlider:DockMargin((mainPanel:GetWide() * -0.5) + 64, 12, 0, 0)
    modelSlider:SetMin(1)
    modelSlider:SetMax(9)
    modelSlider:SetDecimals(0)
    modelSlider:SetValue(modelData)
    modelSlider.OnValueChanged = function(self, value)
        modelData = value

        net.Start('lrp.menu-clGetModel')
        net.WriteInt(modelData, 5)
        net.WriteInt(jobData, 4)
        net.SendToServer()

        net.Receive('lrp.menu-svGetModel', function(len, ply)
            local str = net.ReadString()
            modelPanel:SetModel(str)
        end)
    end

    createLabel(infoPanel, 'Скин игрока', "lrp.menu-medium", color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local skinSlider = vgui.Create("DNumSlider", infoPanel)
    skinSlider:Dock(TOP)
    skinSlider:DockMargin((mainPanel:GetWide() * -0.5) + 64, 12, 0, 0)
    skinSlider:SetMin(0)
    skinSlider:SetMax(23)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(ply:GetSkin())
    skinSlider.OnValueChanged = function(self, value)
        modelPanel.Entity:SetSkin(value)
        skinData = value
    end

    jobComboB.OnSelect = function(self, index, value)
        jobData = index

        net.Start('lrp.menu-clGetSkin')
        net.WriteInt(modelData, 5)
        net.WriteInt(jobData, 4)
        net.SendToServer()
        
        net.Receive('lrp.menu-svGetSkin', function(len, ply)
            local str = net.ReadString()
            modelPanel:SetModel(str)
        end)
    end

    local spawnBtn = vgui.Create("DButton", infoPanel)
    spawnBtn:Dock(BOTTOM)
    spawnBtn:DockMargin(16, 0, 16, 16)
    spawnBtn:SetText('Сохранить и возродиться')
    spawnBtn:SetFont('lrp-playerMenu.large-font')
    spawnBtn:SetTall(40)

    function spawnBtn:DoClick()
        local delay = 5
        local timeLeft = nextRespawn - CurTime()
        if timeLeft < 0 then
            local playerData = {
                job = jobData or 1,
                model = math.modf(modelData) or 1,
                skin = math.modf(skinData) or 0,
            }

            local jsonData = util.TableToJSON(playerData)
            file.Write('lrp_player_data.txt', jsonData)

            net.Start('lrp-gamemode.sendData')
            net.WriteTable(playerData)
            net.SendToServer()

            net.Start('lrp-respawn')
            net.SendToServer()

            nextRespawn = CurTime() + delay
            blur:Hide()
        end
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
			self.isClosing = nil
			self:SetVisible(false)
		end)
	end

	function blur:Toggle()
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
end

function GM:InitPostEntity()
    local data = file.Exists('lrp_player_data.txt', 'DATA') and
        util.JSONToTable( file.Read('lrp_player_data.txt', 'DATA') ) or playerData

    net.Start('lrp-gamemode.sendData')
    net.WriteTable(data)
    net.WriteBool(true) -- send data only for initialization
    net.SendToServer()

    timer.Simple(1, function() -- wait for lrp-gamemode.sendData
        playerMenu()
    end)
end