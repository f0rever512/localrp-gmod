local GWEN = GWEN
local DisableClipping = DisableClipping
local utf8 = utf8
local language = language
local Material = Material
local derma = derma
local hook = hook
local surface = surface
local draw = draw
local Color = Color
local color_white = color_white
local color_transparent = color_transparent

local clr = {
    main = Color(0, 125, 100),
    bright = Color(5, 150, 125),
    dark = Color(0, 80, 65),
    dark2 = Color(5, 60, 50),

    select = Color(20, 180, 110),
	selectDark = Color(10, 135, 80),
	closeBtn = Color(20, 210, 180),
	pressBtn = Color(5, 100, 80),

	white = Color(200, 200, 200),
	shadow = Color(0, 0, 0, 10),
	dsb = Color(90, 90, 90),
    hvr = Color(0, 0, 0, 80),
}

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
	size = 14,
	weight = 400,
})

surface.CreateFont('lrp-skin.iconSmall', {
	font = 'FontAwesome',
	extended = true,
	size = 10,
	weight = 400,
})

local SKIN = {}

SKIN.PrintName = 'LocalRP Derma Skin'
SKIN.Author = 'Garry Newman & Zgoly & chelog & forever512'

SKIN.GwenTexture = Material('gwenskin/GModDefault.png')

SKIN.text_dark = color_white
SKIN.colTextEntryText = color_white
SKIN.colTextEntryTextHighlight = Color(20, 105, 160, 220)
SKIN.colTextEntryTextCursor = color_white
SKIN.colTextEntryTextPlaceholder= Color(220, 220, 220)

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
SKIN.Colours.Tree.Lines = Color(255, 255, 255, 15)
SKIN.Colours.Tree.Normal = Color(220, 220, 220)
SKIN.Colours.Tree.Hover = color_white
SKIN.Colours.Tree.Selected = color_white

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Title = color_white
SKIN.Colours.Properties.Border = clr.main
SKIN.Colours.Properties.Column_Hover = Color(118,199,255,59)
SKIN.Colours.Properties.Column_Normal = Color(255,255,255,0)
SKIN.Colours.Properties.Column_Selected = Color(118,199,255,255)
SKIN.Colours.Properties.Column_Disabled	= clr.white
SKIN.Colours.Properties.Label_Hover = Color(50,50,50,255)
SKIN.Colours.Properties.Label_Normal = Color(0,0,0,255)
SKIN.Colours.Properties.Label_Selected = Color(0,0,0,255)
SKIN.Colours.Properties.Label_Disabled = Color(50, 50, 50, 200)
SKIN.Colours.Properties.Line_Hover = Color(156,156,156,255)
SKIN.Colours.Properties.Line_Normal = Color(156,156,156,255)
SKIN.Colours.Properties.Line_Selected = Color(156,156,156,255)

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

SKIN.Colours.TooltipText = color_white

SKIN.tex = {}

SKIN.tex.RadioButton_Checked		= GWEN.CreateTextureNormal( 448, 64, 15, 15, SKIN.GwenTexture )
SKIN.tex.RadioButton				= GWEN.CreateTextureNormal( 464, 64, 15, 15, SKIN.GwenTexture )
SKIN.tex.RadioButtonD_Checked		= GWEN.CreateTextureNormal( 448, 80, 15, 15, SKIN.GwenTexture )
SKIN.tex.RadioButtonD				= GWEN.CreateTextureNormal( 464, 80, 15, 15, SKIN.GwenTexture )

local function paintShadow(w, h)

	local old = DisableClipping(true)

	for i = 1, 4 do
		draw.RoundedBox(8 + i, -i, -i, w+i*2, h+i*2, clr.shadow)
	end

	DisableClipping(old)

end

function SKIN:PaintPanel(pnl, w, h)

	if not pnl.m_bBackground then return end

	draw.RoundedBox(8, 0, 0, w, h, clr.dark2)

end

function SKIN:PaintFrame(pnl, w, h)

	if pnl.m_bPaintShadow then
		paintShadow(w, h)
	end

	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
	
end

function SKIN:PaintButton(pnl, w, h)

	if not pnl.m_bBackground then return end

	if pnl:GetDisabled() then
		draw.RoundedBox(8, 0, 0, w, h, clr.dsb)
	else
		if pnl.Depressed then
			draw.RoundedBox(8, 0, 0, w, h, clr.pressBtn)
		else
			if pnl.Hovered then
				draw.RoundedBox(8, 0, 0, w, h, clr.bright)
			else
				draw.RoundedBox(8, 0, 0, w, h, clr.main)
			end
		end
	end
	
end

function SKIN:PaintCheckBox(pnl, w, h)

	if pnl:GetDisabled() then
		draw.RoundedBox(6, 0, 0, w, h, clr.dsb)
	else
		if pnl:IsHovered() then
			draw.RoundedBox(6, 0, 0, w, h, clr.bright)
		else
			draw.RoundedBox(6, 0, 0, w, h, clr.main)
		end

		if pnl:GetChecked() then
			draw.SimpleText(utf8.char(0xf00c), 'lrp-skin.iconSmall', w/2, h/2-1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
end

function SKIN:PaintExpandButton(pnl, w, h)

	draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons', w/2, h/2, clr.dark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if pnl:GetExpanded() then
		draw.SimpleText(utf8.char(0xf056), 'lrp-skin.icons', w/2, h/2, clr.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(utf8.char(0xf055), 'lrp-skin.icons', w/2, h/2, Color(255, 255, 255, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
end

function SKIN:PaintTextEntry(pnl, w, h)

	if pnl.m_bBackground then
		if pnl:GetDisabled() then
			draw.RoundedBox(8, 0, 0, w, h, clr.dsb)
		else
			draw.RoundedBox(8, 0, 0, w, h, pnl:HasFocus() and clr.selectDark or clr.bright)
		end
	end

	if pnl.GetPlaceholderText and pnl.GetPlaceholderColor and pnl:GetPlaceholderText() and pnl:GetPlaceholderText():Trim() ~= '' and pnl:GetPlaceholderColor() and (not pnl:GetText() or pnl:GetText() == '') then
		local oldText = pnl:GetText()
		local str = pnl:GetPlaceholderText()
		if str:StartsWith('#') then str = str:sub(2) end
		str = language.GetPhrase(str)
		
		pnl:SetText(str)
		pnl:DrawTextEntryText(pnl:GetPlaceholderColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())
		pnl:SetText(oldText)

		return
	end

	pnl:DrawTextEntryText(pnl:GetTextColor(), pnl:GetHighlightColor(), pnl:GetCursorColor())

end

function SKIN:PaintMenu(pnl, w, h)

	paintShadow(w, h)

	draw.RoundedBox(8, 0, 0, w, h, clr.dark)

end

function SKIN:PaintMenuSpacer(pnl, w, h)
	pnl:SetTall(2)
	
	surface.SetDrawColor(Color(0, 0, 0, 100))
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintMenuOption(pnl, w, h)

	if pnl.m_bBackground and (pnl.Hovered or pnl.Highlight) then
		draw.RoundedBox(8, 1, 1, w - 2, h - 2, clr.selectDark)
	end
	
	if pnl:GetRadio() then
		if pnl:GetChecked() then
			if pnl:GetDisabled() then
				self.tex.RadioButtonD_Checked(4, h / 2 - 8, 15, 15)
			else
				self.tex.RadioButton_Checked(4, h / 2 - 8, 15, 15)
			end
		else
			if pnl:GetDisabled() then
				self.tex.RadioButtonD(4, h / 2 - 8, 15, 15)
			else
				self.tex.RadioButton(4, h / 2 - 8, 15, 15)
			end
		end
	else
		if pnl:GetChecked() then
			draw.SimpleText(utf8.char(0xf00c), 'lrp-skin.icons3', 12, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
end

function SKIN:PaintMenuRightArrow( pnl, w, h )

	draw.SimpleText(utf8.char(0xf054), 'lrp-skin.iconSmall', w-5, h/2, clr.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
end

function SKIN:PaintMenuBar(pnl, w, h)
	surface.SetDrawColor(clr.dark)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintPropertySheet(pnl, w, h)

	local tab = pnl:GetActiveTab()
	local offset = tab and tab:GetTall() - 8 or 0
	
	draw.RoundedBox(8, 0, offset, w, h-offset, clr.dark2)

end

function SKIN:PaintTab(pnl, w, h)
	local tabScroller = pnl:GetParent():GetParent()
	
	tabScroller:SetOverlap(-4)
	tabScroller:DockMargin(16, 0, 16, 0)
	
	if pnl:IsActive() then
		draw.RoundedBoxEx(8, 0, 0, w, h-8, clr.dark2, true, true)
	else
		draw.RoundedBoxEx(8, 0, 0, w, h, Color(5, 30, 20), true, true)
	end
end

function SKIN:PaintWindowCloseButton(pnl, w, h)

	if pnl.Disabled then return end

	draw.RoundedBox(8, w/2-8, h/2-8, 16, 16, clr.closeBtn)

	draw.SimpleText(utf8.char(0xf00d), 'lrp-skin.icons', w/2, h/2-1,
	Color(0, 0, 0, (pnl.Hovered or pnl.Depressed) and 180 or 140), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

function SKIN:PaintWindowMaximizeButton(pnl, w, h) end
function SKIN:PaintWindowMinimizeButton(pnl, w, h) end

function SKIN:PaintVScrollBar( pnl, w, h )
	draw.RoundedBox(4, w/2-2, w+3, 4, h-6 - w*2, Color(255, 255, 255, 50))
end

function SKIN:PaintScrollBarGrip(pnl, w, h)

	if pnl:GetDisabled() then
		draw.RoundedBox(4, w/2-4, 0, 8, h, clr.dsb)
	else
		if pnl.Hovered or pnl.Depressed then
			draw.RoundedBox(4, w/2-4, 0, 8, h, clr.select)
		else
			draw.RoundedBox(4, w/2-4, 0, 8, h, clr.bright)
		end
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

	if pnl:HasFocus() or pnl.ComboBox:IsMenuOpen() then
		color = color_white
		text = utf8.char(0xf077)
	elseif pnl.ComboBox.Hovered then
		color = color_white
	end

	draw.SimpleText(text, 'lrp-skin.icons', w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintComboBox( pnl, w, h )

	if pnl:GetDisabled() then
		draw.RoundedBox(8, 0, 0, w, h, clr.dsb)
	else
		if pnl:IsHovered() or pnl:HasFocus() or pnl.Depressed or pnl:IsMenuOpen() then
			draw.RoundedBox(8, 0, 0, w, h, clr.bright)
		else
			draw.RoundedBox(8, 0, 0, w, h, clr.main)
		end
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
	draw.SimpleText(utf8.char(0xf077), 'lrp-skin.iconSmall', w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintNumberDown(pnl, w, h)
	local col = Color(255, 255, 255, 150)
	if pnl.Depressed or pnl.Hovered then
		col.a = 255
	end
	draw.SimpleText(utf8.char(0xf078), 'lrp-skin.iconSmall', w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTree(pnl, w, h)
	if not pnl.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
end

function SKIN:PaintTreeNode( pnl, w, h )

	if not pnl.m_bDrawLines then return end

	surface.SetDrawColor(self.Colours.Tree.Lines)
	if pnl.m_bLastChild then
		surface.DrawRect( 9, 0, 2, 9 )
		surface.DrawRect( 11, 7, 8, 2 )
	else
		surface.DrawRect( 9, 0, 2, h )
		surface.DrawRect( 11, 7, 8, 2 )
	end

end

function SKIN:PaintTreeNodeButton(pnl, w, h)
	if not pnl.m_bSelected then return end
	
	local w, _ = pnl:GetTextSize()
	draw.RoundedBox(8, 38, 0, w + 6, h, Color(10, 135, 80))
end

function SKIN:PaintSelection(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.selectDark)
end

function SKIN:PaintSliderKnob(pnl, w, h)

	if pnl:GetDisabled() then
		draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons', w/2, h/2, clr.dsb, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		if pnl.Hovered or pnl.Depressed then
			draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(utf8.char(0xf111), 'lrp-skin.icons', w/2, h/2, clr.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
end

local function PaintNotches(x, y, w, h, num)

	if not num then return end

	local space = w / num
	
	for i = 0, num do
		surface.DrawRect(x + i * space, y, 2, h)
	end

end

function SKIN:PaintNumSlider(pnl, w, h)

	surface.SetDrawColor(clr.main)
	surface.DrawRect(8, h / 2 - 1, w - 14, 2)

	PaintNotches(8, h / 2 + 1, w - 16, 4, pnl.m_iNotches)
	
end

function SKIN:PaintProgress(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
	draw.RoundedBox(8, 1, 1, w * pnl:GetFraction() - 2, h - 2, clr.bright)
end

function SKIN:PaintCollapsibleCategory(pnl, w, h)
	pnl:DockMargin(2, 2, 2, 0)

	if h <= pnl:GetHeaderHeight() then
		draw.RoundedBox(8, 0, 0, w, pnl:GetHeaderHeight(), clr.main)

		-- Little hack, draw the ComboBox's dropdown arrow to tell the player the category is collapsed and not empty
		if not pnl:GetExpanded() then
			draw.SimpleText(utf8.char(0xf078), 'lrp-skin.iconSmall', w-12, h/2-1, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		draw.RoundedBox(8, 0, 0, w, pnl:GetHeaderHeight(), clr.bright)
	end
end

function SKIN:PaintCategoryList(pnl, w, h)
	draw.RoundedBox(8, 0, 0, w, h, clr.dark)
end

function SKIN:PaintCategoryButton(pnl, w, h)

	pnl:SetTall(20)

	if pnl.Depressed or pnl.m_bSelected then
		draw.RoundedBox(8, 0, 1, w, h-2, clr.selectDark)
	elseif pnl.Hovered then
		draw.RoundedBox(8, 0, 1, w, h-2, clr.hvr)
	elseif pnl.AltLine then
		draw.RoundedBox(8, 0, 1, w, h-2, Color(0, 0, 0, 20))
	end

end

function SKIN:PaintListViewLine(pnl, w, h)

	if pnl:IsSelected() then
		draw.RoundedBox(6, 1, 1, w-2, h-2, clr.selectDark)
	elseif pnl.Hovered then
		draw.RoundedBox(6, 1, 1, w-2, h-2, clr.hvr)
	elseif pnl.m_bAlt then
		draw.RoundedBox(6, 1, 1, w-2, h-2, Color(0, 0, 0, 30))
	end
	
end

function SKIN:PaintListView(pnl, w, h)
	if not pnl.m_bBackground then return end
	draw.RoundedBox(8, 0, 0, w, h, clr.dark2)
end

function SKIN:PaintTooltip( pnl, w, h )

	local old = DisableClipping(true)
	
	for i = 1, 4 do
		draw.RoundedBox(8 + i, -i-3, -i, w+i*2+6, h+i*2, clr.shadow)
	end
	
	draw.RoundedBox(8, -3, 0, w + 6, h, clr.selectDark)
	draw.NoTexture()
	surface.DrawPoly({
		{x = w/2 - 5, y = h},
		{x = w/2 + 5, y = h},
		{x = w/2, y = h + 5},
	})

	DisableClipping(old)

end

derma.DefineSkin('localrp', 'LocalRP Derma Skin', SKIN)

hook.Add('ForceDermaSkin', 'lrp-skin.set', function()
	return 'localrp'
end)