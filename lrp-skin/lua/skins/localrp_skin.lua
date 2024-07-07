local surface = surface
local draw = draw
local Color = Color
local color_transparent = color_transparent

local clr = {}

clr.main = clr.main or Color(0, 125, 100)
clr.bright = clr.bright or Color(5, 150, 125)
clr.dark = clr.dark or Color(0, 80, 65)
clr.dark2 = clr.dark2 or Color(5, 60, 50)

clr.shadow = clr.shadow or Color(0, 0, 0, 25)
clr.dsb = clr.dsb or Color(100, 100, 100, 100)
clr.hvr = clr.hvr or Color(0, 0, 0, 80)

clr.white = clr.white or Color(200, 200, 200)

surface.CreateFont('lrp-skin.icons', {
	font = 'FontAwesome',
	extended = true,
	size = 13,
	weight = 400,
})

surface.CreateFont('lrp-skin.icons2', {
	font = 'FontAwesome',
	extended = true,
	size = 12,
	weight = 400,
})

surface.CreateFont('lrp-skin.icons3', {
	font = 'FontAwesome',
	extended = true,
	size = 9,
	weight = 400,
})

SKIN = {}
SKIN.PrintName = "LocalRP Skin"
SKIN.Author = "Zgoly"

SKIN.text_dark = Color(255, 255, 255)
SKIN.colTextEntryText = Color(255, 255, 255)
SKIN.colTextEntryTextHighlight = clr.dark
SKIN.colTextEntryTextCursor = Color(255, 255, 255)
SKIN.colTextEntryTextPlaceholder= Color(150, 150, 150)

SKIN.Colours = {}
SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive = color_white
SKIN.Colours.Window.TitleInactive = clr.white

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal = clr.white
SKIN.Colours.Button.Hover = color_white
SKIN.Colours.Button.Down = color_white
SKIN.Colours.Button.Disabled = clr.white

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal = color_white
SKIN.Colours.Tab.Active.Hover = color_white
SKIN.Colours.Tab.Active.Down = color_white
SKIN.Colours.Tab.Active.Disabled = clr.white

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal = clr.white
SKIN.Colours.Tab.Inactive.Hover = color_white
SKIN.Colours.Tab.Inactive.Down = color_white
SKIN.Colours.Tab.Inactive.Disabled = clr.white

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = clr.white
SKIN.Colours.Label.Bright = color_white
SKIN.Colours.Label.Dark = clr.white
SKIN.Colours.Label.Highlight = color_white

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines = clr.white
SKIN.Colours.Tree.Normal = clr.white
SKIN.Colours.Tree.Hover = color_white
SKIN.Colours.Tree.Selected = color_white

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Border = clr.main
SKIN.Colours.Properties.Column_Hover = Color(118,199,255,59)
SKIN.Colours.Properties.Column_Normal = Color(255,255,255,0)
SKIN.Colours.Properties.Column_Selected = Color(118,199,255,255)
SKIN.Colours.Properties.Label_Hover = Color(50,50,50,255)
SKIN.Colours.Properties.Label_Normal = Color(0,0,0,255)
SKIN.Colours.Properties.Label_Selected = Color(0,0,0,255)
SKIN.Colours.Properties.Line_Hover = Color(156,156,156,255)
SKIN.Colours.Properties.Line_Normal = Color(156,156,156,255)
SKIN.Colours.Properties.Line_Selected = Color(156,156,156,255)
SKIN.Colours.Properties.Title = color_white

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header = color_white
SKIN.Colours.Category.Header_Closed = clr.white
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text = clr.white
SKIN.Colours.Category.Line.Text_Hover = color_white
SKIN.Colours.Category.Line.Text_Selected = color_white
SKIN.Colours.Category.Line.Button = color_transparent
SKIN.Colours.Category.Line.Button_Hover = clr.main
SKIN.Colours.Category.Line.Button_Selected = clr.main
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text = clr.white
SKIN.Colours.Category.LineAlt.Text_Hover = color_white
SKIN.Colours.Category.LineAlt.Text_Selected = color_white
SKIN.Colours.Category.LineAlt.Button = color_transparent
SKIN.Colours.Category.LineAlt.Button_Hover = clr.main
SKIN.Colours.Category.LineAlt.Button_Selected = clr.main

SKIN.Colours.TooltipText = clr.white

function SKIN:PaintPanel(pnl, w, h)
	if not pnl.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, clr.dark2)
end

function SKIN:PaintFrame(pnl, w, h)
	local old = DisableClipping(true)
	for i = 1, 12 do
		draw.RoundedBox(8 + i, -i, -i, w + i *  2, h + i * 2, clr.shadow)
	end
	DisableClipping(old)
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
end

function SKIN:PaintButton(pnl, w, h)
	if not pnl.m_bBackground then return end
	
	local off = h > 20 and 2 or 1
	if pnl.Depressed then
		draw.RoundedBox(8, 0, off, w, h-off, clr.main)
		draw.RoundedBox(8, 0, off, w, h-off, clr.hvr)
	else
		draw.RoundedBox(8, 0, 0, w, h, Color(clr.main.r * 0.75, clr.main.g * 0.75, clr.main.b * 0.75, 255))
		draw.RoundedBox(8, 0, 0, w, h-off, clr.main)
		if pnl.Disabled then
			draw.RoundedBox(8, 0, 0, w, h, clr.dsb)
		elseif pnl.Hovered then
			draw.RoundedBox(8, 0, 0, w, h-off, clr.hvr)
		end
	end
end

function SKIN:PaintCheckBox(pnl, w, h)
    local bgColor = clr.main
	local color = color_white

    if pnl:GetDisabled() then
        bgColor = clr.dsb
		color = clr.white
    end

    draw.RoundedBox(w / 3, 0, 0, w - 1, h - 1, bgColor)

    if pnl:GetChecked() and not pnl:GetDisabled() then
		draw.SimpleText("a", "Marlett", w / 2 - 1, h / 2 - 1, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function SKIN:PaintExpandButton(pnl, w, h)
	if pnl:GetExpanded() then
		draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons', w/2, h/2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(utf8.char(0xf056), 'lrp-skin.icons', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons', w/2, h/2, clr.dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(utf8.char(0xf055), 'lrp-skin.icons', w/2, h/2, Color(255, 255, 255, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintTextEntry(pnl, w, h)
	if pnl.m_bBackground then
		if pnl:GetDisabled() then
			draw.RoundedBox(8, 0, 0, w, h, clr.dsb)
		else
			draw.RoundedBox(8, 0, 0, w, h, clr.bright)
			if pnl:HasFocus() then
				draw.RoundedBox(8, 0, 0, w, h, clr.hvr)
			end
		end
	end
	if pnl.GetPlaceholderText and pnl.GetPlaceholderColor and pnl:GetPlaceholderText() and pnl:GetPlaceholderText():Trim() ~= "" and pnl:GetPlaceholderColor() and (not pnl:GetText() or pnl:GetText() == "") then
		local oldText = pnl:GetText()
		local str = pnl:GetPlaceholderText()
		if str:StartWith("#") then str = str:sub(2) end
		str = language.GetPhrase(str)
		pnl:SetText(str)
		pnl:DrawTextEntryText(pnl:GetPlaceholderColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
		pnl:SetText(oldText)
		return
	end
	pnl:DrawTextEntryText(pnl:GetTextColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
end

function SKIN:PaintMenu(pnl, w, h)
	local old = DisableClipping(true)
	for i = 1, 8 do
		draw.RoundedBox(8 + i, -i, -i, w + i *  2, h + i * 2, clr.shadow)
	end
	DisableClipping(old)
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
end

function SKIN:PaintMenuSpacer(pnl, w, h)
	surface.SetDrawColor(Color(0, 0, 0, 100))
	pnl:SetTall(4)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintMenuOption(pnl, w, h)
	if pnl.m_bBackground and (pnl.Hovered or pnl.Highlight) then
		draw.RoundedBox(8, 2, 2, w - 4, h - 4, clr.main)
	end
	if pnl:GetChecked() then
		draw.SimpleText("a", "Marlett", h / 1.5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function SKIN:PaintMenuRightArrow( pnl, w, h )
	draw.SimpleText(utf8.char(0xf054), 'lrp-skin.icons3', w-5, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintMenuBar(pnl, w, h)
	surface.SetDrawColor(clr.dark)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintPropertySheet(pnl, w, h)
	local ActiveTab = pnl:GetActiveTab()
	local Offset = 0
	if ActiveTab then
		Offset = ActiveTab:GetTall() - 8
	end
	draw.RoundedBox(8, 0, Offset, w, h - Offset, clr.dark2)
end

function SKIN:PaintTab(pnl, w, h)
	local step = 8
	local tabScroller = pnl:GetParent():GetParent()
	tabScroller:SetOverlap(-5)
	tabScroller:DockMargin(16, 0, 16, 0)
	if pnl:IsActive() then
		draw.RoundedBoxEx(8, 0, 0, w, h - step, clr.main, true, true)
		surface.SetMaterial(Material("gui/gradient_down"))
		surface.SetDrawColor(clr.main)
		surface.DrawTexturedRect(0, h - step, w, step)
		return
	end
	draw.RoundedBoxEx(8, 0, 0, w, h, clr.dark2, true, true)
end

function SKIN:PaintWindowCloseButton(pnl, w, h)
	if pnl.Disabled then return end

	if pnl.Depressed then
		draw.RoundedBox(8, w/2-8, h/2-7, 16, 16, clr.bright)
		if pnl.Hovered then
			draw.SimpleText(utf8.char(0xf00d), 'lrp-skin.icons', w / 2, h / 2, Color(0,0,0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		draw.RoundedBox(8, w/2-8, h/2-7, 16, 16, Color(clr.bright.r * 0.75, clr.bright.g * 0.75, clr.bright.b * 0.75, 255))
		draw.RoundedBox(8, w/2-8, h/2-8, 16, 16, clr.bright)
		if pnl.Hovered then
			draw.SimpleText(utf8.char(0xf00d), 'lrp-skin.icons', w / 2, h / 2-1, Color(0,0,0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

function SKIN:PaintWindowMaximizeButton(pnl, w, h) end
function SKIN:PaintWindowMinimizeButton(pnl, w, h) end

function SKIN:PaintVScrollBar( pnl, w, h )
	draw.RoundedBox(4, w/2-2, w+3, 4, h-6 - w*2, Color(255, 255, 255, 50))
end

function SKIN:PaintScrollBarGrip(pnl, w, h)
	draw.RoundedBox(4, w/2-4, 0, 8, h, clr.bright)

	if pnl:GetDisabled() then
		return draw.RoundedBox(4, w/2-4, 0, 8, h, clr.dsb)
	end

	if pnl.Depressed then
		return draw.RoundedBox(4, w/2-4, 0, 8, h, clr.hvr)
	end

	if pnl.Hovered then
		return draw.RoundedBox(4, w/2-4, 0, 8, h, clr.hvr)
	end
end

function SKIN:PaintButtonDown( pnl, w, h )

	if not pnl.m_bBackground or pnl:GetDisabled() then return end

	local col = Color(255, 255, 255, 50)
	if pnl.Hovered or pnl.Depressed or pnl:IsSelected() then
		col.a = 255
	end

	draw.SimpleText(utf8.char(0xf078), 'lrp-skin.icons2', w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

function SKIN:PaintButtonUp( pnl, w, h )

	if not pnl.m_bBackground or pnl:GetDisabled() then return end

	local col = Color(255, 255, 255, 50)
	if pnl.Hovered or pnl.Depressed or pnl:IsSelected() then
		col.a = 255
	end

	draw.SimpleText(utf8.char(0xf077), 'lrp-skin.icons2', w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

function SKIN:PaintButtonLeft( pnl, w, h )
	if not pnl.m_bBackground or pnl:GetDisabled() then return end

	local col = Color(255, 255, 255, 50)
	if pnl.Hovered or pnl.Depressed or pnl:IsSelected() then
		col.a = 255
	end

	draw.SimpleText(utf8.char(0xf053), 'lrp-skin.icons2', w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintButtonRight( pnl, w, h )
	if not pnl.m_bBackground or pnl:GetDisabled() then return end

	local col = Color(255, 255, 255, 50)
	if pnl.Hovered or pnl.Depressed or pnl:IsSelected() then
		col.a = 255
	end

	draw.SimpleText(utf8.char(0xf054), 'lrp-skin.icons2', w/2, h/2-1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintComboDownArrow(pnl, w, h)
	local color = clr.white
	local text = utf8.char(0xf078)

	if pnl.ComboBox.Depressed or pnl:HasFocus() or pnl.ComboBox:IsMenuOpen() then
		color = color_white
		text = utf8.char(0xf077)
	elseif pnl.ComboBox.Hovered then
		color = color_white
	end

	draw.SimpleText(text, 'lrp-skin.icons', w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintComboBox( pnl, w, h )
	draw.RoundedBox(8, 0, 0, w, h, clr.bright)
	if pnl:GetDisabled() then
		draw.RoundedBox(8, 0, 0, w, h, Color(255,255,255, 100))
	elseif pnl:HasFocus() or pnl.Depressed or pnl:IsMenuOpen() or pnl.Hovered then
		draw.RoundedBox(8, 0, 0, w, h, clr.hvr)
	end
end

function SKIN:PaintListBox(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.main)
end

function SKIN:PaintNumberUp(pnl, w, h)
	local col = Color(255, 255, 255, 150)
	if pnl.Depressed or pnl.Hovered then
		col.a = 255
	end
	draw.SimpleText(utf8.char(0xf077), 'lrp-skin.icons3', w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintNumberDown(pnl, w, h)
	local col = Color(255, 255, 255, 150)
	if pnl.Depressed or pnl.Hovered then
		col.a = 255
	end
	draw.SimpleText(utf8.char(0xf078), 'lrp-skin.icons3', w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTree(pnl, w, h)
	if not pnl.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
end

function SKIN:PaintTreeNode( pnl, w, h )
	if not pnl.m_bDrawLines then return end

	surface.SetDrawColor(clr.main)
	if ( pnl.m_bLastChild ) then
		surface.DrawRect( 9, 0, 2, 9 )
		surface.DrawRect( 10, 7, 6, 2 )
	else
		surface.DrawRect( 9, 0, 2, h )
		surface.DrawRect( 10, 7, 6, 2 )
	end
end

function SKIN:PaintTreeNodeButton(pnl, w, h)
	if not pnl.m_bSelected then return end
	local w, _ = pnl:GetTextSize()
	draw.RoundedBox(8, 16, 0, w + 32, h, clr.main)
end

function SKIN:PaintSelection(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.main)
end

function SKIN:PaintSliderKnob(pnl, w, h)
	local col = Color(255, 255, 255, 170)
	if pnl.Hovered or pnl.Depressed then
		col.a = 255
	elseif pnl:GetDisabled() then
		col = clr.dsb
	end

	draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons2', w / 2, h / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function PaintNotches(x, y, w, h, num)
	if not num then return end
	local space = w / num
	for i = 0, num do
		surface.DrawRect(x + i * space, y, 2, 6)
	end
end

function SKIN:PaintNumSlider(pnl, w, h)
	surface.SetDrawColor(clr.main)
	surface.DrawRect(8, h / 2 - 1, w - 15, 2)
	PaintNotches(8, h / 2 - 1, w - 16, 1, pnl.m_iNotches)
end

function SKIN:PaintProgress(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
	draw.RoundedBox(8, 0, 0, w * pnl:GetFraction(), h, clr.bright)
end

function SKIN:PaintCollapsibleCategory(pnl, w, h)
	pnl:DockMargin(2, 2, 2, 2)
	draw.RoundedBox(8, 0, 0, w, pnl:GetHeaderHeight(), clr.bright)
end

function SKIN:PaintCategoryList(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
end

function SKIN:PaintCategoryButton(pnl, w, h)
	pnl:SetTall(24)
	if pnl.AltLine then
		if pnl.m_bSelected then
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.main)
		elseif pnl.Depressed then
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.main)
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.hvr)
		elseif ( pnl.Hovered ) then
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.hvr)
		else
			draw.RoundedBox(8, 0, 2, w, h - 4, Color(255, 255, 255, 1))
		end
	else
		if pnl.m_bSelected then
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.main)
		elseif pnl.Depressed then
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.main)
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.hvr)
		elseif ( pnl.Hovered ) then
			draw.RoundedBox(8, 0, 2, w, h - 4, clr.hvr)
		end
	end
end

function SKIN:PaintListViewLine(pnl, w, h)
	if pnl:IsSelected() then
		draw.RoundedBox(8, 2, 0, w - 4, h, clr.main)
	elseif pnl.Hovered then
		draw.RoundedBox(8, 2, 0, w - 4, h, clr.hvr)
	elseif pnl.m_bAlt then
		draw.RoundedBox(8, 2, 0, w - 4, h, Color(0, 0, 0, 20))
	end
end

function SKIN:PaintListView(pnl, w, h)
	if not pnl.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, clr.dark2)
end

function SKIN:PaintTooltip( pnl, w, h )
	local old = DisableClipping(true)
	
	for i = 1, 8 do
		draw.RoundedBox(8 + i, -i - 3, -i, w + i *  2 + 6, h + i * 2, clr.shadow)
	end
	draw.RoundedBox(8, -3, 0, w + 6, h, clr.dark)
	draw.NoTexture()
	surface.DrawPoly({
		{x = w/2 - 5, y = h},
		{x = w/2 + 5, y = h},
		{x = w/2, y = h + 5},
	})

	DisableClipping(old)
end

derma.DefineSkin("localrp_skin", "LocalRP Skin", SKIN)