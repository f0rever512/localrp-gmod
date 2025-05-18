CreateClientConVar('cl_lrp_silent_switch', 0, true, true)

local chPosOff, chAngOff = Vector(0, 0, 0), Angle(0, 90, 90)

local function postDrawTranslucentRenderables()
    local ply = LocalPlayer()
    local override = hook.Run('dbg-view.chShouldDraw', ply)
    if override == nil then
        local wep, veh = ply:GetActiveWeapon(), ply:GetVehicle()
        if IsValid(wep) and wep.DrawCrosshair then
            override = not IsValid(veh) or ply:GetAllowWeaponsInVehicle()
        end
    end

    if not override then return end

    local aim = ply:EyeAngles():Forward()
    local tr = hook.Run('dbg-view.chTraceOverride')
    if not tr then
        local pos = ply:GetShootPos()
        local endpos = pos + aim * 2000
        tr = util.TraceLine({
            start = pos,
            endpos = endpos,
            filter = function(ent)
                return ent ~= ply and ent:GetRenderMode() ~= RENDERMODE_TRANSALPHA
            end
        })
    end

    local _icon = hook.Run('dbg-view.chOverride', tr)
    local n = tr.Hit and tr.HitNormal or -aim
    if math.abs(n.z) > 0.98 then
        n:Add(-aim * 0.01)
    end
    local chPos, chAng = LocalToWorld(chPosOff, chAngOff, tr.HitPos or endpos, n:Angle())
    cam.Start3D2D(chPos, chAng, math.pow(tr.Fraction, 0.5) * 0.25)
    cam.IgnoreZ(true)
    if not hook.Run('dbg-view.chPaint', tr, _icon) then
        surface.SetDrawColor(255, 255, 255, 150)
    end
    cam.IgnoreZ(false)
    cam.End3D2D()
end

hook.Add('PostDrawTranslucentRenderables', 'dbg-view', postDrawTranslucentRenderables)

local delays = {}

surface.CreateFont('lrp.switchFont', {
	font = 'Calibri',
	extended = true,
	size = 82,
	weight = 350,
})

local isSwitching = false
local id = 'switchDelay'

net.Receive('switchDelay', function()
    isSwitching = net.ReadBool()
    local switchTime = net.ReadFloat()

    if isSwitching then
        delays[id] = {
            text = language.GetPhrase('lrp_switch.display_text'),
            start = CurTime(),
            time = switchTime,
        }
    else
        delays[id] = nil
    end
end)

hook.Add('StartCommand', 'switchDelay.removeKeys', function(ply, cmd)
    if not isSwitching then return end
    cmd:RemoveKey(IN_ATTACK)
    cmd:RemoveKey(IN_ATTACK2)
end)

local cx, cy = 0, 0
local size = 40
local p1, p2 = {}, {}
for i = 1, 36 do
    local a1 = math.rad((i-1) * -10 + 180)
    local a2 = math.rad(i * -10 + 180)
    p1[i] = { x = cx + math.sin(a1) * (size + 6), y = cy + math.cos(a1) * (size + 6) }
    p2[i] = {
        { x = cx, y = cy },
        { x = cx + math.sin(a1) * size, y = cy + math.cos(a1) * size },
        { x = cx + math.sin(a2) * size, y = cy + math.cos(a2) * size },
    }
end

local override
hook.Add('dbg-view.chShouldDraw', 'switchDelay', function()
    override = table.Count(delays) > 0
    if override then return true end
end)

hook.Add('dbg-view.chPaint', 'switchDelay', function(tr, icon)
	for id, data in pairs(delays) do
		local segs = math.min(math.ceil((CurTime() - data.start) / data.time * 36), 36)
		local text = data.text .. ('.'):rep(math.floor(CurTime() * 2 % 4))
		draw.SimpleTextOutlined(text, 'lrp.switchFont', 0 + 60, 0, Color(255, 255, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 230))

		draw.NoTexture()
		surface.SetDrawColor(0, 0, 0, 230)
		surface.DrawPoly(p1)

		surface.SetDrawColor(255,255,255, 150)
		for i = 1, segs do
			surface.DrawPoly(p2[i])
		end

		return true
	end
end)

hook.Add('dbg-view.chOverride', 'switchDelay', function(tr, icon)
    local ply = LocalPlayer()
    if override and (not tr.Hit or tr.Fraction > 0.03) then
        local aim = ply:EyeAngles():Forward()
        tr.HitPos =  ply:GetShootPos() + aim * 60
        tr.HitNormal = -aim
        tr.Fraction = 0.03
    end
end)