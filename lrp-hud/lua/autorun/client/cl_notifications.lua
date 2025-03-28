surface.CreateFont('lrpNotify-font', {
    font = "Calibri",
    size = 25,
    weight = 400,
    antialias = true,
    extended = true,
})

local ScreenPos = ScrH() - 40

local colorMain = Color(0, 80, 65)
local colorLoading = Color(0, 125, 100)

local Icons = {}
Icons[ NOTIFY_GENERIC ] = Material( "notifications/generic.png" )
Icons[ NOTIFY_ERROR ] = Material( "notifications/error.png" )
Icons[ NOTIFY_UNDO ] = Material( "notifications/undo.png" )
Icons[ NOTIFY_HINT ] = Material( "notifications/hint.png" )
Icons[ NOTIFY_CLEANUP ] = Material( "notifications/cleanup.png" )

local LoadingIcon = Material( "icon16/arrow_rotate_clockwise.png" )

local Notifications = {}

local function DrawNotification( x, y, w, h, text, icon, col, progress )
	draw.RoundedBoxEx( 8, x, y, w, h, col, true, true, true, true )
	if progress then
		draw.RoundedBoxEx( 8, x, y, h + ( w - h ) * progress, h, col, true, false, true, false )
	end

	draw.SimpleText( text, 'lrpNotify-font', x + 30 + 10, y + h / 2, color_white,
		TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	surface.SetDrawColor( color_white )
	surface.SetMaterial( icon )

	if progress then
		surface.DrawTexturedRectRotated( x + 16, y + h / 2, 16, 16, -CurTime() * 360 % 360 )
	else
		surface.DrawTexturedRect( x + 7, y + 7, 20, 20 )
	end
end

local OriginalAddLegacy = notification.AddLegacy
function notification.AddLegacy( text, type, time )
	if GetConVar('cl_lrp_hud_type'):GetInt() == 1 then
        return OriginalAddLegacy(text, type, time)
    end

	surface.SetFont('lrpNotify-font')

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
		col = colorMain,
		icon = Icons[ type ],
		time = CurTime() + time,

		progress = nil,
	} )
end

local OriginalAddProgress = notification.AddProgress
function notification.AddProgress( id, text, frac )
	if GetConVar('cl_lrp_hud_type'):GetInt() == 1 then
        return OriginalAddProgress(id, text, frac)
    end

	for k, v in ipairs( Notifications ) do
		if v.id == id then
			v.text = text
			v.progress = frac
			
			return
		end
	end

	surface.SetFont('lrpNotify-font')

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
		col = colorLoading,
		icon = LoadingIcon,
		time = math.huge,

		progress = math.Clamp( frac or 0, 0, 1 ),
	} )	
end

local OriginalKill = notification.Kill
function notification.Kill( id )
	if GetConVar('cl_lrp_hud_type'):GetInt() == 1 then
        return OriginalKill(id)
    end

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