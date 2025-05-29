function GM:AllowPlayerPickup(ply, ent) return false end

function GM:PlayerDeathSound(ply)
    local gender = string.find(ply:GetModel(), 'female') and 'female01' or 'male01'

    ply:EmitSound('vo/coast/odessa/' .. gender .. '/nlo_cubdeath0' .. math.random(1, 2) .. '.wav', 70)

	return true
end

function GM:PlayerCanPickupWeapon( ply, wep )
    return not ply:HasWeapon(wep:GetClass())
end

local whiteList = lrp_cfg.sboxMenuWhiteList

local function sboxMenuBlock(ply)
    local wep = ply:GetActiveWeapon()

    if not IsValid(ply) or not IsValid(wep) then return end
    
    if not ply:Alive() then return false end

    if not whiteList[wep:GetClass()] then return false end
end

local hooks = { 'PlayerSpawnVehicle', 'PlayerSpawnRagdoll', 'PlayerSpawnEffect', 'PlayerSpawnProp',
'PlayerSpawnSENT', 'PlayerSpawnNPC', 'PlayerSpawnSWEP', 'PlayerGiveSWEP', }

for _, hookName in pairs(hooks) do
    hook.Add(hookName, 'sboxMenuBlock', function(ply)
        return sboxMenuBlock(ply)
    end)
end