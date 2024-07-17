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

local clr = {}
clr.main = Color(0, 80, 65)
clr.second = Color(5, 60, 50)
clr.defbtn = Color(0, 125, 100)
clr.hovbtn = Color(0, 185, 150)

local playerData = {
    job = jobData,
    model = modelData,
    skin = skinData,
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
    local data = util.JSONToTable(jsonData)
    
    return data
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

local function LRPMenuMain()
    local ply = LocalPlayer()
    local scrw, scrh = ScrW(), ScrH()
    local corner = 8
    hook.Add('RenderScreenspaceEffects', 'lrp.menu-blur', LRPBlur)

	local mainPanel = vgui.Create("DPanel")
	mainPanel:SetSize(scrw * .5, scrh * .8)
    mainPanel:SetPos(ScrW() * .5 - mainPanel:GetWide() / 2, ScrH() * .52 - mainPanel:GetTall() / 2)
	mainPanel:MoveTo(ScrW() * .5 - mainPanel:GetWide() / 2, ScrH() * .5 - mainPanel:GetTall() / 2, 0.25, 0)
    mainPanel:SetAlpha(0)
    mainPanel:AlphaTo(255, 0.25, 0)
	mainPanel:MakePopup()
	mainPanel.Paint = function(self, w, h)
		draw.RoundedBox(corner, 0, 0, w, h, clr.main)
	end
    function mainPanel:OnKeyCodeReleased(key)
		if input.LookupKeyBinding(key) == 'gm_showhelp' then
			self:AlphaTo(0, 0.25, 0)
            self:MoveTo(ScrW() * .5 - self:GetWide() / 2, ScrH() * .52 - self:GetTall() / 2, 0.25, 0)
            if IsValid(self) then
                timer.Simple( 0.25, function()
                    self:SetVisible(false)
                    hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
                end)
            end
		end
	end
    function mainPanel:Think()
		if self:IsVisible() and gui.IsGameUIVisible() then
			self:SetVisible(false)
            hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
		end
	end

    local top = vgui.Create( 'DPanel', mainPanel )
    top:Dock(TOP)
    top:SetTall(40)
    function top:Paint( w, h )
        draw.RoundedBoxEx(corner, 0, 0, w, h, clr.main, true, true, false, false)
    end

    --navig
    -- local navig = vgui.Create( "DPanel", mainPanel )
    -- navig:Dock(LEFT)
    -- navig:SetWide(200)
    -- navig:DockMargin(6, 0, 0, 6)
    -- function navig:Paint( w, h )
    --     draw.RoundedBox(corner, 0, 0, w, h, clr.second)
    -- end
	
	local close = vgui.Create("DButton", top)
	close:Dock(RIGHT)
	close:SetText("")
    close:SetWide(40)
	close.DoClick = function()
        mainPanel:AlphaTo(0, 0.25, 0)
		mainPanel:MoveTo(ScrW() * .5 - mainPanel:GetWide() / 2, ScrH() * .52 - mainPanel:GetTall() / 2, 0.25, 0)
		if IsValid(mainPanel) then
			timer.Simple( 0.25, function()
				mainPanel:SetVisible(false)
                hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
			end)
		end
	end
	close.Paint = function(self, w, h)
        if self:IsHovered() then
            surface.SetDrawColor(clr.defbtn)
            surface.SetMaterial(Material('icon16/cross.png'))
            surface.DrawTexturedRect(8, 8, w - 16, h - 16)
        else
            surface.SetDrawColor(clr.main)
            surface.SetMaterial(Material('icon16/cross.png'))
            surface.DrawTexturedRect(8, 8, w - 16, h - 16)
        end
	end

    local title = vgui.Create( "DLabel", top )
    title:Dock(FILL)
    title:SetText('LocalRP Menu - Настройки игрока')
    title:SetFont("lrp.menu-large")
    title:SetTextColor(Color( 255, 255, 255))
    title:SetTextInset(12, 0)

    local fill = vgui.Create( 'DPanel', mainPanel )
    fill:Dock(FILL)
    fill:DockMargin(6, 0, 6, 6)
    function fill:Paint( w, h )
        draw.RoundedBox(corner, 0, 0, w, h, clr.second)
    end

    -- local sheet = vgui.Create( "DColumnSheet", fill )
    -- sheet:Dock( FILL )

    -- local function navigbtn(name, name2, text, icon)
    --     local name = vgui.Create( 'DButton', navig )
    --     name:SetText("")
    --     name:SetIcon(icon)
    --     name:SetTall(32)
    --     name:Dock(TOP)
    --     name:DockMargin(6, 12, 6, 0)
    --     name.DoClick = function()
    --         -- fill:SetVisible(visible)
    --         -- print('Выбрана ' .. text)
    --         -- visible = not visible
    --     end
    --     function name:Paint( w, h )
    --         if self:IsHovered() then
    --             draw.RoundedBox(corner, 0, 0, w, h, clr.defbtn)
    --         else
    --             draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
    --         end
    --     end

    --     local name2 = vgui.Create( "DLabel", name )
    --     name2:Dock(LEFT)
    --     name2:SetText(text)
    --     name2:SetFont("lrp.menu-medium")
    --     name2:SetTextColor(Color( 255, 255, 255))
    --     name2:SetTextInset(40, 0)
    --     name2:SizeToContents()
    -- end

    -- navigbtn(btn1, txt1,'Игрок', "icon16/user.png")
    -- navigbtn(btn2, txt2, 'Карта', "icon16/map.png")
    -- navigbtn(btn3, txt3, 'Информация', "icon16/information.png")
    -- navigbtn(btn4, txt4, 'Настройки', "icon16/cog.png")

    -- infoPanel
    local infoPanel = vgui.Create("DPanel", fill)
    infoPanel:Dock(FILL)
    infoPanel:DockMargin(0, 0, 0, 0)
    function infoPanel:Paint( w, h )
        draw.RoundedBox( corner, 0, 0, w, h, Color(0, 0, 0, 0))
    end
    -- sheet:AddSheet('Игрок', infoPanel, 'icon16/user.png')

    local modelPanel = vgui.Create("DModelPanel", infoPanel)
    modelPanel:Dock(RIGHT)
    modelPanel:SetSize(mainPanel:GetWide() * 0.3, 0)
    modelPanel:SetModel(ply:GetModel())
    modelPanel:SetFOV(24)
    modelPanel:SetCamPos(Vector(60, 0, 60))
    function modelPanel:LayoutEntity(Entity) return end
    modelPanel.Entity:SetSkin(ply:GetSkin())

    local function infoTitle(name, text, margin)
        local name = vgui.Create( "DLabel", infoPanel )
        name:Dock(TOP)
        name:DockMargin( 0, margin, 0, 0 )
        name:SetText(text)
        name:SetFont("lrp.menu-medium")
        name:SetTextColor(color_white)
        name:SetTextInset(16, 0)
    end

    infoTitle(nickTitle, 'Никнейм игрока', 12)

    local nick = vgui.Create( "DLabel", infoPanel )
    nick:Dock(TOP)
    nick:DockMargin( 0, 12, 0, 0 )
    nick:SetText(ply:GetName())
    nick:SetFont("lrp.menu-medium")
    nick:SetTextColor(Color( 255, 255, 255))
    nick:SetTextInset(32, 0)

    infoTitle(hpTitle, 'Здоровье / броня игрока', 36)
    local hp = vgui.Create( "DLabel", infoPanel )
    hp:Dock(TOP)
    hp:DockMargin( 0, 12, 0, 0 )
    hp:SetText(ply:Health() .. ' здоровья / ' .. ply:Armor() .. ' брони')
    hp:SetFont("lrp.menu-medium")
    hp:SetTextColor(Color( 255, 255, 255))
    hp:SetTextInset(32, 0)

    infoTitle(jobTitle, 'Профессия игрока', 36)
    local jobComboB = vgui.Create( "DComboBox", infoPanel )
    jobComboB:Dock(TOP)
    jobComboB:DockMargin( 32, 12, mainPanel:GetWide() * .3, 0 )
    jobComboB:SetValue(team.GetName(ply:Team()))
    jobComboB:SetIcon('icon16/status_offline.png')
    jobComboB:AddChoice("Гражданин", nil, false, 'icon16/user.png')
    jobComboB:AddChoice("Бездомный", nil, false, 'icon16/user_gray.png')
    jobComboB:AddChoice('Офицер полиции', nil, false, 'icon16/medal_gold_1.png')
    jobComboB:AddChoice("Детектив", nil, false, 'icon16/asterisk_yellow.png')
    jobComboB:AddChoice('Оперативник спецназа', nil, false, 'icon16/award_star_gold_1.png')
    jobComboB:AddChoice('Медик', nil, false, 'icon16/pill.png')

    infoTitle(modelTitle, 'Модель игрока', 36)
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

    infoTitle(skinTitle, 'Скин игрока', 36)
    local skinSlider = vgui.Create( "DNumSlider", infoPanel )
    skinSlider:Dock(TOP)
    skinSlider:DockMargin((mainPanel:GetWide() * -0.5) + 64, 12, 0, 0)
    skinSlider:SetMin(0)
    skinSlider:SetMax(23) -- NumModelSkins(modelPanel:GetModel()) - 1
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
        -- else
        --     spawnBtn:SetText('Сохранить и возродиться (' .. math.Round(timeLeft) .. ')')
	    end
	end
end

net.Receive('lrp.menu-main', function()
    LRPMenuMain()
end)