local respawnTimeCVar = CreateConVar('lrp_respawntime', 5, FCVAR_ARCHIVE, 'Set respawn time')

function getRespawnTime()
    return respawnTimeCVar:GetInt()
end