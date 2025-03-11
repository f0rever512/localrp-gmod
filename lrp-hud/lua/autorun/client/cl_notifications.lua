surface.CreateFont("NotifyFont", {
    font = "Calibri",
    size = 25,
    weight = 400,
    antialias = true,
    extended = true,
})

local ScreenPos = ScrH() - 40

local ForegroundColor = Color( 230, 230, 230 )
local BackgroundColor = Color( 0, 0, 0, 225 )

--[[Colors[ type ]
local Colors = {}
Colors[ NOTIFY_GENERIC ] = Color( 52, 73, 94, 100 )
Colors[ NOTIFY_ERROR ] = Color( 192, 57, 43 )
Colors[ NOTIFY_UNDO ] = Color( 41, 128, 185 )
Colors[ NOTIFY_HINT ] = Color( 39, 174, 96 )
Colors[ NOTIFY_CLEANUP ] = Color( 243, 156, 18 )]]

local LoadingColor = Color( 22, 160, 133 )

local Icons = {}
Icons[ NOTIFY_GENERIC ] = Material( "notifications/generic.png" )
Icons[ NOTIFY_ERROR ] = Material( "notifications/error.png" )
Icons[ NOTIFY_UNDO ] = Material( "notifications/undo.png" )
Icons[ NOTIFY_HINT ] = Material( "notifications/hint.png" )
Icons[ NOTIFY_CLEANUP ] = Material( "notifications/cleanup.png" )

local LoadingIcon = Material( "icon16/arrow_rotate_clockwise.png" )

local Notifications = {}

local function DrawNotification( x, y, w, h, text, icon, col, progress )
	draw.RoundedBoxEx( 8, x, y, w, h, BackgroundColor, true, true, true, true )

	if progress then
		draw.RoundedBoxEx( 8, x, y, h + ( w - h ) * progress, h, col, true, false, true, false )
	else
		draw.RoundedBoxEx( 8, x, y, h, h, col, true, false, true, false )
	end

	draw.SimpleText( text, "NotifyFont", x + 30 + 10, y + h / 2, ForegroundColor,
		TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.SetDrawColor( ForegroundColor )
	surface.SetMaterial( icon )

	if progress then
		surface.DrawTexturedRectRotated( x + 16, y + h / 2, 16, 16, -CurTime() * 360 % 360 )
	else
		surface.DrawTexturedRect( x + 7, y + 7, 20, 20 )
	end
end

function notification.AddLegacy( text, type, time )
	surface.SetFont("NotifyFont")

	local w = surface.GetTextSize( text ) + 20 + 32
	local h = 32
	local x = ScrW()
	local y = ScreenPos

	table.insert( Notifications, 1, {
		x = x,
		y = y,
		w = w,
		h = h,

		text = text,
		col = Color(0, 210, 170, 75),
		icon = Icons[ type ],
		time = CurTime() + time,

		progress = nil,
	} )
end

function notification.AddProgress( id, text, frac )
	for k, v in ipairs( Notifications ) do
		if v.id == id then
			v.text = text
			v.progress = frac
			
			return
		end
	end

	surface.SetFont("NotifyFont")

	local w = surface.GetTextSize( text ) + 20 + 32
	local h = 32
	local x = ScrW()
	local y = ScreenPos

	table.insert( Notifications, 1, {
		x = x,
		y = y,
		w = w,
		h = h,

		id = id,
		text = text,
		col = LoadingColor,
		icon = LoadingIcon,
		time = math.huge,

		progress = math.Clamp( frac or 0, 0, 1 ),
	} )	
end

function notification.Kill( id )
	for k, v in ipairs( Notifications ) do
		if v.id == id then v.time = 0 end
	end
end

hook.Add( "HUDPaint", "DrawNotifications", function()
	for k, v in ipairs( Notifications ) do
		DrawNotification( math.floor( v.x ), math.floor( v.y ), v.w, v.h, v.text, v.icon, v.col, v.progress )

		v.x = Lerp( FrameTime() * 10, v.x, v.time > CurTime() and ScrW() - v.w - 8 or ScrW() + 1 )
		v.y = Lerp( FrameTime() * 10, v.y, ScreenPos - ( k - 1 ) * ( v.h + 5 ) )
	end

	for k, v in ipairs( Notifications ) do
		if v.x >= ScrW() and v.time < CurTime() then
			table.remove( Notifications, k )
		end
	end
end )