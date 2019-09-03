
AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
 
include('shared.lua')



function ENT:Initialize()
	self:SetModel( "models/hunter/geometric/hex1x1.mdl" )
	--self:SetMaterial("phoenix_storms/grey_chrome")
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_NONE )   
	self:SetSolid( SOLID_VPHYSICS )         
	self:SetUseType(SIMPLE_USE)
	self:EmitSound("ambient/machines/lab_loop1.wav", 60)

	
end

