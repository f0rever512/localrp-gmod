include('cl_quick_menu.lua')

CreateClientConVar('lrp_sbtitle', '1', true, false)

local scale = ScrW() >= 1600 and 1 or 0.8

surface.CreateFont('lrpSbSmall-font', {
    font = "Calibri",
    size = 25 * scale,
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

local function createLabel(parent, text, font, color, dock, margin, inset)
    local label = vgui.Create('DLabel', parent)
    label:SetText(text)
    label:SetFont(font)
    label:SetTextColor(color)
    label:Dock(dock)
    label:SizeToContents()
    if margin then label:DockMargin(unpack(margin)) end
    if inset then label:SetTextInset(unpack(inset)) end
    return label
end

local corner = 8
local fadeTime = 0.2

local main = Color(0, 80, 65)
local second = Color(0, 0, 0, 125)
local hovbtn = Color(0, 125, 100)

local blurMaterial = Material('pp/blurscreen')

function ToggleScoreboard(toggle)
    local width, height = ScrW(), ScrH()
    
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
                surface.DrawTexturedRect(-1, -1, width + 2, height + 2)
            end
            
            draw.NoTexture()
            surface.SetDrawColor(0, 45, 35, a * 250)
            surface.DrawRect(-1, -1, width + 1, height + 1)
        end
    end)
    
    if toggle then
        sbActive = true

        SBPanel = vgui.Create("DPanel")
        SBPanel:SetSize(width * 0.4, height * 0.8)
        SBPanel:SetPos(width * 0.5 - SBPanel:GetWide() * 0.5, height * 0.52 - SBPanel:GetTall() * 0.5)
        SBPanel:MoveTo(width * 0.5 - SBPanel:GetWide() * 0.5, height * 0.5 - SBPanel:GetTall() * 0.5, fadeTime, 0)
        SBPanel:SetAlpha(0)
        SBPanel:AlphaTo(255, fadeTime, 0)
        SBPanel:MakePopup()
        SBPanel.Paint = function(self, w, h)
            draw.RoundedBox(corner, 0, 0, w, h, main)
        end

        if GetConVar("lrp_sbtitle"):GetBool() then
            local top = vgui.Create('DPanel', SBPanel)
            top:Dock(TOP)
            top:SetTall(height * 0.03)
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
            playerPnl:SetTall(height * 0.045)
            playerPnl:SetText("")
            playerPnl.DoClick = function()
                if v:IsValid() then
                    LRPDerma(v)
                end
            end
            playerPnl.Paint = function(self, w, h)
                draw.RoundedBox(corner, 0, 0, w, h, self:IsHovered() and hovbtn or Color(0, 0, 0, 0))
                if v:IsValid() and engine.ActiveGamemode() == 'localrp' then
                    draw.SimpleText(team.GetName(v:Team()), 'lrpSbSmall-font', w * 0.5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            local rangIconMargin = playerPnl:GetTall() * 0.35
            local rangIcon = vgui.Create("DImage", playerPnl)
            rangIcon:Dock(LEFT)
            rangIcon:SetWide(playerPnl:GetWide() * 0.25)
            rangIcon:DockMargin(rangIconMargin * 0.5, rangIconMargin, rangIconMargin * 0.5, rangIconMargin)
            rangIcon:SetImage(v:IsAdmin() and "icon16/user_red.png" or "icon16/user.png")

            local img = vgui.Create("AvatarImage", playerPnl)
            img:Dock(LEFT)
            img:SetWide(playerPnl:GetTall() - 8)
            img:DockMargin(0, 4, 0, 4)
            img:SetPlayer(v, 48)

            local imgb = vgui.Create("DButton", img)
            imgb:Dock(FILL)
            imgb:SetText('')
            imgb.Paint = function() end
            imgb.DoClick = function()
                if v:IsValid() then
                    v:ShowProfile()
                end
            end

            createLabel(playerPnl, v:Name(), 'lrpSbSmall-font', color_white, LEFT, {8, 0, 0, 0})

            if v ~= LocalPlayer() then
                local mute = vgui.Create("DImageButton", playerPnl)
                mute:Dock(RIGHT)
                mute:SetWide(playerPnl:GetTall() - 8)
                mute:DockMargin(0, 4, 4, 4)
                mute:SetImage(v:IsMuted() and "icon32/muted.png" or "icon32/unmuted.png")
                mute.DoClick = function()
                    if v:IsValid() then
                        v:SetMuted(not v:IsMuted())
                        mute:SetImage(v:IsMuted() and "icon32/muted.png" or "icon32/unmuted.png")
                    end
                end
            end

            createLabel(playerPnl, v:Ping(), 'lrpSbSmall-font', color_white, RIGHT, {0, 0, 32 + (v == LocalPlayer() and playerPnl:GetTall() - 4 or 0), 0})
            createLabel(playerPnl, v:Deaths(), 'lrpSbSmall-font', color_white, RIGHT, {0, 0, 32, 0})
            createLabel(playerPnl, v:Frags(), 'lrpSbSmall-font', color_white, RIGHT, {0, 0, 32, 0})
        end
    else
        sbActive = false

        if IsValid(SBPanel) then
            SBPanel:AlphaTo(0, fadeTime, 0)
            SBPanel:MoveTo(width * 0.5 - SBPanel:GetWide() * 0.5, height * 0.52 - SBPanel:GetTall() / 2, fadeTime, 0)
            timer.Simple(fadeTime, function()
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
    blurAmmount = math.Approach( blurAmmount or 0, sbActive and 0.8 or 0, FrameTime() / (fadeTime + 0.2) )
end)