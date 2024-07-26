local whiteList = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true
}

local function canAccessSpawnMenu(ply)
    if not ply:Alive() then return false end
    if ply:IsAdmin() or GetGlobalBool("AccessSpawn") then return true end

    local wep = ply:GetActiveWeapon()
    return whiteList[wep:GetClass()] or false
end

if SERVER then
    hook.Add("PlayerSpawnSWEP", "BlockSpawnMenu", function(ply, class)
        return canAccessSpawnMenu(ply)
    end)
else
    local function spawnMenuBlock()
        local ply = LocalPlayer()
        return canAccessSpawnMenu(ply)
    end

    hook.Add("ContextMenuOpen", "hide_spawnmenu", spawnMenuBlock)
    hook.Add("SpawnMenuOpen", "hide_spawnmenu", spawnMenuBlock)
end