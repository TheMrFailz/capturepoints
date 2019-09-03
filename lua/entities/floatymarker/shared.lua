ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Floating Marker"
ENT.Author			= "TheMrFailz"
ENT.Contact			= "Coconut Corp"
ENT.Purpose			= "The floating bit above it."
ENT.Instructions	= "Do not feed to the snails."

ENT.Spawnable		= true
ENT.Category		= "GPoints"
ENT.AdminOnly		= true




function ENT:Initialize()
	if SERVER then
       
    else

		local matprop = {
		["$basetexture"] = "phoenix_storms/grey_chrome",
		["$model"] = 1,
		["$ignorez"] = 1,
		--["$selfillum"] = 1,
		--["$selfillummaskscale"] = 0.1
		}

		self:SetRenderMode(RENDERMODE_GLOW)
		self:SetRenderFX(kRenderFxDistort)


		local transmat = CreateMaterial( "transparentcapturepointG", "UnlitGeneric",  matprop)

        self:SetMaterial("!transparentcapturepointG")
    end
end