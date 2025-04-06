include('cl_quick_menu.lua')
include('lrp_blur.lua')

CreateClientConVar('lrp_sbtitle', '1', true, false)

surface.CreateFont("lrp.sb-small", {
    font = "Calibri",
    size = 25,
    weight = 300,
    antialias = true,
    extended = true
})

surface.CreateFont("lrp.sb-medium", {
    font = "Calibri",
    size = 27,
    weight = 500,
    antialias = true,
    extended = true
})

function ToggleScoreboard(toggle)
    local scrw, scrh = ScrW(), ScrH()
    local corner = 15

    local main = Color(0, 80, 65)
    local second = Color(0, 0, 0, 125)
    local hovbtn = Color(0, 125, 100)

    if toggle then
        hook.Add('RenderScreenspaceEffects', 'lrp.menu-blur', LRPBlur)
        -- blurPanel = vgui.Create('DPanel')
        -- blurPanel:SetSize(ScrW(), ScrH())
        -- blurPanel.Paint = function(self, w, h)
        --     LRPBlur()
        -- end

        SBPanel = vgui.Create("DPanel")
        SBPanel:SetSize(scrw * 0.4, scrh * 0.8)
        SBPanel:SetPos(-SBPanel:GetWide(), scrh * 0.5 - SBPanel:GetTall() / 2)
        SBPanel:MoveTo(scrw * 0.5 - SBPanel:GetWide() / 2, scrh * 0.5 - SBPanel:GetTall() / 2, 0.2, 0)
        SBPanel:SetAlpha(0)
        SBPanel:AlphaTo(255, 0.2, 0)
        SBPanel:MakePopup()
        SBPanel.Paint = function(self, w, h)
            draw.RoundedBox(corner, 0, 0, w, h, main)
        end

        if GetConVar("lrp_sbtitle"):GetBool() then
            local top = vgui.Create('DPanel', SBPanel)
            top:Dock(TOP)
            top:SetTall(32)
            top.Paint = function(self, w, h)
                draw.RoundedBox(corner, 0, 0, w, h, main)
                draw.SimpleText('LocalRP - Scoreboard', "lrp.sb-medium", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local fill = vgui.Create("DPanel", SBPanel)
        fill:Dock(FILL)
        fill:DockMargin(6, GetConVar("lrp_sbtitle"):GetBool() and 0 or 6, 6, 6)
        fill:DockPadding(0, 6, 0, 6)
        fill.Paint = function(self, w, h)
            draw.RoundedBox(corner, 0, 0, w, h, second)
        end

        local scroll = vgui.Create("DScrollPanel", fill)
        scroll:Dock(FILL)

        for _, v in ipairs(player.GetAll()) do
            local plypanel = vgui.Create("DButton", scroll)
            plypanel:Dock(TOP)
            plypanel:DockMargin(6, 0, 6, 6)
            plypanel:SetTall(SBPanel:GetTall() * 0.06)
            plypanel:SetText("")
            plypanel.DoClick = function()
                LRPDerma(v)
            end
            plypanel.Paint = function(self, w, h)
                if IsValid(v) then
                    draw.RoundedBox(corner, 0, 0, w, h, self:IsHovered() and hovbtn or Color(0, 0, 0, 0))
                    if engine.ActiveGamemode() == 'localrp' then
                        draw.SimpleText(team.GetName(v:Team()), "lrp.sb-small", w * 0.5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end

            local rangicon = vgui.Create("DImage", plypanel)
            rangicon:Dock(LEFT)
            rangicon:SetWide(SBPanel:GetWide() * 0.02)
            rangicon:DockMargin(12, SBPanel:GetTall() * 0.02, 12, SBPanel:GetTall() * 0.02)
            rangicon:SetImage(v:IsAdmin() and "icon16/user_red.png" or "icon16/user.png")

            local img = vgui.Create("AvatarImage", plypanel)
            img:Dock(LEFT)
            img:SetWide(SBPanel:GetWide() * 0.06)
            img:DockMargin(0, 4, 0, 4)
            img:SetPlayer(v, 38)

            local imgb = vgui.Create("DButton", img)
            imgb:Dock(FILL)
            imgb:SetText('')
            imgb.Paint = function() end
            imgb.DoClick = function()
                if IsValid(v) then
                    v:ShowProfile()
                end
            end

            local nameLabel = vgui.Create("DLabel", plypanel)
            nameLabel:Dock(LEFT)
            nameLabel:DockMargin(12, 0, 0, 0)
            nameLabel:SetText(v:Name())
            nameLabel:SetFont('lrp.sb-small')
            nameLabel:SetTextColor(color_white)
            nameLabel:SizeToContents()

            if v ~= LocalPlayer() then
                local mute = vgui.Create("DImageButton", plypanel)
                mute:Dock(RIGHT)
                mute:SetWide(SBPanel:GetWide() * 0.05)
                mute:DockMargin(0, 8, 8, 8)
                mute:SetImage(v:IsMuted() and "icon32/muted.png" or "icon32/unmuted.png")
                mute.DoClick = function()
                    v:SetMuted(not v:IsMuted())
                    mute:SetImage(v:IsMuted() and "icon32/muted.png" or "icon32/unmuted.png")
                end
            end

            local kdLabel = vgui.Create("DLabel", plypanel)
            kdLabel:Dock(RIGHT)
            kdLabel:DockMargin(0, 0, v == LocalPlayer() and SBPanel:GetWide() * 0.1 or SBPanel:GetWide() * 0.04, 0)
            kdLabel:SetText(string.format("%d      %d      %d", v:Frags(), v:Deaths(), v:Ping()))
            kdLabel:SetFont('lrp.sb-small')
            kdLabel:SetTextColor(color_white)
            kdLabel:SizeToContents()
        end
    else
        if IsValid(SBPanel) then
            SBPanel:AlphaTo(0, 0.2, 0)
            SBPanel:MoveTo(scrw, scrh * 0.5 - SBPanel:GetTall() / 2, 0.2, 0)
            timer.Simple(0.2, function()
                hook.Remove('RenderScreenspaceEffects', 'lrp.menu-blur')
                -- blurPanel:Remove()
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
