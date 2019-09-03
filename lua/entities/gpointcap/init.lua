
AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')



function ENT:Initialize()
	self:SetModel( "models/props_gameplay/cap_point_base.mdl" )
	self:PhysicsInit( SOLID_OBB )      
	self:SetMoveType( MOVETYPE_NONE )   
	--self:SetSolid( SOLID_VPHYSICS )         
	self:SetUseType(SIMPLE_USE)
	--self:EmitSound("ambient/machines/lab_loop1.wav", 60)

	local size = 100000

	self:SetTrigger(true)
	--self:SetCollisionBounds(Vector(-size, -size, -size),Vector(size, size, size))
	self:UseTriggerBounds(true, size)
	
	self.touchyplayers = {}

	self.OwnerTeam = 0 -- Team ID for who owns it.
	self.CapVal = 0 -- -100 to 100 value for capture status. Technically means it only supports 2 teams.
	
	self.CheckDelay = 1 -- How long should we wait to check if someone is capping us each time?
	self.CheckTimer = 0 -- Last time when we checked
	self.CheckSphere = 600 -- Radius of checking sphere

	self.TeamAID = gpoint_TeamAID
	self.TeamBID = gpoint_TeamBID

	self.ColorState = Color(200,200,200) -- What was our last colorstate?

	self.capann = false

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMaterial("metal")
		phys:SetMass(1000000)
	end
	
	self.marker = ents.Create("floatymarker")
	self.marker:SetPos(self:LocalToWorld(Vector(0,0,200)))
	self.marker:SetAngles(Angle(0,0,90))
	self.marker:SetParent(self)
	self.marker:Spawn()
	
end

function ENT:StartTouch(ply)
	table.insert(self.touchyplayers, ply)



end

function ENT:EndTouch(ply)
	table.RemoveByValue(self.touchyplayers, ply)



end

function ENT:Think()
	self.marker:SetAngles(Angle(0,CurTime() * 50,90))

	local hasTeamA = false
	local hasTeamB = false
	local hasTeamNone = true

	

	if self.CheckTimer < CurTime() then
		self.CheckTimer = CurTime() + self.CheckDelay 
		
	
		hasTeamA = false
		hasTeamB = false

		for k, v in pairs( self.touchyplayers ) do
			
			if v != nil then
		
				if v:IsPlayer() then
					
					if v:Team() == self.TeamAID then
						hasTeamA = true
						hasTeamNone = false

					elseif v:Team() == self.TeamBID then
						hasTeamB = true
						hasTeamNone = false
						
					end
					
					
				end
			end
		end
		if hasTeamA == false && hasTeamB == true then
			if self.CapVal != 100 then
				self.CapVal = self.CapVal + 10
				self.OwnerTeam = 0
				self:EmitSound("hl1/fvox/blip.wav")
				if self.capann == false then
					PrintMessage( HUD_PRINTTALK, team.GetName(self.TeamBID) .. " is capturing " .. self.pointName .. "!")
					self.capann = true
				end

				if self.CapVal == 100 then
					net.Start("capturepointcaptured")
					net.Broadcast()
					PrintMessage( HUD_PRINTTALK, team.GetName(self.TeamBID) .. " has captured " .. self.pointName .. "!")
					self.OwnerTeam = self.TeamBID
					self.ColorState = team.GetColor(self.TeamBID)
				end

			end
			
		elseif hasTeamA == true && hasTeamB == false then
			if self.CapVal != -100 then

				self.CapVal = self.CapVal - 10
				self:EmitSound("hl1/fvox/blip.wav")
				self.OwnerTeam = 0

				if self.capann == false then
					PrintMessage( HUD_PRINTTALK, team.GetName(self.TeamAID) .. " is capturing " .. self.pointName .. "!")
					self.capann = true
				end

				if self.CapVal == -100 then

					net.Start("capturepointcaptured")
					net.Broadcast()

					PrintMessage( HUD_PRINTTALK, team.GetName(self.TeamAID) .. " has captured " .. self.pointName .. "!")
					self.OwnerTeam = self.TeamAID
					self.ColorState = team.GetColor(self.TeamAID)
				end
				
			end
			
		elseif hasTeamA == true && hasTeamB == true then
			hasTeamNone = false
			
		end

		if hasTeamNone == true then
			if self.CapVal != 100 && (self.CapVal != 0 && self.CapVal != -100) then
				
				if self.CapVal < 100 && self.CapVal > 0 then
					self.CapVal = self.CapVal - 10
				elseif self.CapVal > -100 && self.CapVal < 0 then
					self.CapVal = self.CapVal + 10
				end
				
			end

			self.capann = false
			
		end
		
				
		-- self.marker:SetColor(LerpVector(100/math.abs(self.CapVal), self.ColorState:ToVector(), goingto:ToVector()):ToColor())

		local goingto = Color(0,0,0)
		if(self.CapVal > 0)then
			goingto = team.GetColor(self.TeamBID)
		else
			goingto = team.GetColor(self.TeamAID)
		end
		
		self.marker:SetColor(LerpVector(math.abs(self.CapVal) / 100, self.ColorState:ToVector(), goingto:ToVector()):ToColor())
		--self.marker:SetColor(Color(redval,greenval,blueval))
		
	end

	self:NextThink(CurTime() + 0.05)
	return true
end

