function GM:HUDDrawTargetID() end

function GM:DrawDeathNotice(x, y) end

function GM:HUDAmmoPickedUp(itemName, amount)
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    notification.AddLegacy(lrp.lang('lrp_gm.hud_ammo_picked_up', itemName, amount), NOTIFY_HINT, 2)
    surface.PlaySound('buttons/lightswitch2.wav')
end

function GM:HUDItemPickedUp(itemName)
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    notification.AddLegacy(lrp.lang('lrp_gm.hud_item_picked_up', lrp.lang(itemName)), NOTIFY_HINT, 2)
    surface.PlaySound('buttons/lightswitch2.wav')
end

function GM:HUDWeaponPickedUp(wep) return false end

hook.Add('DrawPhysgunBeam', 'lrp-gamemode.physgunColor', function(ply, wep, enabled, target, bone, deltaPos)
    local color = ply:IsAdmin() and Vector(1, 0, 0) or Vector(1, 1, 1)

    ply:SetWeaponColor(enabled and color or Vector(0, 0, 0))
end)

local whiteList = lrp_cfg.sboxMenuWhiteList

local function sboxMenuBlock()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not IsValid(ply) or not IsValid(wep) then return end
    
    if not ply:Alive() then return false end

    if not whiteList[wep:GetClass()] then return false end
end

hook.Add('ContextMenuOpen', 'sboxMenuBlock', sboxMenuBlock)
hook.Add('SpawnMenuOpen', 'sboxMenuBlock', sboxMenuBlock)

lrp = lrp or {}

function lrp.lang(key, ...)
    local text = language.GetPhrase(key)
    local args = {...}

    if #args > 0 then
        return string.format(text, unpack(args))
    else
        return text
    end
end