local blurMaterial = Material('pp/blurscreen')
local blurAmount = 0.8

local function LRPBlur()
    if blurAmount > 0 then
        local tab = {
            ['$pp_colour_addr'] = 0,
            ['$pp_colour_addg'] = 0,
            ['$pp_colour_addb'] = 0,
            ['$pp_colour_mulr'] = 0,
            ['$pp_colour_mulg'] = 0,
            ['$pp_colour_mulb'] = 0,
            ['$pp_colour_brightness'] = -blurAmount * 0.2,
            ['$pp_colour_contrast'] = 1 + 0.5 * blurAmount,
            ['$pp_colour_colour'] = 1 - blurAmount,
        }

        DrawColorModify(tab)
        surface.SetDrawColor(255, 255, 255, blurAmount * 255)
        surface.SetMaterial(blurMaterial)
        
        for i = 1, 3 do 
            blurMaterial:SetFloat('$blur', blurAmount * i * 2)
            blurMaterial:Recompute() 
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(-1, -1, ScrW() + 2, ScrH() + 2)
        end
        
        draw.NoTexture()
        surface.SetDrawColor(0, 45, 35, blurAmount * 250)
        surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
    end
end

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

local function SavePlayerData(data)
    local jsonData = util.TableToJSON(data)
    file.Write('lrp_player_data.txt', jsonData)
end

local function LoadPlayerData()
    if not file.Exists('lrp_player_data.txt', "DATA") then
        return playerData
    end

    local jsonData = file.Read('lrp_player_data.txt', "DATA")
    return util.JSONToTable(jsonData)
end

net.Receive('lrp-loadData', function()
    local data = LoadPlayerData()
    if data then
        net.Start('lrp-sendData')
        net.WriteTable(data)
        net.SendToServer()

        net.Start('lrp-sendData2')
        net.WriteTable(data)
        net.SendToServer()
    end
end)

local function createPanel(parent, dock, width, height, margin, paintFunc)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(dock)
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
    local label = vgui.Create("DLabel", parent)
    label:SetText(text)
    label:SetFont(font)
    label:SetTextColor(color)
    label:Dock(dock)
    if margin then label:DockMargin(unpack(margin)) end
    if inset then label:SetTextInset(unpack(inset)) end
    return label
end

local function LRPMenuMain()
    local ply = LocalPlayer()
    local scrw, scrh = ScrW(), ScrH()
    local corner = 8
    hook.Add('RenderScreenspaceEffects', 'lrp.menu-blur', LRPBlur)

    local mainPanel = createPanel(nil, nil, scrw * 0.5, scrh * 0.8, nil, function(self, w, h)
        draw.RoundedBox(corner, 0, 0, w, h, clr.main)
    end)
    mainPanel:SetPos(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.52 - mainPanel:GetTall() / 2)
    mainPanel:MoveTo(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.5 - mainPanel:GetTall() / 2, 0.25, 0)
    mainPanel:SetAlpha(0)
    mainPanel:AlphaTo(255, 0.25, 0)
    mainPanel:MakePopup()
    
    function mainPanel:OnKeyCodeReleased(key)
        if input.LookupKeyBinding(key) == 'gm_showhelp' then
            self:AlphaTo(0, 0.25, 0)
            self:MoveTo(ScrW() * 0.5 - self:GetWide() / 2, ScrH() * 0.52 - self:GetTall() / 2, 0.25, 0)
            timer.Simple(0.25, function()
                self:SetVisible(false)
                hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
            end)
        end
    end

    function mainPanel:Think()
        if self:IsVisible() and gui.IsGameUIVisible() then
            self:SetVisible(false)
            hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
        end
    end

    local top = createPanel(mainPanel, TOP, nil, 40, nil, function(self, w, h)
        draw.RoundedBoxEx(corner, 0, 0, w, h, clr.main, true, true, false, false)
    end)

    local close = vgui.Create("DButton", top)
    close:Dock(RIGHT)
    close:SetText("")
    close:SetWide(40)
    close.DoClick = function()
        mainPanel:AlphaTo(0, 0.25, 0)
        mainPanel:MoveTo(ScrW() * 0.5 - mainPanel:GetWide() / 2, ScrH() * 0.52 - mainPanel:GetTall() / 2, 0.25, 0)
        timer.Simple(0.25, function()
            mainPanel:SetVisible(false)
            hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
        end)
    end
    close.Paint = function(self, w, h)
        local color = self:IsHovered() and clr.defbtn or clr.main
        surface.SetDrawColor(color)
        surface.SetMaterial(Material('icon16/cross.png'))
        surface.DrawTexturedRect(8, 8, w - 16, h - 16)
    end

    createLabel(top, 'LocalRP Menu - Настройки игрока', "lrp.menu-large", color_white, FILL, nil, {12, 0})

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

    createLabel(infoPanel, 'Профессия игрока', "lrp.menu-medium", color_white, TOP, {0, 36, 0, 0}, {16, 0})
    local jobComboB = vgui.Create("DComboBox", infoPanel)
    jobComboB:Dock(TOP)
    jobComboB:DockMargin(32, 12, mainPanel:GetWide() * 0.3, 0)
    jobComboB:SetValue(team.GetName(ply:Team()))
    jobComboB:SetIcon('icon16/status_offline.png')
    jobComboB:AddChoice("Гражданин", nil, false, 'icon16/user.png')
    jobComboB:AddChoice("Бездомный", nil, false, 'icon16/user_gray.png')
    jobComboB:AddChoice('Офицер полиции', nil, false, 'icon16/medal_gold_1.png')
    jobComboB:AddChoice("Детектив", nil, false, 'icon16/asterisk_yellow.png')
    `:AddChoice('Оперативник спецназа', nil, false, 'icon16/award_star_gold_1.png')
    jobComboB:AddChoice('Медик', nil, false, 'icon16/pill.png')

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
    spawnBtn:SetFont('lrp.menu-large')
    spawnBtn:SetTall(40)
    spawnBtn.DoClick = function()
        local delay = 5
        local timeLeft = nextRespawn - CurTime()
        if timeLeft < 0 then
            local playerData = {
                job = jobData or 1,
                model = math.modf(modelData) or 1,
                skin = math.modf(skinData) or 0,
            }
            SavePlayerData(playerData)
            
            net.Start('lrp-loadData')
            net.SendToServer()

            net.Start('lrp-respawn')
            net.SendToServer()
            nextRespawn = CurTime() + delay
        end
    end
end

net.Receive('lrp.menu-main', function()
    LRPMenuMain()
end)
