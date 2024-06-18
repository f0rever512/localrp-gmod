if CLIENT then end
-- concommand.Add( "lrp_greet", function()
-- 	local scrw, scrh = ScrW(), ScrH()
--     local main = Color(0, 80, 65, 255)
--     local bgclr = Color(0, 0, 0, 200) --0, 100, 80, 200
--     local panelclr = Color(0, 45, 35, 255)

--     --background
--     local background = vgui.Create("DPanel")
-- 	background:SetSize(scrw, scrh)
-- 	background:Center()
-- 	background.Paint = function(self, w, h)
-- 		draw.RoundedBox(0, 0, 0, w, h, bgclr)
-- 	end

--     --greetPanel
-- 	local greetPanel = vgui.Create("DPanel", background)
-- 	greetPanel:SetSize(scrw * .75, scrh * .75)
-- 	greetPanel:Center()
-- 	greetPanel:MakePopup()
-- 	greetPanel.Paint = function(self, w, h)
-- 		draw.RoundedBox(18, 0, 0, w, h, main)
-- 	end

--     --top
--     local top = vgui.Create( 'DPanel', greetPanel )
--     top:Dock(TOP)
--     top:SetTall(40)
--     function top:Paint( w, h )
--         draw.RoundedBoxEx(18, 0, 0, w, h, main, true, true, false, false)
--     end
	
--     --close
-- 	local close = vgui.Create("DButton", top)
-- 	close:Dock(RIGHT)
--     close:DockMargin(0, 0, 8, 0)
-- 	close:SetText("")
--     close:SetWide(40)
-- 	close.DoClick = function()
-- 		background:Remove()
-- 	end
-- 	close.Paint = function(self, w, h)
-- 		--draw.RoundedBoxEx(18, 0, 0, w, h, faded_black, false, true, false, false)
--         surface.SetDrawColor(255, 255, 255)
--         surface.SetMaterial(Material("icon16/cancel.png"))
--         surface.DrawTexturedRect(8, 8, w - 16, h - 16)
-- 	end

--     --title
--     local title = vgui.Create( "DLabel", top )
--     title:Dock(FILL)
--     title:SetText( "Приветственный экран - LocalRP" )
--     title:SetFont("titlefont")
--     title:SetTextColor(Color( 255, 255, 255))
--     title:SetTextInset(16, 0)

--     --fill
--     local fill = vgui.Create( 'DPanel', greetPanel )
--     fill:Dock(FILL)
--     fill:DockMargin(7, 0, 7, 7)
--     function fill:Paint( w, h )
--         draw.RoundedBox(18, 0, 0, w, h, panelclr)
--     end
-- end)