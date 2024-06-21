whiteList = {
	"weapon_physgun",
	"gmod_tool"
}

if SERVER then
    local function spawnmenublock(ply,class)
		local wep = ply:GetActiveWeapon()

        if !ply:Alive() then return false end

		if ply:IsAdmin() then return true end

		if !table.HasValue(whiteList, wep:GetClass()) then return false end
    end

    --[[hook.Add("PlayerSpawnVehicle","Cantspawnbullshit",function(ply) return spawnmenublock(ply,"vehicle") end)
    hook.Add("PlayerSpawnRagdoll","Cantspawnbullshit",function(ply) return spawnmenublock(ply,"ragdoll") end)
    hook.Add("PlayerSpawnEffect","Cantspawnbullshit",function(ply) return spawnmenublock(ply,"effect") end)
    hook.Add("PlayerSpawnProp","Cantspawnbullshit",function(ply) return spawnmenublock(ply,"prop") end)
    hook.Add("PlayerSpawnSENT","Cantspawnbullshit",function(ply) return spawnmenublock(ply,"sent") end)
    hook.Add("PlayerSpawnNPC","Cantspawnbullshit",function(ply) return spawnmenublock(ply,"npc") end)

    hook.Add("PlayerSpawnSWEP","SpawnBlockSWEP",function(ply) return spawnmenublock(ply,"swep") end)
    hook.Add("PlayerGiveSWEP","SpawnBlockSWEP",function(ply) return spawnmenublock(ply,"swep") end)

    local function spawn(ply,class,ent)
        local func = TableRound().spawnmenublock
        func = func and func(ply,class,ent)
    end

    hook.Add("PlayerSpawnedVehicle","sv_round",function(ply,model,ent) spawn(ply,"vehicle",ent) end)
    hook.Add("PlayerSpawnedRagdoll","sv_round",function(ply,model,ent) spawn(ply,"ragdoll",ent) end)
    hook.Add("PlayerSpawnedEffect","sv_round",function(ply,model,ent) spawn(ply,"effect",ent) end)
    hook.Add("PlayerSpawnedProp","sv_round",function(ply,model,ent) spawn(ply,"prop",ent) end)
    hook.Add("PlayerSpawnedSENT","sv_round",function(ply,model,ent) spawn(ply,"sent",ent) end)
    hook.Add("PlayerSpawnedNPC","sv_round",function(ply,model,ent) spawn(ply,"npc",ent) end)]]
else
    local function spawnmenublock()
        local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
        
        if !ply:Alive() then return false end

        if GetGlobalBool("AccessSpawn") then return true end

		if !table.HasValue(whiteList, wep:GetClass()) then return false end
    end

    hook.Add("ContextMenuOpen", "hide_spawnmenu", spawnmenublock)
    hook.Add("SpawnMenuOpen", "hide_spawnmenu", spawnmenublock)
end