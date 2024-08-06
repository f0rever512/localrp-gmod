local whiteList = {
    ["weapon_physgun"] = true,
    ["gmod_tool"] = true
}

if SERVER then
    local function SvSpawnBlock(ply)
        if not ply:Alive() then return false end
        if GetGlobalBool("AccessSpawn") then return true end

        local wep = ply:GetActiveWeapon()
		if not whiteList[wep:GetClass()] then return false end
    end
    
    local hooks = { 'PlayerSpawnVehicle', 'PlayerSpawnRagdoll', 'PlayerSpawnEffect', 'PlayerSpawnProp',
    'PlayerSpawnSENT', 'PlayerSpawnNPC', 'PlayerSpawnSWEP', 'PlayerGiveSWEP', }
    
    for _, hookName in pairs(hooks) do
        hook.Add(hookName, 'SpawnBlock', function(ply) return SvSpawnBlock(ply) end)
    end
else
    local function ClSpawnBlock()
        local ply = LocalPlayer()
	
        if !ply:Alive() then return false end
        if GetGlobalBool("AccessSpawn") then return true end

        local wep = ply:GetActiveWeapon()
		if not whiteList[wep:GetClass()] then return false end
    end

    hook.Add("ContextMenuOpen", 'SpawnBlock', ClSpawnBlock)
    hook.Add("SpawnMenuOpen", 'SpawnBlock', ClSpawnBlock)
end