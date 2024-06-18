-- local function LRPMenu()
-- 	local scrw, scrh = ScrW(), ScrH()
--     local main = Color(0, 80, 65, 255)
--     local bgclr = Color(0, 100, 80, 200)
--     local panelclr = Color(0, 45, 35, 255)

-- 	--mainPanel
--     local mainPanel = vgui.Create( 'DPanel' )
--     mainPanel:SetSize( scrw, scrh )
--     mainPanel:Dock(FILL)
--     mainPanel:MakePopup()
--     function mainPanel:Paint( w, h )
--         draw.RoundedBox( 0, 0, 0, w, h, bgclr )
--     end

--     --top
--     local top = vgui.Create( 'DPanel', mainPanel )
--     top:Dock(TOP)
--     top:SetTall(40)
--     function top:Paint( w, h )
--         draw.RoundedBox( 0, 0, 0, w, h, main )
--     end

--     --ctrl
--     local ctrl = vgui.Create( 'DPanel', mainPanel )
--     ctrl:Dock(BOTTOM)
--     ctrl:SetTall(40)
--     function ctrl:Paint( w, h )
--         draw.RoundedBox( 0, 0, 0, w, h, main )
--     end

--     --title
--     local title = vgui.Create( "DLabel", top )
--     title:Dock(FILL)
--     title:SetText( "LocalRP Menu" )
--     title:SetFont("titlefont")
--     title:SetTextColor(Color( 255, 255, 255))
--     title:SetTextInset(16, 0)

-- 	--close
-- 	local close = vgui.Create( 'DButton', top )
-- 	close:Dock(RIGHT)
--     close:SetWide(40)
--     close:SetText("")
-- 	close.DoClick = function()
-- 		mainPanel:Remove()
-- 	end
--     function close:Paint( w, h )
--         surface.SetDrawColor(0, 100, 80)
--         surface.SetMaterial(Material("icon16/cancel.png"))
--         surface.DrawTexturedRect(8, 8, w - 16, h - 16)
--     end

--     --playerPanel
--     playerW = scrw * .3
--     playerH = scrh * .65
    
--     local playerPanel = vgui.Create( 'DFrame', mainPanel )
--     playerPanel:SetSize( playerW, playerH )
--     playerPanel:Center()
--     playerPanel:SetTitle( 'Настройка игрока' )
--     playerPanel:ShowCloseButton( false )
--     function playerPanel:Paint( w, h )
--         draw.RoundedBox( 12, 0, 0, w, h, panelclr )
--     end

--     --modelPanel
--     modelW = playerW * .35
--     local modelPanel = vgui.Create("DModelPanel", playerPanel)
--     modelPanel:Dock(LEFT)
--     modelPanel:SetSize( modelW, 0 )
--     modelPanel:SetModel(LocalPlayer():GetModel())
--     modelPanel:SetFOV(21)
--     --function icon:LayoutEntity( Entity ) return end
--     --function icon.Entity:GetPlayerColor() return Vector (1, 0, 0) end

--     --ctrl button
--     local navigbtn1 = vgui.Create( 'DButton', ctrl )
-- 	navigbtn1:Dock(FILL)
--     navigbtn1:DockMargin(1, 5, 1, 5)
--     navigbtn1:SetText("")
-- 	navigbtn1.DoClick = function()
--         playerPanel:SetVisible(visible)
--         visible = !visible
-- 	end
--     function navigbtn1:Paint( w, h )
--         surface.SetDrawColor(255, 255, 255)
--         surface.SetMaterial(Material("icon16/user.png"))
--         surface.DrawTexturedRect(w / 2.03, 0, 30, 30)
--     end

--     --infoPanel
--     local infoPanel = vgui.Create("DPanel", playerPanel)
--     infoPanel:Dock(FILL)
--     function infoPanel:Paint( w, h )
--         draw.RoundedBox( 12, 0, 0, w, h, main )
--     end

--     --nickTitle
--     local nickTitle = vgui.Create( "DLabel", infoPanel )
--     nickTitle:Dock(TOP)
--     nickTitle:DockMargin( 0, 10, 0, 0 )
--     nickTitle:SetText( "Никнейм игрока" )
--     nickTitle:SetFont("mainfont")
--     nickTitle:SetTextColor(Color( 255, 255, 255))
--     nickTitle:SetTextInset(16, 0)

--     --nick
--     local nick = vgui.Create( "DLabel", infoPanel )
--     nick:Dock(TOP)
--     nick:DockMargin( 0, 10, 0, 0 )
--     nick:SetText( LocalPlayer():GetName() )
--     nick:SetFont("mainfont")
--     nick:SetTextColor(Color( 255, 255, 255))
--     nick:SetTextInset(32, 0)

--     --nickEntry
--     -- local nickEntry = vgui.Create("DTextEntry", infoPanel)
--     -- nickEntry:SetSize(infoPanel:GetSize() / .17, 30)
--     -- nickEntry:SetPos(0, 100)
--     -- nickEntry:SetTextColor(Color(0, 0, 0))
--     -- nickEntry:SetFont("mainfont")
--     -- nickEntry:SetValue( LocalPlayer():GetName() )
--     -- nickEntry.OnEnter = function( self )
-- 	-- 	chat.AddText( self:GetValue() )
-- 	-- end

--     --modelTitle
--     local modelTitle = vgui.Create( "DLabel", infoPanel )
--     modelTitle:Dock(TOP)
--     modelTitle:DockMargin( 0, 30, 0, 0 )
--     modelTitle:SetText( "Модель игрока" )
--     modelTitle:SetFont("mainfont")
--     modelTitle:SetTextColor(Color( 255, 255, 255))
--     modelTitle:SetTextInset(16, 0)

--     --modelComboB
--     local ModelComboB = vgui.Create( "DComboBox", infoPanel )
--     ModelComboB:Dock(TOP)
--     ModelComboB:DockMargin( 32, 10, 32, 0 )
--     ModelComboB:SetValue( "Выбери модель" )
--     ModelComboB:AddChoice( "models/humans/modern/male_01_01.mdl" )
--     ModelComboB:AddChoice( "models/humans/modern/male_02_01.mdl" )
--     ModelComboB:AddChoice( "models/humans/modern/male_03_01.mdl" )
--     ModelComboB.OnSelect = function( self, index, value )
--         ppp = value
--         print( ppp .. " имеет индекс: " .. index )
--     end
--     ccc = ppp

--     --classTitle
--     local classTitle = vgui.Create( "DLabel", infoPanel )
--     classTitle:Dock(TOP)
--     classTitle:DockMargin( 0, 30, 0, 0 )
--     classTitle:SetText( "Класс игрока" )
--     classTitle:SetFont("mainfont")
--     classTitle:SetTextColor(Color( 255, 255, 255))
--     classTitle:SetTextInset(16, 0)

--     --class
--     local class = vgui.Create( "DLabel", infoPanel )
--     class:Dock(TOP)
--     class:DockMargin( 0, 10, 0, 0 )
--     class:SetText( team.GetName(LocalPlayer():Team()) )
--     class:SetFont("mainfont")
--     class:SetTextColor(Color( 255, 255, 255))
--     class:SetTextInset(32, 0)
-- end

local function LRPMenu()
	local scrw, scrh = ScrW(), ScrH()
    local bgclr = Color(0, 0, 0, 200)
    local main = Color(0, 80, 65, 255)
    local second = Color(0, 0, 0, 125)

    --background
    local background = vgui.Create("DPanel")
	background:SetSize(scrw, scrh)
	background:Center()
	background.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, bgclr)
	end

    --mainPanel
	local mainPanel = vgui.Create("DPanel", background)
	mainPanel:SetSize(scrw * .8, scrh * .8)
	mainPanel:Center()
	mainPanel:MakePopup()
	mainPanel.Paint = function(self, w, h)
		draw.RoundedBox(15, 0, 0, w, h, main)
	end

    --top
    local top = vgui.Create( 'DPanel', mainPanel )
    top:Dock(TOP)
    top:SetTall(40)
    function top:Paint( w, h )
        draw.RoundedBoxEx(15, 0, 0, w, h, main, true, true, false, false)
    end

    --navig
    local navig = vgui.Create( "DPanel", mainPanel )
    navig:Dock(LEFT)
    navig:SetWide(200)
    navig:DockMargin(6, 0, 0, 6)
    function navig:Paint( w, h )
        draw.RoundedBox(15, 0, 0, w, h, main)
    end
	
    --close
	local close = vgui.Create("DButton", top)
	close:Dock(RIGHT)
	close:SetText("")
    close:SetWide(40)
	close.DoClick = function()
		background:Remove()
	end
	close.Paint = function(self, w, h)
		--draw.RoundedBoxEx(18, 0, 0, w, h, faded_black, false, true, false, false)
        surface.SetDrawColor(0, 100, 80)
        surface.SetMaterial(Material('icon16/cross.png'))
        surface.DrawTexturedRect(8, 8, w - 16, h - 16)
	end

    --title
    local title = vgui.Create( "DLabel", top )
    title:Dock(FILL)
    title:SetText( "LocalRP Menu" )
    title:SetFont("titlefont")
    title:SetTextColor(Color( 255, 255, 255))
    title:SetTextInset(16, 0)

    --fill
    local fill = vgui.Create( 'DPanel', mainPanel )
    fill:Dock(FILL)
    fill:DockMargin(6, 0, 6, 6)
    function fill:Paint( w, h )
        draw.RoundedBox(15, 0, 0, w, h, main)
    end

    local function navigbtn(name, name2, text, icon)
        local name = vgui.Create( 'DButton', navig )
        name:SetText("")
        name:SetIcon(icon)
        name:SetTall(40)
        name:Dock(TOP)
        name:DockMargin(0, 0, 0, 6)
        name.DoClick = function()
            fill:SetVisible(visible)
            visible = !visible
        end
        function name:Paint( w, h )
            draw.RoundedBox( 15, 0, 0, w, h, second )
        end

        local name2 = vgui.Create( "DLabel", name )
        name2:Dock(LEFT)
        name2:SetText(text)
        name2:SetFont("mainfont")
        name2:SetTextColor(Color( 255, 255, 255))
        name2:SetTextInset(40, 0)
        name2:SizeToContents()
    end

    navigbtn(btn1, txt1,'Игрок', "icon16/user.png")
    navigbtn(btn2, txt2, 'Карта', "icon16/map.png")
    navigbtn(btn3, txt3, 'Информация', "icon16/information.png")
    navigbtn(btn4, txt4, 'Настройки', "icon16/cog.png")

    local modelPanel = vgui.Create("DModelPanel", fill)
    modelPanel:Dock(RIGHT)
    modelPanel:SetSize( 250, 0 )
    modelPanel:SetModel(LocalPlayer():GetModel())
    modelPanel:SetFOV(24)

    -- infoPanel
    local infoPanel = vgui.Create("DPanel", fill)
    infoPanel:Dock(FILL)
    infoPanel:DockMargin(0, 0, 0, 0)
    function infoPanel:Paint( w, h )
        draw.RoundedBox( 15, 0, 0, w, h, second)
    end

    --nickTitle
    local nickTitle = vgui.Create( "DLabel", infoPanel )
    nickTitle:Dock(TOP)
    nickTitle:DockMargin( 0, 10, 0, 0 )
    nickTitle:SetText( "Никнейм игрока" )
    nickTitle:SetFont("mainfont")
    nickTitle:SetTextColor(Color( 255, 255, 255))
    nickTitle:SetTextInset(16, 0)

    --nick
    local nick = vgui.Create( "DLabel", infoPanel )
    nick:Dock(TOP)
    nick:DockMargin( 0, 10, 0, 0 )
    nick:SetText( LocalPlayer():GetName() )
    nick:SetFont("mainfont")
    nick:SetTextColor(Color( 255, 255, 255))
    nick:SetTextInset(32, 0)

    --nickEntry
    -- local nickEntry = vgui.Create("DTextEntry", infoPanel)
    -- nickEntry:SetSize(infoPanel:GetSize() / .17, 30)
    -- nickEntry:SetPos(0, 100)
    -- nickEntry:SetTextColor(Color(0, 0, 0))
    -- nickEntry:SetFont("mainfont")
    -- nickEntry:SetValue( LocalPlayer():GetName() )
    -- nickEntry.OnEnter = function( self )
	-- 	chat.AddText( self:GetValue() )
	-- end

    --modelTitle
    local modelTitle = vgui.Create( "DLabel", infoPanel )
    modelTitle:Dock(TOP)
    modelTitle:DockMargin( 0, 30, 0, 0 )
    modelTitle:SetText( "Модель игрока" )
    modelTitle:SetFont("mainfont")
    modelTitle:SetTextColor(Color( 255, 255, 255))
    modelTitle:SetTextInset(16, 0)

    --modelname
    local modelname = vgui.Create( "DLabel", infoPanel )
    modelname:Dock(TOP)
    modelname:DockMargin( 0, 10, 0, 0 )
    modelname:SetText( LocalPlayer():GetModel() )
    modelname:SetFont("mainfont")
    modelname:SetTextColor(Color( 255, 255, 255))
    modelname:SetTextInset(32, 0)

    --classTitle
    local classTitle = vgui.Create( "DLabel", infoPanel )
    classTitle:Dock(TOP)
    classTitle:DockMargin( 0, 30, 0, 0 )
    classTitle:SetText( "Класс игрока" )
    classTitle:SetFont("mainfont")
    classTitle:SetTextColor(Color( 255, 255, 255))
    classTitle:SetTextInset(16, 0)

    --class
    local class = vgui.Create( "DLabel", infoPanel )
    class:Dock(TOP)
    class:DockMargin( 0, 10, 0, 0 )
    class:SetText( team.GetName(LocalPlayer():Team()) )
    class:SetFont("mainfont")
    class:SetTextColor(Color( 255, 255, 255))
    class:SetTextInset(32, 0)

    --classComboB
    local classComboB = vgui.Create( "DComboBox", infoPanel )
    classComboB:Dock(TOP)
    classComboB:DockMargin( 32, 10, 640, 0 )
    classComboB:SetValue( "Выбери класс" )
    classComboB:AddChoice("Гражданин")
    classComboB:AddChoice("Бездомный")
    classComboB:AddChoice("Полицейский")
    classComboB:AddChoice("Детектив")
    classComboB:AddChoice("Спецназ")
    classComboB.OnSelect = function( self, index, value )
        print( value .. " имеет индекс: " .. index )
    end
end

net.Receive("lrpmenu", function()
    LRPMenu()
end)