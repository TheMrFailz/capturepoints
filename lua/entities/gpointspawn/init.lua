
AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')



function ENT:Initialize()
	self:SetModel( "models/player/kleiner.mdl" )
	self:PhysicsInit( SOLID_NONE )      
	self:SetMoveType( MOVETYPE_NONE )   
	self:SetSolid( SOLID_VPHYSICS )         
	self:SetUseType(SIMPLE_USE)
	--self:EmitSound("ambient/machines/lab_loop1.wav", 60)




    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMaterial("metal")
		phys:SetMass(1000000)
	end

	
end



function ENT:Think()
	
end

