GM.Name = "LocalRP"
GM.Author = "forever512"
GM.Website = "https://github.com/f0rever512"

DeriveGamemode('sandbox')

function GM:Initialize()
	MsgN((SERVER and 'LocalRP Gamemode Initialized' or 'LocalRP Gamemode Initialized') .. os.date(' - %H:%M:%S', os.time()))
end