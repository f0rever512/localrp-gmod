local size = math.Clamp(7.5, 5, 15) * 0.1
local scale = (ScrW() >= 2560 and size + 0.1) or (ScrW() / 175 >= 6 and size + 0.1) or 0.8
local CurTb = 0
local CurSlt = 1
local alpha = 0
local lastAction = -math.huge
local tblLoad = {}
local slide = {}
local newinv
local CurSwep = {}
local width = 200 * scale
local height = 25 * scale
local Marge = height / 4
local x = 0

local bgclr = Color(0, 0, 0, 210)
local selectclr = Color(0, 80, 65, 220)
local textclr = Color(255, 255, 255)

local hideElements = {
    ["CHudWeaponSelection"] = true
}
local tblFont = {}

for _, y in pairs(file.Find("scripts/weapon_*.txt", "MOD")) do
    local t = util.KeyValuesToTable(file.Read("scripts/" .. y, "MOD"))

    CurSwep[y:match("(.+)%.txt")] = {
        Slot = t.bucket,
        SlotPos = t.bucket_position,
        TextureData = t.texturedata
    }
end

function WeaponSelectorFont(scales)
    local name = ("WeaponSelectorFonts." .. tostring(scales))
    if tblFont[name] then return name end

    surface.CreateFont(name, {
        font = "Calibri",
        size = scales * 1.5 * scale,
        weight = 400 * scale,
        antialias = true,
	    extended = true
    })

    tblFont[name] = true

    return name
end

local function GetCurSwep()
    if alpha <= 0 then
        table.Empty(slide)
        local class = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()

        for k1, v1 in pairs(tblLoad) do
            for k2, v2 in pairs(v1) do
                if v2.classname == class then
                    CurTb = k1
                    CurSlt = k2

                    return
                end
            end
        end
    end
end

local function update()
    table.Empty(tblLoad)

    for k, v in pairs(LocalPlayer():GetWeapons()) do
        local classname = v:GetClass()
        local Slot = CurSwep[classname] and CurSwep[classname].Slot - 1 or v.Slot or 0
        tblLoad[Slot] = tblLoad[Slot] or {}

        table.insert(tblLoad[Slot], {
            classname = classname,
            name = v:GetPrintName(),
            slotpos = CurSwep[classname] and CurSwep[classname].SlotPos - 1 or v.SlotPos or 0
        })
    end

    for k, v in pairs(tblLoad) do
        table.sort(v, function(a, b) return a.slotpos < b.slotpos end)
    end
end

hook.Add("OnScreenSizeChanged", "WeaponSelector.Hooks.OnScreenSizeChanged", function(oldWidth, oldHeight)
    scale = (ScrW() >= 2560 and size + 0.1) or (ScrW() / 175 >= 6 and size + 0.1) or 0.8
end)

hook.Add("CreateMove", "WeaponSelector.Hooks.CreateMove", function(cmd)
    if newinv then
        local wep = LocalPlayer():GetWeapon(newinv)

        if wep:IsValid() and LocalPlayer():GetActiveWeapon() ~= wep then
            cmd:SelectWeapon(wep)
        else
            newinv = nil
        end
    end
end)

hook.Add("PlayerBindPress", "WeaponSelector.Hooks.PlayerBindPress", function(ply, bind, pressed)
    if !ply:Alive() then return end
    if not pressed then return end
    bind = bind:lower()
    if LocalPlayer():InVehicle() then return end

    if string.sub(bind, 1, 4) == "slot" and not ply:KeyDown(IN_ATTACK) then
        local n = tonumber(string.sub(bind, 5, 5) or 1) or 1
        if n < 1 or n > 6 then return true end
        n = n - 1
        update()
        if not tblLoad[n] then return true end
        GetCurSwep()

        if CurTb == n and tblLoad[CurTb] and (alpha > 0 or GetConVarNumber("hud_fastswitch") > 0) then
            CurSlt = CurSlt + 1

            if CurSlt > #tblLoad[CurTb] then
                CurSlt = 1
            end
        else
            CurTb = n
            CurSlt = 1
        end

        if GetConVarNumber("hud_fastswitch") > 0 then
            newinv = tblLoad[CurTb][CurSlt].classname
        else
            lastAction = RealTime()
            alpha = 1
        end

        surface.PlaySound("ambient/water/rain_drip1.wav")

        return true
    elseif bind == "invnext" and not ply:KeyDown(IN_ATTACK) then
        update()
        if #tblLoad < 0 then return true end
        GetCurSwep()
        CurSlt = CurSlt + 1

        if CurSlt > (tblLoad[CurTb] and #tblLoad[CurTb] or -1) then
            repeat
                CurTb = CurTb + 1

                if CurTb > 5 then
                    CurTb = 0
                end
            until tblLoad[CurTb]
            CurSlt = 1
        end

        if GetConVarNumber("hud_fastswitch") > 0 then
            newinv = tblLoad[CurTb][CurSlt].classname
        else
            lastAction = RealTime()
            alpha = 1
        end

        surface.PlaySound("ambient/water/rain_drip1.wav")

        return true
    elseif bind == "invprev" and not ply:KeyDown(IN_ATTACK) then
        update()
        if #tblLoad < 0 then return true end
        GetCurSwep()
        CurSlt = CurSlt - 1

        if CurSlt < 1 then
            repeat
                CurTb = CurTb - 1

                if CurTb < 0 then
                    CurTb = 5
                end
            until tblLoad[CurTb]
            CurSlt = #tblLoad[CurTb]
        end

        if GetConVarNumber("hud_fastswitch") > 0 then
            newinv = tblLoad[CurTb][CurSlt].classname
        else
            lastAction = RealTime()
            alpha = 1
        end

        surface.PlaySound("ambient/water/rain_drip1.wav")

        return true
    elseif bind == "+attack" and alpha > 0 then
        if tblLoad[CurTb] and tblLoad[CurTb][CurSlt] and not bind == "+attack2" then
            newinv = tblLoad[CurTb][CurSlt].classname
        end

        if LocalPlayer():GetActiveWeapon() and tblLoad[CurTb][CurSlt] then
            RunConsoleCommand('use', tblLoad[CurTb][CurSlt].classname)
        end

        alpha = 0

        surface.PlaySound("ambient/water/rain_drip3.wav")

        return true
    end
end)

hook.Add("HUDPaint", "WeaponSelector.Hooks.HUDPaint", function()
    if not IsValid(LocalPlayer()) then return end

    if alpha < 1e-02 then
        if alpha ~= 0 then
            alpha = 0
        end

        return
    end

    update()

    if RealTime() - lastAction > 2 then
        alpha = Lerp(FrameTime() * 10, alpha, 0)
    end

    surface.SetAlphaMultiplier(alpha)
    surface.SetDrawColor(bgclr)
    surface.SetTextColor(textclr)
    surface.SetFont(WeaponSelectorFont(20))
    local thisWidth = 0

    for i, v in pairs(tblLoad) do
        thisWidth = thisWidth + width + Marge
    end

    x = (ScrW() - thisWidth) / 2

    local pos = x

    for i, v in SortedPairs(tblLoad) do
        local y = Marge

        pos = x + thisWidth * 0.1

        for j, wep in pairs(v) do
            local selected = CurTb == i and CurSlt == j
            local height = height + (height + Marge) * 1
            draw.RoundedBox(0, x, y, width, height, selected and selectclr or bgclr)

            local w, h = surface.GetTextSize(wep.name)

            if w > width - 10 then
                surface.SetFont(WeaponSelectorFont(16))
                w, h = surface.GetTextSize(wep.name)
            else
                surface.SetFont(WeaponSelectorFont(20))
                w, h = surface.GetTextSize(wep.name)
            end

            surface.SetTextPos(x + (width - w) / 2, y + (height - h) / 2)
            surface.DrawText(wep.name)
            y = y + height + Marge
        end

        x = x + width + Marge
    end

    surface.SetAlphaMultiplier(1)
end)

hook.Add("HUDShouldDraw", "WeaponSelector.Hooks.HUDShouldDraw", function(elementName)
    if hideElements[elementName] then return false end
end)