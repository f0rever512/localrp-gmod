CreateClientConVar("lrp_chatsize_w", "65", true, false)
CreateClientConVar("lrp_chatsize_h", "35", true, false)
CreateClientConVar("lrp_chattitle", "1", true, false)

surface.CreateFont("ChatFontTitle",{
	size = 26,
	weight = 400,
	font = "Calibri",
	extended = true,
	antialias = true,
})

-- surface.CreateFont("ChatFontType",{
-- 	size = 20,
-- 	weight = 400,
-- 	font = "Calibri",
-- 	extended = true,
-- 	antialias = true,
-- })

surface.CreateFont("ChatFontEntry",{
	size = 24,
	weight = 400,
	font = "Calibri",
	extended = true,
	antialias = true,
})

surface.CreateFont("ChatFontSh",{
	size = 24,
	weight = 400,
	font = "Calibri",
	extended = true,
	antialias = true,
	shadow = true
})

lrpchat = {}

concommand.Add( "lrp_updatechat", function()
	chatsize_w = GetConVarNumber("lrp_chatsize_w") * 10
	chatsize_h = GetConVarNumber("lrp_chatsize_h") * 10
	lrpchat.buildBox()
end)

concommand.Add( "lrp_defaultchat", function()
	GetConVar("lrp_chatsize_w"):SetInt( 65 )
	GetConVar("lrp_chatsize_h"):SetInt( 35 )
	GetConVar("lrp_chattitle"):SetInt( 1 )
	chatsize_w = GetConVarNumber("lrp_chatsize_w") * 10
	chatsize_h = GetConVarNumber("lrp_chatsize_h") * 10
	lrpchat.buildBox()
end)

chatsize_w = GetConVarNumber("lrp_chatsize_w") * 10
chatsize_h = GetConVarNumber("lrp_chatsize_h") * 10

function lrpchat.buildBox()
	local mainclr = Color(0, 80, 65, 200)
	local sideclr = Color(0, 0, 0, 125)
	lrpchat.frame = vgui.Create("DFrame")
	lrpchat.frame:SetSize( chatsize_w, chatsize_h ) --GetConVarNumber("lrp_chatsize_w"), GetConVarNumber("lrp_chatsize_h")
	lrpchat.frame:SetTitle("")
	lrpchat.frame:SetSizable(false)
	lrpchat.frame:ShowCloseButton( false )
	lrpchat.frame:SetDraggable( true )
	lrpchat.frame:SetPos( 10, ScrH() * .5 - lrpchat.frame:GetTall() / 2)
	lrpchat.frame.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, mainclr )
		if GetConVarNumber("lrp_chattitle") == 1 then
			draw.SimpleText("LocalRP - Chatbox","ChatFontTitle", 8, 2, Color(255, 255, 255)) --GetHostName() / lrpchat.frame:GetSize() * .45
		end
	end
	lrpchat.oldPaint = lrpchat.frame.Paint
	lrpchat.btn = vgui.Create( "DImageButton", lrpchat.frame )
	lrpchat.btn:SetPos( chatsize_w - 28, 3 )
	lrpchat.btn:SetColor(Color(0, 100, 80, 250))
	lrpchat.btn:SetImage( "icon16/cross.png" )
	lrpchat.btn:SetSize(24, 24)
	lrpchat.btn.DoClick = function()
		lrpchat.hideBox()
	end
	lrpchat.entry = vgui.Create("DTextEntry", lrpchat.frame)
	lrpchat.entry:SetTextColor( color_white )
	lrpchat.entry:SetPos( 45, lrpchat.frame:GetTall() - lrpchat.entry:GetTall() - 5 )
	lrpchat.entry:SetFont("ChatFontEntry")
	lrpchat.entry:SetDrawBorder( false )
	lrpchat.entry:SetDrawBackground( false )
	lrpchat.entry:SetCursorColor( Color(255, 255, 255, 75) )
	lrpchat.entry:SetHighlightColor( Color(15, 95, 145) )
	lrpchat.entry:SetSize( lrpchat.frame:GetWide() - 50, 20 )
	--lrpchat.entry:SetPlaceholderText( ' Печатай' )
	lrpchat.entry.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, sideclr )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	lrpchat.entry.OnTextChanged = function( self )
		if self and self.GetText then 
			gamemode.Call( "ChatTextChanged", self:GetText() or "" )
		end
	end

	lrpchat.entry.OnKeyCodeTyped = function( self, code )
		local types = {"", "teamchat", "console",/*"ooc"*/}

		if code == KEY_ESCAPE then

			lrpchat.hideBox()
			gui.HideGameUI()

		elseif code == KEY_TAB then
			
			lrpchat.TypeSelector = (lrpchat.TypeSelector and lrpchat.TypeSelector + 1) or 1
			
			if lrpchat.TypeSelector > 3 then lrpchat.TypeSelector = 1 end
			if lrpchat.TypeSelector < 1 then lrpchat.TypeSelector = 3 end
			
			lrpchat.ChatType = types[lrpchat.TypeSelector]
			timer.Simple(0.001, function() lrpchat.entry:RequestFocus() end)

		elseif code == KEY_ENTER then
			-- Replicate the client pressing enter
			
			if string.Trim( self:GetText() ) != "" then
				local ply = LocalPlayer()
				if lrpchat.ChatType == types[2] then
					print('(Team)', ply:GetName() .. ': ' .. self:GetText())
					ply:ConCommand("say_team \"" .. (self:GetText() or "") .. "\"")
				elseif lrpchat.ChatType == types[3] then
					ply:ConCommand(self:GetText() or "")
				elseif lrpchat.ChatType == types[4] then
					ply:ConCommand("say \"/// " .. self:GetText() .. "\"")
				else
					print(ply:GetName() .. ': ' .. self:GetText())
					ply:ConCommand("say \"" .. self:GetText() .. "\"")
				end
			end

			lrpchat.TypeSelector = 1
			lrpchat.hideBox()
		end
	end

	lrpchat.chatLog = vgui.Create("RichText", lrpchat.frame) 
	lrpchat.chatLog:SetSize( lrpchat.frame:GetWide() - 10, lrpchat.frame:GetTall() - 60 )
	lrpchat.chatLog:SetPos( 5, 30 )
	lrpchat.chatLog.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, sideclr )
	end
	lrpchat.chatLog.Think = function( self )
		if lrpchat.lastMessage then
			local elapsedTime = CurTime() - lrpchat.lastMessage
			local fadeOutTime = 2	
			local alpha = 255
	
			if elapsedTime > 5 then
				alpha = Lerp((elapsedTime - 5) / fadeOutTime, 255, 0)
				if alpha <= 0 then
					self:SetVisible(false)
					return
				end
			end

			self:SetAlpha(alpha)
			self:SetVisible(true)
		end
	end
	lrpchat.chatLog.PerformLayout = function( self )
		self:SetFontInternal("ChatFontSh")
		self:SetFGColor( color_white )
	end
	lrpchat.oldPaint2 = lrpchat.chatLog.Paint
	
	local text = "Чат :"

	local say = vgui.Create("DLabel", lrpchat.frame)
	say:SetText("")
	-- surface.SetFont( "ChatFontType")
	-- local w, h = surface.GetTextSize( text )
	
	-- say.Paint = function( self, w, h )
	-- 	draw.RoundedBoxEx( 8, 0, 0, w, h, sideclr, true, false, true, false )
	-- 	draw.DrawText( text, "ChatFontType", 5, -1, color_white )
	-- end

	say.Think = function( self )
		local types = {"", "teamchat", "console",/*"ooc"*/}
		local s = {}

		if lrpchat.ChatType == types[2] then 
			text = "Командный чат :"
		elseif lrpchat.ChatType == types[3] then
			text = "Console :"
		//elseif lrpchat.ChatType == types[4] then
		//	text = "OOC :"
		else
			text = "Чат :"
			s.pw = 5
			s.sw = lrpchat.frame:GetWide() - 10
		end

		if s then
			if not s.pw then s.pw = 5 end
			if not s.sw then s.sw = lrpchat.frame:GetWide() - 10 end
		end

		-- local w, h = surface.GetTextSize( text )
		-- self:SetSize( w + 5, 20 )
		-- self:SetPos( 5, lrpchat.frame:GetTall() - lrpchat.entry:GetTall() - 5 )

		lrpchat.entry:SetPlaceholderColor( Color(255, 255, 255, 100) )
		lrpchat.entry:SetPlaceholderText(text)
		lrpchat.entry:SetSize( s.sw, 20 )
		lrpchat.entry:SetPos( s.pw, lrpchat.frame:GetTall() - lrpchat.entry:GetTall() - 5 )
	end	
	
	lrpchat.hideBox()
end

--// Hides the chat box but not the messages
function lrpchat.hideBox()
	lrpchat.frame.Paint = function() end
	lrpchat.chatLog.Paint = function() end
	
	lrpchat.chatLog:SetVerticalScrollbarEnabled( false )
	lrpchat.chatLog:GotoTextEnd()
	
	lrpchat.lastMessage = lrpchat.lastMessage or CurTime() - 12
	
	-- Hide the chatbox except the log
	local children = lrpchat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == lrpchat.frame.btnMaxim or pnl == lrpchat.frame.btnClose or pnl == lrpchat.frame.btnMinim then continue end
		
		if pnl != lrpchat.chatLog then
			pnl:SetVisible( false )
		end
	end
	
	-- Give the player control again
	lrpchat.frame:SetMouseInputEnabled( false )
	lrpchat.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )
	gamemode.Call("FinishChat")
	lrpchat.entry:SetText( "" )
	gamemode.Call( "ChatTextChanged", "" )
end
function lrpchat.showBox()
	lrpchat.frame.Paint = lrpchat.oldPaint
	lrpchat.chatLog.Paint = lrpchat.oldPaint2
	lrpchat.chatLog:SetAlpha(255)
	
	lrpchat.chatLog:SetVerticalScrollbarEnabled( true )
	lrpchat.lastMessage = nil
	local children = lrpchat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == lrpchat.frame.btnMaxim or pnl == lrpchat.frame.btnClose or pnl == lrpchat.frame.btnMinim then continue end
		
		pnl:SetVisible( true )
	end
	lrpchat.frame:MakePopup()
	lrpchat.entry:RequestFocus()
	gamemode.Call("StartChat")
end
local oldAddText = chat.AddText
function chat.AddText(...)
	if not lrpchat.chatLog then
		lrpchat.buildBox()
	end
	
	local msg = {}
	
	-- Iterate through the strings and colors
	for _, obj in pairs( {...} ) do
		if type(obj) == "table" then
			lrpchat.chatLog:InsertColorChange( obj.r, obj.g, obj.b, obj.a ) --lrpchat.chatLog:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
			table.insert( msg, Color(obj.r, obj.g, obj.b, obj.a) )
		elseif type(obj) == "string"  then
			lrpchat.chatLog:AppendText( obj )
			table.insert( msg, obj )
		elseif obj:IsPlayer() then
			local ply = obj
			local col = GAMEMODE:GetTeamColor( obj )
			lrpchat.chatLog:InsertColorChange( col.r, col.g, col.b, 255 )
			lrpchat.chatLog:AppendText( obj:Nick() )
			table.insert( msg, obj:Nick() )
		end
	end
	lrpchat.chatLog:AppendText("\n")
	
	lrpchat.chatLog:SetVisible( true )
	lrpchat.lastMessage = CurTime()
--	oldAddText(unpack(msg))
end
hook.Remove( "ChatText", "lrp_joinleave")
hook.Add( "ChatText", "lrp_joinleave", function( index, name, text, type )
	if not lrpchat.chatLog then
		lrpchat.buildBox()
	end
	
	if type != "chat" then
		lrpchat.chatLog:InsertColorChange( 255, 200, 40, 255 )
		lrpchat.chatLog:AppendText( text.."\n" )
		lrpchat.chatLog:SetVisible( true )
		lrpchat.lastMessage = CurTime()
		return true
	end
end)
hook.Remove("PlayerBindPress", "lrp_hijackbind")
hook.Add("PlayerBindPress", "lrp_hijackbind", function(ply, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		if bind == "messagemode2" then 
			lrpchat.ChatType = "teamchat"
		else
			lrpchat.ChatType = ""
		end
		
		if IsValid( lrpchat.frame ) then
			lrpchat.showBox()
		else
			lrpchat.buildBox()
			lrpchat.showBox()
		end
		return true
	end
end)
hook.Remove("HUDShouldDraw", "lrp_hidedefault")
hook.Add("HUDShouldDraw", "lrp_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)
local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
	return lrpchat.frame:GetPos()
end

function chat.GetChatBoxSize()
	return lrpchat.frame:GetSize()
end

chat.Open = lrpchat.showBox
function chat.Close(...) 
	if IsValid( lrpchat.frame ) then 
		lrpchat.hideBox(...)
	else
		lrpchat.buildBox()
		lrpchat.showBox()
	end
end