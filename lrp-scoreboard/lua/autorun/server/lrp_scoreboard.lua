function adminstration(cmd, text)
	net.Receive( cmd, function( len, ply )
		local p = net.ReadEntity()
		if ply:IsAdmin() then
			print(ply:GetName(), text, p:GetName())
			if cmd == "kickuser" then
				p:Kick( "Kicked from the server" )
			elseif cmd == "5m" then
				p:Ban( 5, true )
			elseif cmd == "15m" then
				p:Ban( 15, true )
			elseif cmd == "freeze" then
				p:Freeze( true )
			elseif cmd == "unfreeze" then
				p:Freeze( false )
			elseif cmd == "5sec" then
				if p:Alive() then
					p:Ignite(5)
				end
			elseif cmd == "10sec" then
				if p:Alive() then
					p:Ignite(10)
				end
			elseif cmd == "unignite" then
				if p:Alive() then
					p:Extinguish()
				end
			elseif cmd == "5hp" then
				if p:Alive() then
					p:SetHealth(5)
				end
			elseif cmd == "25hp" then
				if p:Alive() then
					p:SetHealth(25)
				end
			elseif cmd == "50hp" then
				if p:Alive() then
					p:SetHealth(50)
				end
			elseif cmd == "100hp" then
				if p:Alive() then
					p:SetHealth(100)
				end
			elseif cmd == "kill" then
				if p:Alive() then
					p:Kill()
				end
			elseif cmd == "silkill" then
				if p:Alive() then
					p:KillSilent()
				end
			elseif cmd == "0ar" then
				if p:Alive() then
					p:SetArmor(0)
				end
			elseif cmd == "25ar" then
				if p:Alive() then
					p:SetArmor(25)
				end
			elseif cmd == "50ar" then
				if p:Alive() then
					p:SetArmor(50)
				end
			elseif cmd == "100ar" then
				if p:Alive() then
					p:SetArmor(100)
				end
			elseif cmd == "resp" then
				p:Spawn()
			else
				return
			end
		end
	end)
end
cmdnetwork = {
	"kickuser",
	"5m",
	"15m",
	"freeze",
	"unfreeze",
	"5sec",
	"10sec",
	"unignite",
	"5hp",
	"25hp",
	"50hp",
	"100hp",
	"kill",
	"silkill",
	"0ar",
	"25ar",
	"50ar",
	"100ar",
	"resp",
}
for v, k in pairs(cmdnetwork) do
	util.AddNetworkString(k)
end

local cmdtable = {}
cmdtable["kickuser"] = "кикнул"
cmdtable["5m"] = "забанил на 5 минут"
cmdtable["15m"] = "забанил на 15 минут"
cmdtable["freeze"] = "заморозил"
cmdtable["unfreeze"] = "разморозил"
cmdtable["5sec"] = "поджег на 5 секунд"
cmdtable["10sec"] = "поджег на 10 секунд"
cmdtable["unignite"] = "потушил"
cmdtable["5hp"] = "установил 5 здоровья"
cmdtable["25hp"] = "установил 25 здоровья"
cmdtable["50hp"] = "установил 50 здоровья"
cmdtable["100hp"] = "установил 100 здоровья"
cmdtable["kill"] = "убил"
cmdtable["silkill"] = "тихо убил"
cmdtable["0ar"] = "установил 0 брони"
cmdtable["25ar"] = "установил 25 брони"
cmdtable["50ar"] = "установил 50 брони"
cmdtable["100ar"] = "установил 100 брони"
cmdtable["resp"] = "возродил"

for v, k in pairs(cmdtable) do
	adminstration(v, k)
end