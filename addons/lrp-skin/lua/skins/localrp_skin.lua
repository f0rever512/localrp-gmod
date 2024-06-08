local surface = surface
local draw = draw
local Color = Color
local color_transparent = color_transparent
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

local MainColor = Color(0, 125, 100)
local Color_MenuBG = Color(0, 45, 35, 200)

local ShadowColor = Color(0, 0, 0, 25)

local ColorPrimary = Color(255, 255, 255)
local ColorSecondary = Color(200, 200, 200)

local BackgroundColorPrimary = Color(0, 80, 65)
local BackgroundColorSecondary = Color(0, 125, 100)
local BackgroundColorTertiary = Color(0, 185, 150)
local BackgroundColorDisabled = Color(100, 100, 100, 100)

local GradientDown = Material("gui/gradient_down")

SKIN = {}

SKIN.PrintName = "LocalRP Skin"
SKIN.Author = "Zgoly"
SKIN.DermaVersion = 1

SKIN.text_dark = Color(255, 255, 255)
SKIN.colTextEntryText = Color(255, 255, 255)
SKIN.colTextEntryTextHighlight = Color(0, 150, 255)
SKIN.colTextEntryTextCursor = Color(255, 255, 255)
SKIN.colTextEntryTextPlaceholder= Color(150, 150, 150)

SKIN.Colours = {}
SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive = ColorPrimary
SKIN.Colours.Window.TitleInactive = ColorSecondary

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal = ColorSecondary
SKIN.Colours.Button.Hover = ColorPrimary
SKIN.Colours.Button.Down = ColorPrimary
SKIN.Colours.Button.Disabled = ColorSecondary

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal = ColorPrimary
SKIN.Colours.Tab.Active.Hover = ColorPrimary
SKIN.Colours.Tab.Active.Down = ColorPrimary
SKIN.Colours.Tab.Active.Disabled = ColorSecondary

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal = ColorSecondary
SKIN.Colours.Tab.Inactive.Hover = ColorPrimary
SKIN.Colours.Tab.Inactive.Down = ColorPrimary
SKIN.Colours.Tab.Inactive.Disabled = ColorSecondary

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = ColorSecondary
SKIN.Colours.Label.Bright = ColorPrimary
SKIN.Colours.Label.Dark = ColorSecondary
SKIN.Colours.Label.Highlight = ColorPrimary

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines = ColorSecondary
SKIN.Colours.Tree.Normal = ColorSecondary
SKIN.Colours.Tree.Hover = ColorPrimary
SKIN.Colours.Tree.Selected = ColorPrimary

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal = ColorSecondary
SKIN.Colours.Properties.Line_Selected = ColorPrimary
SKIN.Colours.Properties.Line_Hover = ColorPrimary
SKIN.Colours.Properties.Title = ColorPrimary
SKIN.Colours.Properties.Column_Normal = ColorSecondary
SKIN.Colours.Properties.Column_Selected = ColorPrimary
SKIN.Colours.Properties.Column_Hover = ColorPrimary
SKIN.Colours.Properties.Border = ColorPrimary
SKIN.Colours.Properties.Label_Normal = ColorSecondary
SKIN.Colours.Properties.Label_Selected = ColorPrimary
SKIN.Colours.Properties.Label_Hover = ColorPrimary

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header = ColorPrimary
SKIN.Colours.Category.Header_Closed = ColorSecondary
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text = ColorSecondary
SKIN.Colours.Category.Line.Text_Hover = ColorPrimary
SKIN.Colours.Category.Line.Text_Selected = ColorPrimary
SKIN.Colours.Category.Line.Button = color_transparent
SKIN.Colours.Category.Line.Button_Hover = BackgroundColorSecondary
SKIN.Colours.Category.Line.Button_Selected = MainColor
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text = ColorSecondary
SKIN.Colours.Category.LineAlt.Text_Hover = ColorPrimary
SKIN.Colours.Category.LineAlt.Text_Selected = ColorPrimary
SKIN.Colours.Category.LineAlt.Button = color_transparent
SKIN.Colours.Category.LineAlt.Button_Hover = BackgroundColorSecondary
SKIN.Colours.Category.LineAlt.Button_Selected = MainColor

SKIN.Colours.TooltipText = ColorSecondary

function SKIN:PaintPanel(panel, w, h)
	if not panel.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
end

function SKIN:PaintFrame(panel, w, h)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorPrimary)
end

function SKIN:PaintButton(panel, w, h)
	if not panel.m_bBackground then return end
	local bgColor = BackgroundColorSecondary
	if panel.Depressed or panel:IsSelected() or panel:GetToggle() then
		bgColor = MainColor
	elseif panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end
	draw.RoundedBox(8, 0, 0, w, h, bgColor)
end

function SKIN:PaintTree(panel, w, h)
	if not panel.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorPrimary)
end

function SKIN:PaintCheckBox(panel, w, h)
    local bgColor = BackgroundColorSecondary
	local color = ColorPrimary

    if panel:GetDisabled() then
        bgColor = BackgroundColorDisabled
		color = ColorSecondary
    end

    draw.RoundedBox(w / 3, 0, 0, w, h, bgColor)

    if panel:GetChecked() and not panel:GetDisabled() then
		draw.SimpleText("a", "Marlett", w / 2 - 1, h / 2 - 1, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function SKIN:PaintExpandButton(panel, w, h)
	local text = panel:GetExpanded() and "-" or "+"
	draw.SimpleText(text, "DermaDefaultBold", w / 2 + 1, h / 2 - 1, ColorSecondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTextEntry(panel, w, h)
	if panel.m_bBackground then
		if panel:GetDisabled() then
			draw.RoundedBox(8, 0, 0, w, h, BackgroundColorDisabled)
		elseif panel:HasFocus() then
			draw.RoundedBox(8, 0, 0, w, h, BackgroundColorTertiary)
		else
			draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
		end
	end
	if panel.GetPlaceholderText and panel.GetPlaceholderColor and panel:GetPlaceholderText() and panel:GetPlaceholderText():Trim() ~= "" and panel:GetPlaceholderColor() and (not panel:GetText() or panel:GetText() == "") then
		local oldText = panel:GetText()
		local str = panel:GetPlaceholderText()
		if str:StartWith("#") then str = str:sub(2) end
		str = language.GetPhrase(str)
		panel:SetText(str)
		panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor())
		panel:SetText(oldText)
		return
	end
	panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor())
end

function SKIN:PaintMenu(panel, w, h)
	local old = DisableClipping(true)
	for i = 1, 8 do
		draw.RoundedBox(8 + i, -i, -i, w + i *  2, h + i * 2, ShadowColor)
	end
	DisableClipping(old)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorPrimary)
end

function SKIN:PaintMenuSpacer(panel, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	panel:SetTall(4)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintMenuOption(panel, w, h)
	if panel.m_bBackground and (panel.Hovered or panel.Highlight) then
		draw.RoundedBox(8, 2, 2, w - 4, h - 4, BackgroundColorSecondary)
	end
	if panel:GetChecked() then
		draw.SimpleText("a", "Marlett", h / 1.5, h / 2, ColorPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintMenuRightArrow(panel, w, h)
	draw.SimpleText("4", "Marlett", h / 2, h / 2, ColorPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintPropertySheet(panel, w, h)
	local ActiveTab = panel:GetActiveTab()
	local Offset = 0
	if ActiveTab then
		Offset = ActiveTab:GetTall() - 8
	end
	draw.RoundedBox(15, 0, Offset, w, h - Offset, Color_MenuBG)
end

function SKIN:PaintTab(panel, w, h)
	local step = 8
	local tabScroller = panel:GetParent():GetParent()
	tabScroller:SetOverlap(-5)
	tabScroller:DockMargin(16, 0, 16, 0)
	if panel:IsActive() then
		draw.RoundedBoxEx(8, 0, 0, w, h - step, MainColor, true, true)
		surface.SetMaterial(GradientDown)
		surface.SetDrawColor(MainColor)
		surface.DrawTexturedRect(0, h - step, w, step)
		return
	end
	draw.RoundedBoxEx(8, 0, 0, w, h, Color_MenuBG, true, true)
end

function SKIN:PaintWindowCloseButton(panel, w, h)
	if not panel.m_bBackground then return end

	local bgColor = BackgroundColorSecondary
	local color = ColorSecondary

	if panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
		color = ColorSecondary
	elseif panel.Depressed or panel:IsSelected() then
		bgColor = MainColor
		color = ColorPrimary
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
		color = ColorPrimary
	end

	draw.RoundedBox(8, 0, 4, w, h - 8, bgColor)
	draw.SimpleText("r", "Marlett", w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end


function SKIN:PaintWindowMaximizeButton(panel, w, h)
	-- if not panel.m_bBackground then return end

	-- local bgColor = BackgroundColorSecondary
	-- local color = ColorSecondary

	-- if panel:GetDisabled() then
	-- 	bgColor = BackgroundColorDisabled
	-- 	color = ColorSecondary
	-- elseif panel.Depressed or panel:IsSelected() then
	-- 	bgColor = MainColor
	-- 	color = ColorPrimary
	-- elseif panel.Hovered then
	-- 	bgColor = BackgroundColorTertiary
	-- 	color = ColorPrimary
	-- end

	-- draw.RoundedBox(0, 0, 4, w, h - 8, bgColor)
	-- draw.SimpleText("1", "Marlett", w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintWindowMinimizeButton(panel, w, h)
	-- if not panel.m_bBackground then return end

	-- local bgColor = BackgroundColorSecondary
	-- local color = ColorSecondary

	-- if panel:GetDisabled() then
	-- 	bgColor = BackgroundColorDisabled
	-- 	color = ColorSecondary
	-- elseif panel.Depressed or panel:IsSelected() then
	-- 	bgColor = MainColor
	-- 	color = ColorPrimary
	-- elseif panel.Hovered then
	-- 	bgColor = BackgroundColorTertiary
	-- 	color = ColorPrimary
	-- end

	-- draw.RoundedBoxEx(8, 0, 4, w, h - 8, bgColor, true, false, true)
	-- draw.SimpleText("0", "Marlett", w / 2, h / 2 - 4, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintVScrollBar(panel, w, h)
	local step = 14
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
	draw.RoundedBox(8, 0, step, w, h - step * 2, BackgroundColorPrimary)
end

function SKIN:PaintScrollBarGrip(panel, w, h)
	local bgColor = BackgroundColorSecondary

	if panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
	elseif panel.Depressed then
		bgColor = MainColor
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end

	draw.RoundedBox(8, 2, 2, w - 4, h - 4, bgColor)
end

function SKIN:PaintButtonDown(panel, w, h)
	if not panel.m_bBackground then return end

	local bgColor = BackgroundColorSecondary
	local color = ColorPrimary

	if panel.Depressed or panel:IsSelected() then
		bgColor = MainColor
	elseif panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
		color = ColorSecondary
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end
	
	draw.RoundedBoxEx(8, 0, 0, w, h, bgColor, false, false, true, true)
	draw.SimpleText("6", "Marlett", h / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintButtonUp(panel, w, h)
	if not panel.m_bBackground then return end

	local bgColor = BackgroundColorSecondary
	local color = ColorPrimary

	if panel.Depressed or panel:IsSelected() then
		bgColor = MainColor
	elseif panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
		color = ColorSecondary
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end
	
	draw.RoundedBoxEx(8, 0, 0, w, h, bgColor, true, true)
	draw.SimpleText("5", "Marlett", h / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintButtonLeft(panel, w, h)
	if not panel.m_bBackground then return end

	local bgColor = BackgroundColorSecondary
	local color = ColorPrimary

	if panel.Depressed or panel:IsSelected() then
		bgColor = MainColor
	elseif panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
		color = ColorSecondary
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end
	
	draw.RoundedBox(8, 0, 0, w, h, bgColor)
	draw.SimpleText("3", "Marlett", h / 2, h / 2, ColorPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintButtonRight(panel, w, h)
	if not panel.m_bBackground then return end

	local bgColor = BackgroundColorSecondary
	local color = ColorPrimary

	if panel.Depressed or panel:IsSelected() then
		bgColor = MainColor
	elseif panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
		color = ColorSecondary
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end
	
	draw.RoundedBox(8, 0, 0, w, h, bgColor)
	draw.SimpleText("4", "Marlett", h / 2, h / 2, ColorPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintComboDownArrow(panel, w, h)
	local color = ColorSecondary
	local text = "6"

	if panel.ComboBox.Depressed or panel.ComboBox:IsMenuOpen() then
		color = ColorPrimary
		text = "5"
	elseif panel.ComboBox.Hovered then
		color = ColorPrimary
	end

	draw.SimpleText(text, "Marlett", h / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintComboBox(panel, w, h)
	local bgColor = BackgroundColorSecondary

	if panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
	elseif panel.Depressed or panel:IsMenuOpen() then
		return draw.RoundedBox(8, 0, 0, w, h, MainColor)
	elseif panel.Hovered then
		bgColor = BackgroundColorTertiary
	end

	draw.RoundedBox(8, 0, 0, w, h, bgColor)
end

function SKIN:PaintListBox(panel, w, h)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
end

function SKIN:PaintNumberUp(panel, w, h)
	local color = ColorSecondary

	if panel.Depressed then
		color = MainColor
	elseif panel.Hovered then
		color = ColorPrimary
	end
	
	draw.SimpleText("5", "Marlett", h / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintNumberDown(panel, w, h)
	local color = ColorSecondary

	if panel.Depressed then
		color = MainColor
	elseif panel.Hovered then
		color = ColorPrimary
	end
	
	draw.SimpleText("6", "Marlett", h / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTreeNode(panel, w, h)
	if not panel.m_bDrawLines then return end
	surface.SetDrawColor(BackgroundColorSecondary)
	if panel.m_bLastChild then
		surface.DrawRect(9, 0, 2, 7)
		surface.DrawRect(9, 7, 9, 2)
	else
		surface.DrawRect(9, 0, 2, h)
	end
end

function SKIN:PaintTreeNodeButton(panel, w, h)
	if not panel.m_bSelected then return end
	local w, _ = panel:GetTextSize()
	draw.RoundedBox(8, 16, 0, w + 32, h, BackgroundColorSecondary)
end

function SKIN:PaintSelection(panel, w, h)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
end

function SKIN:PaintSliderKnob(panel, w, h)
	local bgColor = BackgroundColorTertiary
	if panel:GetDisabled() then
		bgColor = BackgroundColorDisabled
	elseif panel.Hovered then
		bgColor = MainColor
	end

	draw.SimpleText("n", "Marlett", h / 2, h / 2, bgColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function PaintNotches(x, y, w, h, num)
	if not num then return end
	local space = w / num
	for i = 0, num do
		surface.DrawRect(x + i * space, y, 2, 8)
	end
end

function SKIN:PaintNumSlider(panel, w, h)
	surface.SetDrawColor(BackgroundColorSecondary)
	surface.DrawRect(8, h / 2 - 1, w - 15, 2)
	PaintNotches(8, h / 2 - 1, w - 16, 1, panel.m_iNotches)
end

function SKIN:PaintProgress(panel, w, h)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
	draw.RoundedBox(8, 0, 0, w * panel:GetFraction(), h, MainColor)
end

function SKIN:PaintCollapsibleCategory(panel, w, h)
	panel:DockMargin(2, 2, 2, 2)
	if h <= panel:GetHeaderHeight() then
		if not panel:GetExpanded() then
			draw.RoundedBox(8, 0, 0, w, h, MainColor)
		end
	else
		draw.RoundedBoxEx(8, 0, 0, w, panel:GetHeaderHeight(), MainColor, true, true)
	end
end

function SKIN:PaintCategoryList(panel, w, h)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorPrimary)
end

function SKIN:PaintCategoryButton(panel, w, h)
	panel:SetTall(24)
	local bgColor = BackgroundColorSecondary
	if panel.Depressed or panel.m_bSelected then
		bgColor = BackgroundColorTertiary
	elseif panel.Hovered then
		bgColor = BackgroundColorSecondary
	else
		bgColor = color_transparent
	end
	draw.RoundedBox(8, 0, 2, w, h - 4, bgColor)
end

function SKIN:PaintListViewLine(panel, w, h)
	
	if panel:IsSelected() then
		draw.RoundedBox(8, 0, 0, w, h, MainColor)
	elseif panel.Hovered then
		draw.RoundedBox(8, 0, 0, w, h, BackgroundColorTertiary)
	end
end

function SKIN:PaintListView(panel, w, h)
	if not panel.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorSecondary)
end

function SKIN:PaintTooltip(panel, w, h)
	draw.RoundedBox(8, 0, 0, w, h, BackgroundColorPrimary)
end

function SKIN:PaintMenuBar(panel, w, h)
	surface.SetDrawColor(BackgroundColorPrimary)
	surface.DrawRect(0, 0, w, h)
end

derma.DefineSkin("localrp_skin", "LocalRP Skin", SKIN)