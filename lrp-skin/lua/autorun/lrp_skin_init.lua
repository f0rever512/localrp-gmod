if SERVER then
    AddCSLuaFile("skins/localrp_skin.lua")
    print("LocalRP Skin initialized on server")
else
    include("skins/localrp_skin.lua")
    print("LocalRP Skin initialized on client")
    hook.Add("ForceDermaSkin", "setskin", function()
		return "localrp_skin"
	end)
end