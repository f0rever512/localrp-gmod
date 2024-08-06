local whiteList = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true
}

local function canAccessSpawnMenu(ply)
    if not ply:Alive() then return false end
    if GetGlobalBool("AccessSpawn") then return true end

    local wep = ply:GetActiveWeapon()
    return whiteList[wep:GetClass()] or false
end

if SERVER then
    local hooks = { 'PlayerSpawnVehicle', 'PlayerSpawnRagdoll', 'PlayerSpawnEffect', 'PlayerSpawnProp',
    'PlayerSpawnSENT', 'PlayerSpawnNPC', 'PlayerSpawnSWEP', 'PlayerGiveSWEP', }
    
    for _, hookName in pairs(hooks) do
        hook.Add(hookName, 'SpawnBlock', function(ply) return canAccessSpawnMenu(ply) end)
    end
else
    local function ClSpawnBlock()
        local ply = LocalPlayer()
        return canAccessSpawnMenu(ply)
    end
    hook.Add("ContextMenuOpen", 'SpawnBlock', ClSpawnBlock)
    hook.Add("SpawnMenuOpen", 'SpawnBlock', ClSpawnBlock)
end