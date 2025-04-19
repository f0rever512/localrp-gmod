include('cl_quick_menu.lua')
include('lrp_blur.lua')

CreateClientConVar('lrp_sbtitle', '1', true, false)

local scale = ScrW() >= 1600 and 1 or 0.8

surface.CreateFont("lrp.sb-small", {
    font = "Calibri",
    size = 25,
    weight = 300,
    antialias = true,
    extended = true
})

surface.CreateFont('lrpSbTitle-font', {
    font = "Calibri",
    size = 27 * scale,
    weight = 500,
    antialias = true,
    extended = true
})

local scrw, scrh = ScrW(), ScrH()
local corner = 8

local main = Color(0, 80, 65)
local second = Color(0, 0, 0, 125)
local hovbtn = Color(0, 125, 100)

local blurMaterial = Material('pp/blurscreen')

function ToggleScoreboard(toggle)
    hook.Add( 'RenderScreenspaceEffects', 'lrpScoreboard.blur', function()
        local state = blurAmmount
        local a = 0.8 - math.pow( 1 - state, 4 )

        if a > 0 then
            local colMod = {
                ['$pp_colour_addr'] = 0,
                ['$pp_colour_addg'] = 0,
                ['$pp_colour_addb'] = 0,
                ['$pp_colour_mulr'] = 0,
                ['$pp_colour_mulg'] = 0,
                ['$pp_colour_mulb'] = 0,
                ['$pp_colour_brightness'] = -a * 0.2,
                ['$pp_colour_contrast'] = 1 + 0.5 * a,
                ['$pp_colour_colour'] = 1 - a,
            }
    
            DrawColorModify(colMod)
            surface.SetDrawColor(255, 255, 255, a * 255)
            surface.SetMaterial(blurMaterial)
            
            for i = 1, 3 do 
                blurMaterial:SetFloat('$blur', a * i * 2)
                blurMaterial:Recompute() 
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(-1, -1, ScrW() + 2, ScrH() + 2)
            end
            
            draw.NoTexture()
            surface.SetDrawColor(0, 45, 35, a * 250)
            surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
        end
    end)
    
    if toggle then
        sbActive = true

        SBPanel = vgui.Create("DPanel")
        SBPanel:SetSize(scrw * 0.4, scrh * 0.8)
        SBPanel:SetPos(scrw * 0.5 - SBPanel:GetWide() * 0.5, scrh * 0.52 - SBPanel:GetTall() * 0.5)
        SBPanel:MoveTo(scrw * 0.5 - SBPanel:GetWide() * 0.5, scrh * 0.5 - SBPanel:GetTall() * 0.5, 0.2, 0)
        SBPanel:SetAlpha(0)
        SBPanel:AlphaTo(255, 0.2, 0)
        SBPanel:MakePopup()
        SBPanel.Paint = function(self, w, h)
            draw.RoundedBox(corner, 0, 0, w, h, main)
        end

        if GetConVar("lrp_sbtitle"):GetBool() then
            local top = vgui.Create('DPanel', SBPanel)
            top:Dock(TOP)
            top:SetTall(scrh * 0.03)
            top.Paint = function(self, w, h)
                draw.SimpleText('LocalRP - Scoreboard', 'lrpSbTitle-font', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            local playerPnl = vgui.Create("DButton", scroll)
            playerPnl:Dock(TOP)
            playerPnl:DockMargin(6, 0, 6, 6)
            playerPnl:SetTall(scrh * 0.045)
            playerPnl:SetText("")
            playerPnl.DoClick = function()
                LRPDerma(v)
            end
            playerPnl.Paint = function(self, w, h)
                if IsValid(v) then
                    draw.RoundedBox(corner, 0, 0, w, h, self:IsHovered() and hovbtn or Color(0, 0, 0, 0))
                    if engine.ActiveGamemode() == 'localrp' then
                        draw.SimpleText(team.GetName(v:Team()), "lrp.sb-small", w * 0.5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end

            local rangIcon = vgui.Create("DImage", playerPnl)
            rangIcon:Dock(LEFT)
            rangIcon:SetWide(SBPanel:GetWide() * 0.02)
            rangIcon:DockMargin(12, SBPanel:GetTall() * 0.02, 12, SBPanel:GetTall() * 0.02)
            rangIcon:SetImage(v:IsAdmin() and "icon16/user_red.png" or "icon16/user.png")

            local img = vgui.Create("AvatarImage", playerPnl)
            img:Dock(LEFT)
            img:SetWide(scrh * 0.04)
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

            local nameLabel = vgui.Create("DLabel", playerPnl)
            nameLabel:Dock(LEFT)
            nameLabel:DockMargin(12, 0, 0, 0)
            nameLabel:SetText(v:Name())
            nameLabel:SetFont('lrp.sb-small')
            nameLabel:SetTextColor(color_white)
            nameLabel:SizeToContents()

            if v ~= LocalPlayer() then
                local mute = vgui.Create("DImageButton", playerPnl)
                mute:Dock(RIGHT)
                mute:SetWide(SBPanel:GetWide() * 0.05)
                mute:DockMargin(0, 8, 8, 8)
                mute:SetImage(v:IsMuted() and "icon32/muted.png" or "icon32/unmuted.png")
                mute.DoClick = function()
                    v:SetMuted(not v:IsMuted())
                    mute:SetImage(v:IsMuted() and "icon32/muted.png" or "icon32/unmuted.png")
                end
            end

            local kdLabel = vgui.Create("DLabel", playerPnl)
            kdLabel:Dock(RIGHT)
            kdLabel:DockMargin(0, 0, v == LocalPlayer() and SBPanel:GetWide() * 0.1 or SBPanel:GetWide() * 0.04, 0)
            kdLabel:SetText(string.format("%d      %d      %d", v:Frags(), v:Deaths(), v:Ping()))
            kdLabel:SetFont('lrp.sb-small')
            kdLabel:SetTextColor(color_white)
            kdLabel:SizeToContents()
        end
    else
        sbActive = false

        if IsValid(SBPanel) then
            SBPanel:AlphaTo(0, 0.2, 0)
            SBPanel:MoveTo(scrw * 0.5 - SBPanel:GetWide() * 0.5, scrh * 0.52 - SBPanel:GetTall() / 2, 0.2, 0)
            timer.Simple(0.2, function()
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

hook.Add('Think', 'lrpScoreboard.think', function()
    blurAmmount = math.Approach( blurAmmount or 0, sbActive and 0.8 or 0, FrameTime() / 0.3 )
end)