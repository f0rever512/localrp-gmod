if SERVER then
    AddCSLuaFile("skins/localrp_skin.lua")
    print("LocalRP Skin loaded on server")
else
    include("skins/localrp_skin.lua")
    print("LocalRP Skin loaded on client")
    hook.Add("ForceDermaSkin", "LRPSkin", function()
		return "localrp_skin"
	end)
end