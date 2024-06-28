include('lrp_blur.lua')
include('lrp_derma.lua')

CreateClientConVar('lrp_sbtitle', '1', true, false)

surface.CreateFont( "lrp.sb-small", {
	font = "Calibri",
	size = 25,
	weight = 300,
	antialias = true,
	extended = true
})
surface.CreateFont( "lrp.sb-medium", {
	font = "Calibri",
	size = 27,
	weight = 500,
	antialias = true,
	extended = true
})

local function ToggleScoreboard(toggle)
	local scrw, scrh = ScrW(), ScrH()
	local corner = 15

	local main = Color(0, 80, 65)
    local second = Color(0, 0, 0, 125)
	local hovbtn = Color(0, 125, 100)

	if toggle then
		hook.Add('RenderScreenspaceEffects', 'lrp.menu-blur', LRPBlur)
		--gui.EnableScreenClicker( true )
		SBPanel = vgui.Create("DPanel")
		SBPanel:SetSize(ScrW() * .4, ScrH() * .8)
		SBPanel:SetPos(-SBPanel:GetWide(), ScrH() * .5 - SBPanel:GetTall() / 2)
		SBPanel:MoveTo(ScrW() * .5 - SBPanel:GetWide() / 2, ScrH() * .5 - SBPanel:GetTall() / 2, 0.2, 0)
		SBPanel:SetAlpha(0)
		SBPanel:AlphaTo(255, 0.2, 0)
		SBPanel:MakePopup()
		SBPanel.Paint = function(self, w, h)
			draw.RoundedBox(corner, 0, 0, w, h, main)
		end

		if GetConVarNumber('lrp_sbtitle') == 1 then
			local top = vgui.Create('DPanel', SBPanel)
			top:Dock(TOP)
			top:SetTall(32)
			function top:Paint( w, h )
				draw.RoundedBox(corner, 0, 0, w, h, main)
				draw.SimpleText('LocalRP - Scoreboard', "lrp.sb-medium", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
		
		fill = vgui.Create("DPanel", SBPanel)
		fill:Dock(FILL)
		if GetConVarNumber('lrp_sbtitle') == 1 then
			fill:DockMargin(6, 0, 6, 6)
		else
			fill:DockMargin(6, 6, 6, 6)
		end
		fill:DockPadding(0, 6, 0, 6)
		function fill:Paint( w, h )
			draw.RoundedBox(corner, 0, 0, w, h, second)
		end

		local scroll = vgui.Create("DScrollPanel", fill)
		scroll:Dock(FILL)

		for k, v in pairs(player.GetAll()) do
			local plypanel = vgui.Create("DButton", scroll)
			plypanel:Dock(TOP)
			plypanel:DockMargin(6, 0, 6, 6)
			plypanel:SetTall(SBPanel:GetTall() * .06)
			plypanel:SetText("")
			plypanel.DoClick = function()
				LRPDerma(v)
			end

			plypanel.Paint = function(self, w, h)
				if IsValid(v) then
					if self:IsHovered() then
						draw.RoundedBox(corner, 0, 0, w, h, hovbtn)
					else
						draw.RoundedBox(corner, 0, 0, w, h, Color(0, 0, 0, 0))
					end

					if engine.ActiveGamemode() == 'localrp' then
						draw.SimpleText(team.GetName(v:Team()), "lrp.sb-small", w * .5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					end
				end
			end

			local rangicon = vgui.Create( "DImage", plypanel )
			rangicon:Dock(LEFT)
			rangicon:SetWide(SBPanel:GetWide() * .02)
			rangicon:DockMargin(12, SBPanel:GetTall() * .02, 12, SBPanel:GetTall() * .02)
			if v:IsAdmin() then
				rangicon:SetImage("icon16/user_red.png")
			else
				rangicon:SetImage("icon16/user.png")
			end

			local img = vgui.Create( "AvatarImage", plypanel )
			img:Dock(LEFT)
			img:SetWide(SBPanel:GetWide() * .06)
			img:DockMargin(0, 4, 0, 4)
			img:SetPlayer( v, 38 )

			local imgb = vgui.Create( "DButton", img )
			imgb:Dock(FILL)
			imgb:SetText('')
			imgb.Paint = function( self, w, h ) end
			imgb.DoClick = function()
				if IsValid(v) then
					v:ShowProfile()
				end
			end

			local nameLabel = vgui.Create("DLabel", plypanel)
			nameLabel:Dock(LEFT)
			nameLabel:DockMargin(12, 0, 0, 0 )
			nameLabel:SetText(v:Name())
			nameLabel:SetFont('lrp.sb-small')
			nameLabel:SetTextColor(Color( 255, 255, 255))

			if v ~= LocalPlayer() then
				local mute = vgui.Create( "DImageButton", plypanel )
				mute:Dock(RIGHT)
				mute:SetWide(SBPanel:GetWide() * .05)
				mute:DockMargin(0, 8, 8, 8)
				mute:SetPlayer( v, 38 )
				if v:IsMuted() == false then
					mute:SetImage( "icon32/unmuted.png" )
				else
					mute:SetImage( "icon32/muted.png" )
				end
				mute.DoClick = function()
					if mute:GetImage() == "icon32/unmuted.png" then
						v:SetMuted( true )
						mute:SetImage( "icon32/muted.png" )
					else
						v:SetMuted( false )
						mute:SetImage( "icon32/unmuted.png" )
					end
				end
			end

			local frags = v:Frags()
			local deaths = v:Deaths()
			local ping = v:Ping()

			local kdLabel = vgui.Create("DLabel", plypanel)
			kdLabel:Dock(RIGHT)
			if v ~= LocalPlayer() then
				kdLabel:DockMargin(0, 0, SBPanel:GetWide() * .04, 0)
			else
				kdLabel:DockMargin(0, 0, SBPanel:GetWide() * .1, 0)
			end
			kdLabel:SetText(frags .. '      ' .. deaths .. '      ' .. ping)
			kdLabel:SetFont('lrp.sb-small')
			kdLabel:SetTextColor(Color( 255, 255, 255))
			kdLabel:SizeToContents()
		end
	else
		SBPanel:AlphaTo(0, 0.2, 0)
		SBPanel:MoveTo(ScrW(), ScrH() * .5 - SBPanel:GetTall() / 2, 0.2, 0)
		--gui.EnableScreenClicker(false)
		if IsValid(SBPanel) then
			timer.Simple( 0.2, function()
				hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
				SBPanel:Remove()
			end)
		end
	end
end

hook.Add( "ScoreboardShow", "Scoreboard_Open", function()
    ToggleScoreboard(true)
	return false
end )

hook.Add( "ScoreboardHide", "Scoreboard_Close", function()
	ToggleScoreboard(false)
	CloseDermaMenus()
end )