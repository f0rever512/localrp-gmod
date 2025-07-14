local hulltrdata = {}
local function PlayerHullTrace(pos, ply, filter)
	hulltrdata.start = pos
	hulltrdata.endpos = pos
	hulltrdata.filter = filter

	return util.TraceEntity( hulltrdata, ply )
end

local directions = {
	Vector(0,0,0), Vector(0,0,1), -- Center and up
	Vector(1,0,0), Vector(-1,0,0), Vector(0,1,0), Vector(0,-1,0) -- All cardinals
	}
for deg = 45, 315, 90 do -- Diagonals
	local r = math.rad(deg)
	table.insert(directions, Vector(math.Round(math.cos(r)), math.Round(math.sin(r)), 0))
end

local magn = 15 -- How much increment for each iteration
local iterations = 2 -- How many iterations
local function PlayerSetPosNoBlock( ply, pos, filter )
	local tr

	local dirvec
	local m = magn
	local i = 1
	local its = 1
	repeat
		dirvec = directions[i] * m
		i = i + 1
		if i > #directions then
			its = its + 1
			i = 1
			m = m + magn
			if its > iterations then
				ply:SetPos(pos) -- We've done as many checks as we wanted, lets just force him to get stuck then.
				return false
			end
		end

		tr = PlayerHullTrace(dirvec + pos, ply, filter)
	until tr.Hit == false

	ply:SetPos(pos + dirvec)
	return true
end

local meta = FindMetaTable('Player')

function meta:InvisiblePlayerModel(bool)
	self:SetNoDraw(bool)
	self:DrawShadow(not bool)
	self:SetCollisionGroup(bool and COLLISION_GROUP_IN_VEHICLE or COLLISION_GROUP_PLAYER)
	self:SetNotSolid(bool)
	self:DrawWorldModel(not bool)

	if bool then
		self:Lock()
	else
		self:UnLock()
	end
end

function meta:SetRagdoll(bool)
    if bool then
        local plyphys = self:GetPhysicsObject()
        local plyvel = Vector(0,0,0)
        if plyphys:IsValid() then
            plyvel = plyphys:GetVelocity()
        end

        self.defPos = self:GetPos() -- Store pos incase the ragdoll is missing when we're to unrag him.

        local rag = ents.Create("prop_ragdoll")
        rag:SetModel(self:GetModel())
        rag:SetSkin(self:GetSkin())
        rag:SetPos(self:GetPos())
        rag:SetAngles(Angle(0, self:GetAngles().y, 0))
        rag:SetColor(self:GetColor())
        rag:SetMaterial(self:GetMaterial())
        rag:Spawn()
        rag:Activate()

        rag:GetPhysicsObject():SetInertia(Vector(1, 1, 1))

        for i = 1, rag:GetPhysicsObjectCount() do
            if IsValid(rag:GetPhysicsObject(i-1)) then
                rag:GetPhysicsObject(i-1):SetMass(12.7)
            end
        end
    
        -- Push him back abit
        plyvel = plyvel + (self:GetPos() - self:GetPos()):GetNormal() * 30
    
        -- Code copied from TTT
        local num = rag:GetPhysicsObjectCount() - 1
        for i = 0, num do
            local bone = rag:GetPhysicsObjectNum(i)
            if IsValid(bone) then
                local bp, ba = self:GetBonePosition(rag:TranslatePhysBoneToBone(i))
                if bp and ba then
                    bone:SetPos(bp)
                    bone:SetAngles(ba)
                end
    
                bone:SetVelocity(plyvel)
            end
        end

        self.playerRagdoll = rag
        self:SetParent(rag)
        self:InvisiblePlayerModel(true)
        self:SetNW2Entity('playerRagdollEntity', rag)
    else
        local pos
        if IsValid(self.playerRagdoll) then -- Sometimes the ragdoll is missing when we want to unrag, not good!
            if self.playerRagdoll.hasremoved then return end -- It has already been removed.
            self.playerRagdoll.hasremoved = true

            pos = self.playerRagdoll:GetPos()
        else
            pos = self.defPos -- Put him at the place he got tazed, works great.
        end
        self:SetParent()
    
        PlayerSetPosNoBlock(self, pos, {self, self.playerRagdoll})
    
        SafeRemoveEntity(self.playerRagdoll)
        self:InvisiblePlayerModel(false)
        
        self:SetLocalVelocity(Vector(0, 0, 0))
        self:SetAbsVelocity(Vector(0, 0, 0))
    end
end